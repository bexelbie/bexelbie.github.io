---
title: "op-secret-manager: A SUID Tool for Secret Distribution"
date: 2026-02-06 12:40:00 +0100
excerpt: "A no-daemon tool that distributes 1Password secrets to multi-user Linux systems but retains centralized management."
---

Getting secrets from 1Password to applications running on Linux keeps forcing a choice I don't want to make. Manual retrieval works until you get more than a couple of things ... then you need something more. There are lots of options, but they all felt awkward or heavy, so I wrote [`op-secret-manager`](https://github.com/bexelbie/op-secret-manager) to fill the gap: a single-binary tool that fetches secrets from 1Password and writes them to per-user directories. No daemon, no persistent state, no ceremony.

## The Problem: Secret Zero on Multi-User Systems

The "secret zero" problem is fundamental: you need a first credential to unlock everything else. On a multi-user Linux system, this creates friction. Different users (application accounts like `postgres`, `redis`, or human operators) need different secrets. You want to centralize management (1Password) but local distribution without exposing credentials across user boundaries. You also don't want to solve the "secret zero" problem multiple times or have a bunch of first credentials saved in random places all over the disk.

Existing approaches each carry costs:

- **Manual copying**: Unscalable and leaves secret material in shell history or temporary files.
- **1Password CLI directly**: Requires each user to authenticate or have API key access, which recreates the distribution problem and litters the disk with API keys.
- **Persistent agents** (Connect, Vault): Add services to monitor, restart policies to configure, and failure modes to handle.
- **Cloud provider integrations**: Generally unavailable on bare metal or hybrid environments where half your infrastructure isn't in AWS/Azure/GCP.

What I wanted: the `postgres` user runs a command, secrets appear in `/run/user/1001/secrets/`, done.

## How It Works

The tool uses a mapfile to define which secrets go where:

```
postgres   op://vault/db/password         db_password
postgres   op://vault/db/connection       connection_string
redis      op://vault/redis/auth          redis_password
```

Each line maps a username, a 1Password secret reference, and an output path. Relative paths expand to `/run/user/<uid>/secrets/`. Absolute paths work if the user has write permission.

The "secret zero" challenge is now centralized through the use of a single API key file that all users can access. But the API key needs protection from unprivileged reads and ideally from the users themselves. This is where SUID comes in ... carefully.

## Privilege Separation Design

The security model uses SUID elevation to a service account (not root), reads protected configuration, then immediately drops privileges before touching the network or filesystem.

This has not been independently security audited. Treat it as you would any custom SUID program: read the source, understand the threat model, and test it in your environment before deploying broadly.

The flow:

1. Binary is SUID+SGID to `op:op` (an unprivileged service account)
2. Process starts with elevated privileges, reads:
   - API key from `/etc/op-secret-manager/api` (mode 600, owned by `op`)
   - Mapfile from `/etc/op-secret-manager/mapfile` (typically mode 640, owned by `op:op` or `root:op`)
3. Drops all privileges to the real calling user
4. Validates that the calling user appears in the mapfile
5. Fetches secrets from 1Password
6. Writes secrets as the real user to `/run/user/<uid>/secrets/`

Because the network calls and writes happen *after* the privilege drop, the filesystem automatically enforces isolation. User `postgres` cannot write to `redis`'s directory. The secrets land with the correct ownership without additional chown operations.

### Why SUID to a Service Account?

Elevating to root would be excessive. Elevating to a dedicated, unprivileged service account constrains the blast radius. If someone compromises the binary, they get the privileges of `op` (which can read one API key) rather than full system access.

Alternatives considered:

- **Linux capabilities** (`CAP_DAC_READ_SEARCH`): Still requires root ownership of the binary to assign capabilities, which increases risk.
- **Group-readable API key**: Forces all users into a shared group, allowing direct API key reads. This moves the problem rather than solving it.
- **No privilege separation**: Each user needs a copy of the API key, defeating centralized management.

The mapfile provides access control: it defines which users can request which secrets. The filesystem enforces it: even if you bypass the mapfile check, you can't write to another user's runtime directory. While you would theoretically be able to harvest a secret, you won't be able to modify what the other user uses. This is key because a secret may not actually be "secret." I have found it useful to centralize some configuration management, like API endpoint addresses, with this tool.

