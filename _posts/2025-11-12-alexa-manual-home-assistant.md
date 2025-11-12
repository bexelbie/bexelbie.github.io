---
title: "Managing a manual Alexa Home Assistant Skill via the Web UI"
date: 2025-11-12 13:40:00 +0100
excerpt: "Skip hand-editing YAML entity lists by tagging Home Assistant devices with labels and auto-generating the Alexa exposure list via an automation."
---

My house has a handful of Amazon Echo Dot devices that we mostly use for timers, turning lights on and off, and playing music. They work well and have been an easy solution. I also use [Home Assistant](https://home-assistant.io) for some basic home automation and serve most everything I want to verbally control to the Echo Dots from Home Assistant.

I don't use the [Nabu Casa Home Assistant Cloud Service](https://www.nabucasa.com). If you're reading this and you want the easy route, consider it — the cloud service is convenient. One benefit of the service is that there is a UI toggle to mark which entities/devices to expose to voice assistants.

If you take the [manual route](https://www.home-assistant.io/integrations/alexa.smart_home/), like I do, you must set up a developer account, AWS Lambda, and maintain a hand-coded list of entity IDs in a YAML file.

```yaml
- switch.living_room
- switch.table
- light.kitchen
- sensor.temp_humid_reindeer_marshall_temperature
- sensor.living_room_temperature
- sensor.temp_humid_rubble_chase_temperature
- sensor.temp_humid_olaf_temperature
- sensor.ikea_of_sweden_vindstyrka_temperature
- light.white_lamp_bulb_1_light
- light.white_lamp_bulb_2_light
- light.white_lamp_bulb_3_light
- switch.ikea_smart_plug_2_switch
- switch.ikea_smart_plug_1_switch
- sensor.temp_humid_chase_c_temperature
- light.side_light
- switch.h619a_64c3_power_switch
```
A list of entity IDs to expose to Alexa.
{: .text-center}

Fun, right? Maintaining that list is tedious. I generally don't mess with my Home Assistant installation very often. Therefore, when I need to change what is exposed to Alexa or add a new device, finding the actual entity_id is annoying.  This is not helped by how good Home Assistant has gotten at showing only friendly names in most places. I decided there had to be a better way to do this other than manually maintaining YAML.

After some digging through docs and the source, I found there isn't a built-in way to build this list by labels, categories, or friendly names. The Alexa integration supports only explicit entity IDs or glob includes/excludes.

So I worked out a way to build the list with a Home Assistant automation. It isn't fully automatic - there's no trigger that runs right before Home Assistant reboots - and you still need to restart Home Assistant when the list changes. But it lets me maintain the list by labeling entities rather than hand-editing YAML.

After a few experiments and some (occasionally overly imaginative) AI help, I arrived at this process. There are two parts.

## Prep and staging

In your `configuration.yaml` enable the Alexa Smart Home Skill to use an external list of entity IDs. I store mine in `/config/alexa_entities.yaml`.

```yaml
alexa:
  smart_home:
    locale: en-US
    endpoint: https://api.amazonalexa.com/v3/events
    client_id: !secret alexa_client_id
    client_secret: !secret alexa_client_secret
    filter:
      include_entities:
         !include alexa_entities.yaml
```

Add two helper shell commands:

<!-- {% raw %} -->
```yaml
shell_command:
  clear_alexa_entities_file: "truncate -s 0 /config/alexa_entities.yaml"
  append_alexa_entity: '/bin/sh -c "echo \"- {{ entity }}\" >> /config/alexa_entities.yaml"'
```
<!-- {% endraw %} -->

## A script to find the entities

Place this script in `scripts.yaml`. It does three things:
1. Clears the existing file.
2. Finds all entities labeled with the tag you choose (I use "Alexa").
3. Appends each entity ID to the file.

<!-- {% raw %} -->
```yaml
export_alexa_entities:
  alias: Export Entities with Alexa Label
  sequence:
    # 1. Clear the file
    - service: shell_command.clear_alexa_entities_file

    # 2. Loop through each entity and append
    - repeat:
        for_each: "{{ label_entities('Alexa') }}"
        sequence:
          - service: shell_command.append_alexa_entity
            data:
              entity: "{{ repeat.item }}"
  mode: single
```
<!-- {% endraw %} -->

Why clear the file and write it line by line? I couldn't get any `file` or `notify` integration to write to `/config`, and passing a YAML list to a shell command collapses whitespace into a single line. Reformatting that back into proper YAML without invoking Python was painful, so I chose to truncate and append line-by-line. It's ugly, but it's simple and it works.

The result is that I can label entities in the UI and avoid tedious bookkeeping.

![Home Assistant entity details screen showing an IKEA smart plug named 'tree' with the Alexa label applied in the Labels section](/img/2025/labeled-entity.jpg)
