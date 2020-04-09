---
title: Remote singing
toc: true
toc_label: "Table of Contents"
---

This page explains what you will need to participate in a remote singing
session.

# Setup

## Equipment

| Item | Ideal | Alternative | Notes |
|-|-|-|-|
| Computer | Dedicated laptop or desktop | smartphone | |
| Microphone ("mic") | External plug-in mic<br/>(USB or standard 3.5mm jack) | Use built-in mic on computer / phone | A good quality external mic is going to provide superior sound input. |
| Headphones | Pair of "over the ear" headphones<br/>(USB or standard 3.5mm jack) |  "in the ear" headphones / buds | Required to minimise background noise and hear the rest of the singers as clearly as possible. |
| Network connection | Ethernet cable | wifi! | Most routers / wifi hubs have one or more [Ethernet][ethernet] sockets on the back. Having a wired connection between your computer and the router provides a more **reliable** and generally **faster** link to the internet. |


## Software

- Register for the free [JamKazam][jamkazam] service.
- Download the free JamKazam application for Windows or MacOS.

## Initial setup

- Plugin your headphones and microphone.
- Start the JamKazam application and login.
- Click the menu button next to your name (top right).
- Click "Audio Gear" and follow the instructions to "Add new gear".
- Click the menu button again.
- Click "Test Network", then "Start network test".

  > **Note:**
  >
  > Unfortunately, this facility seems somewhat unreliable as sometimes it
  > reports, "No network test servers are available".

# Singing session

## Before joining a session

Check the following:

- *Ideally*, no other applications or apps are running on your device

  So close down your web browser, mail client, games, *etc*.

  > **Note:**
  >
  > This includes things like system updates which can really slow down the
  > system and use up your network bandwidth. Consider applying updates a few
  > hours before the meeting and rebooting after the updates complete.

- Your microphone and headphones are plugged in and working.

## On joining a session

- Ensure that once you have joined you:

  - Turn audio *on*

  - Turn video *off*

    Sending and recieving video takes up a lot of "bandwidth" and will
    potentially introduce delays/lag/latency which we need to avoid.

- We may want to record the session.

## After the session

Ask the singers for their view on:

- Audio quality?
- Any noticeable delays?
- Any other thoughts / improvements?

# Appendices

## Software Options

| Application | Audio codec | Duplex comms? | Public servers? | Private server possible? | Viable? | Notes |
|-|-|-|-|-|-|-|
| ~~[JackTrip][jacktrip]~~ | custom? | Yes | No | Yes | No | Setup too complex for most. |
| [JamKazam][jamkazam] | [Opus][opus] | Yes | Yes | No | possible | Free service, but unknown how reliable it is.<br/><br/>[Servers currently very busy / overloaded][jamkazam-overloaded]. |
| [Jamulus](http://llcon.sourceforge.net) | [Opus][opus] | Yes | Yes | Yes | possible | Would require us to run our own dedicated private server. |
| ~~[Jitsi](https://meet.jit.si)~~ | [Opus][opus] | No | Yes | Yes | No | No sign up or account required - just create/join a session! |
| [Ninjam](https://www.cockos.com/ninjam) | [OGG Vorbis][vorbis] | Yes | Yes | Yes | maybe | **Warning:** Public servers appear to auto-upload **all** recordings to a https://archive.org!<br/><br/>We could run it on a dedicated private server though. |
| ~~WhatsApp video~~ | [Opus][opus] | No | Yes | No | No |
| ~~[Zoom][zoom]~~ | [Opus][opus] | No | Yes | No | No | |

**Notes:**

- [Opus][opus] is the *de facto* and best audio codec available for encoding voice data.
- [OGG Vorbis][vorbis] is another (general purpose) excellent codec.
- Duplex communications (similar to "polyphony") are required to allow all singers to be heard by each other at the same time<br/>
  (as opposed to simplex where only one person can talk/sing at any one time).

[ethernet]: https://en.wikipedia.org/wiki/Ethernet
[jacktrip]: https://github.com/jacktrip/jacktrip
[jamkazam]: https://www.jamkazam.com
[jamkazam-overloaded]: https://sourceforge.net/p/llcon/discussion/533517/thread/ebb54e1b8f/?limit=25
[opus]: https://en.wikipedia.org/wiki/Opus_(audio_format)
[vorbis]: https://en.wikipedia.org/wiki/Vorbis
[zoom]: https://zoom.us
