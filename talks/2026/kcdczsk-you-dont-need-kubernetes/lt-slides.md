---
marp: true
theme: default
paginate: true
footer: "**The 139 Euro Monitoring Stack - KCD Czech & Slovak 2026 - www.bexelbie.com - @bexelbie@toot.io**"
---

<!-- _class: lead -->
<!-- _paginate: false -->
<!-- _footer: "**KCD Czech & Slovak - Prague - May 2026**" -->

# The 139 Euro Monitoring Stack

Brian "bex" Exelbierd
www.bexelbie.com
www.puzzlesecretary.com
@bexelbie@toot.io

<!--
- Hi, I'm bex.
- I run a side project called PuzzleSecretary - it tracks social game scores for my friends.
- It's a real web service on the internet. It needs monitoring and alerting.
- My monitoring stack costs 139 euros, but since I already owned it ... in some ways it was free
- It can also make my lights dim ...
- Let me explain.
-->

---

# This Is My Monitoring Stack

<!-- TODO: photo of HA Green box or your IT cabinet -->
![bg right:40% fit](ha-green.jpg)

I bought it to track my water meter.

It's a Home Assistant Green. 139 euros.

It is also, accidentally:
- A time-series database
- An MQTT message bus
- A push notification system
- An automation engine with 100+ integrations

<!--
- This little box sits in my IT cabinet at home.
- I bought it to automate lights and track my water meter.
- But think about what it actually does.
- It takes a value, stores it over time, graphs it, and alerts you when something goes wrong.
- Battery levels. Temperature. Water consumption. That's time-series data.
- It speaks MQTT. It sends push notifications to my phone. It runs automations.
- That is a monitoring stack. The box just didn't say so.
-->

---

# The Server (60-Second Version)

![bg right:30% fit](flatcar-logo.svg)

- **Flatcar Linux** - immutable OS, auto-updates itself
- **Rootless Podman** - containers managed by systemd
- **Cloudflare Tunnel + Tailscale** - zero open ports
- **1Password API** - secrets download at boot

One VM. Zero maintenance most weeks.

The boring infrastructure takes care of itself.
The interesting question is monitoring.

<!--
- I'm going to go fast here because this isn't the point of the talk.
- Flatcar is immutable. It updates itself. I don't touch it.
- Podman runs my containers as an unprivileged user. Systemd manages them and brings the up in the right order.
- Cloudflare Tunnel handles public traffic. Tailscale handles SSH. Zero inbound ports on the VM.
- 1Password has an API. Secrets get pulled before services start.
- All of this takes care of itself. Most weeks I spend zero minutes on it.
- But monitoring. I need to know when something breaks.
- I don't want to run Grafana because then I am going to need more infrastructure.
- Besides, I know me and I'm never going to look at a dashboard.
-->

---

# CPU Graphs Next to Water Meters

<!-- TODO: screenshot of actual HA dashboard showing server + household metrics -->
![bg fit](ha-dashboard.png)

<!--
- This is my actual Home Assistant dashboard.
- On the left: water consumption, thermostat, household stuff.
- On the right: CPU, memory, disk usage from my server.
- Telegraf collects metrics on the VM and publishes them over MQTT.
- They flow through Tailscale to Home Assistant at my house.
- HA stores them in long-term statistics. Same engine. Same graphs.
- Container needs updating? Adds a to-do list item. Right next to "buy groceries."
- Memory spiking? Push notification to my phone.
- Server stops sending metrics entirely? Override silent mode. Wake me up.
- I wrote some automations. That's the whole alerting system.
-->

---

<!-- _class: lead -->
<!-- _paginate: false -->
<!-- _footer: "**KCD Czech & Slovak - Prague - May 2026**" -->

# Your side project is not your day job.

Stop over-engineering it with your day job's tools.

**puzzlesecretary.com**

Brian "bex" Exelbierd
www.bexelbie.com - @bexelbie@toot.io

<!--
- 139 euros. A box I already had. Some automations.
- Your side project doesn't need Grafana. It doesn't need Kubernetes. It doesn't need PagerDuty.
- It needs you to ask: what do I already have?
- Thank you.
-->

<!-- Build Notes:
Build: marp --pptx --html lt-slides.md -o lt-slides.pptx --allow-local-files
TODO: Add ha-green.jpg (photo of HA Green box or IT cabinet)
TODO: Add ha-dashboard.png (screenshot showing server metrics alongside household data)
TODO: Create a "messy real" HA dashboard mixing household + server: kitchen lights on/off, water meter last hour, server memory usage, container updates needed, thermostat. Screenshot it for slide 4. Don't polish it - should look like someone's actual HA, not a demo.
TODO: Copy flatcar-logo.svg from the installfest talk directory
-->