### Root Execution

Allowing root to use the tool required special handling. The risk is mapfile poisoning: an attacker modifies the mapfile to make root write secrets to dangerous locations.

The mitigation: root execution is only permitted if the mapfile is owned by `root:op` with no group or world write bits. If you can create a root-owned, properly-permissioned file, you already have root access and don't need this tool for privilege escalation.  The SGID bit on the binary lets the service account, `op`, read the mapfile even though it is owned by root.

## Practical Integration: Podman Quadlets

My primary use case is systemd-managed containers. Podman Quadlets make this concise. This example is of a rootless *user* Quadlet (managed via `systemctl --user`), not a system service.

```ini
[Unit]
Description=Application Container
After=network-online.target

[Container]
Image=docker.io/myapp:latest
Volume=/run/user/%U/secrets:/run/secrets:ro,Z
Environment=DB_PASSWORD_FILE=/run/secrets/db_password
ExecStartPre=/usr/local/bin/op-secret-manager
ExecStopPost=/usr/local/bin/op-secret-manager --cleanup

[Service]
Restart=always

[Install]
WantedBy=default.target
```

`ExecStartPre` fetches secrets before the container starts. The container sees them at `/run/secrets/` (read-only). `ExecStopPost` removes them on shutdown. The application reads secrets from files (not environment variables), avoiding the "secrets in env" problem where `env` or a log dump leaks credentials.

The secrets directory is a `tmpfs` (memory-backed `/run`), so nothing touches disk. If lingering is enabled for the user (`loginctl enable-linger`), the directory persists across logins.

## Trade-offs and Constraints

This design makes specific compromises for simplicity:

**No automatic rotation.** The tool runs, fetches, writes, exits. If a secret changes in 1Password, you need to re-run the tool (or restart the service). For scenarios requiring frequent rotation, a persistent agent might be better. For most use cases, rotation happens infrequently enough that ExecReload or a manual re-fetch works fine.

**Filesystem permissions are the security boundary.** If an attacker bypasses Unix file permissions (kernel exploit, root compromise), the API key is exposed. This is consistent with how `/etc/shadow` or SSH host keys are protected. File permissions are the Unix-standard mechanism. Encrypting the API key on disk would require storing the decryption key somewhere accessible to the SUID binary, recreating the same problem with added complexity.

**Scope managed by 1Password service account.** The shared API key is the critical boundary. If it's compromised, every secret it can access is exposed. Proper 1Password service account scoping (separate vaults, least-privilege grants, regular audits) is essential.

**Mapfile poisoning risk for non-root.** If an attacker can modify the mapfile, they can make users write secrets to unintended locations. This is mitigated by restrictive mapfile permissions (typically `root:op` with mode 640). The filesystem still prevents writes to directories the user doesn't own, but absolute paths could overwrite user-owned files.

**No cross-machine coordination.** This is a single-host tool. Distributing secrets to a cluster requires running the tool on each node or using a different solution.

## Implementation Details Worth Noting

The Go implementation uses the 1Password SDK rather than shelling out to `op` CLI. This avoids parsing CLI output and handles authentication internally.

Path sanitization prevents directory traversal (`..` is rejected). Absolute paths are allowed but subject to the user's own filesystem permissions after privilege drop.

The cleanup mode (`--cleanup`) removes files based on the mapfile. It only deletes files, not directories, and only if they match entries for the current user. This prevents accidental removal of shared directories.

A verbose flag (`-v`) exists primarily for debugging integration issues. Most production usage doesn't need it.

## Availability

The project is [on GitHub](https://github.com/bexelbie/op-secret-manager) under GPLv3. Pre-built binaries for Linux amd64 and arm64 are available in releases.

This isn't the right tool for every scenario. If you need dynamic rotation, audit trails beyond what 1Password provides, or distributed coordination, look at Vault or a cloud provider's secret manager. If you're running Kubernetes, use native secret integration.

But for the specific case of "I have a few Linux boxes, some containers, and a 1Password account; I want secrets distributed without adding persistent infrastructure," this does the job.
