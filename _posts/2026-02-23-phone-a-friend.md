---
title: "Phone a Friend: Multi-Model Subagents for VS Code Copilot Chat"
date: 2026-02-23 11:10:00 +0100
excerpt: "Dispatch subtasks to a different AI model - with editor gutter indicators intact."
---

I wanted a way to stay inside Visual Studio Code, use Copilot Chat as the "orchestrator," and still mix and match models for different parts of the work. Plan a change with one of the slower, more capable models, but let a smaller, faster model handle mechanical refactors. Edit a blog post with one model, but hand Jekyll plumbing or JSON/YAML munging to another. The friction was that the built-in Copilot Chat extension only lets subagents run on the same model as the parent conversation, while the Copilot CLI happily lets you pick any available model per run. Phone a Friend bolts that flexibility onto Copilot Chat, so I can keep the full VS Code experience - including gutter diffs - while dispatching subtasks to whatever model is best for the job.

## The Problem

When you use GitHub Copilot Chat in VS Code, every subagent it spawns runs on the same model as the parent conversation. If you're on Claude Opus 4.6, all subagents are Claude Opus 4.6. Sometimes you want a different model for a subtask - a faster one for simple work, or a different vendor for a second opinion.

GitHub Copilot CLI supports `--model` to pick any available model, but using it directly doesn't help - changes made by the CLI don't produce VS Code's gutter indicators (the green/red diff decorations in the editor margin). You get the work done but lose the visual feedback that makes code review comfortable.

[Phone a Friend](https://github.com/bexelbie/phone-a-friend) is an MCP server that solves both problems. It dispatches work to Copilot CLI with the model of choice, captures a unified diff of the changes, and returns it to the calling agent - which applies it through VS Code's edit tools. Gutter indicators show up as the changes were made natively.

## How It Works

1. Copilot Chat calls the `phone_a_friend` MCP tool with a prompt, model name, and working directory
2. The MCP server creates an isolated git worktree from `HEAD`
3. It launches Copilot CLI in non-interactive mode in that worktree with the requested model
4. The subagent does its work and writes its response to a "message-in-a-bottle" file
5. The MCP server reads the response, captures a `git diff`, and cleans up the worktree
6. The MCP server then returns the response text and unified diff to the calling agent
7. The calling agent applies the diff using VS Code's edit tools - gutter indicators appear

The "message in a bottle" pattern is worth explaining. Copilot CLI's stdout mixes the agent's response with progress output and is unreliable to parse. Rather than fighting noisy output, the tool instructs the subagent to write its final response to a file. The server reads the file. Clean separation.

## Safety

Worktree isolation means your working tree is never modified directly. Push protection blocks `git push` at the tool level. Worktrees are cleaned up after every invocation, even on errors.

## Setup

You install Phone a Friend like any other MCP server in VS Code: add the `@bexelbie/phone-a-friend` npm package through the `MCP: Add Server...` command, or point VS Code at it via your MCP configuration. The GitHub README details the exact JSON and prerequisites (Node.js, Copilot CLI, Git).

## Usage

Once configured, you stay in Copilot Chat and describe the outcome you want; the calling agent decides when to route a subtask through Phone a Friend. The tool surface includes discovery hints, so natural phrasing like "get a second opinion from another model" is usually enough to trigger it. Any model that Copilot CLI exposes is available.

## Known Limitations

A few trade-offs worth knowing:

- **Context cost.** The unified diff lands in the calling agent's context window. Large diffs eat context. I've got an issue open exploring ideas for improving this.
- **Message-in-a-bottle compliance.** Most models follow the instruction to write their final response into the message-in-a-bottle file, but some may occasionally ignore it. When that happens, the calling agent still gets the diff of any file changes but not the response text.

## Availability

The project is [on GitHub](https://github.com/bexelbie/phone-a-friend) under MIT license, and published on npm as [`@bexelbie/phone-a-friend`](https://www.npmjs.com/package/@bexelbie/phone-a-friend). Written in TypeScript.

## What Changed For Me

Since integrating this into my Copilot setup, the biggest shift is that I no longer have to choose between "the model I want to think with" and "the model I want to do the work" and I eliminated a bunch of copy/paste from manually emulating this. I keep the main conversation with a larger, more capable model for planning and review, and routinely:

- send quick, mechanical refactors to a smaller, faster model
- hand Jekyll front matter, Liquid, and config tweaks to a model that's better at markup and templating
- ask a different vendor's model for a second opinion on changes or ideas, especially where that model may be better at the task

Because everything still lands back in the same VS Code buffer with normal gutter diffs, it feels like one coherent tool instead of a handful of loosely-connected ones.

The project also had an unexpected dynamic in the development process. Building an MCP server that mimics a capability already available to the model created a strange feedback loop. I could collaborate on the implementation with Opus, and then turn around and interview it as a subject matter expert on how it uses that very same capability. It was a weird feeling to use the model as both a partner in writing the code and a primary source for understanding the user requirements.
