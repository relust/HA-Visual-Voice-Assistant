# HA-Visual-Voice-Assistant

# Introduction

Ever since voice satellites [were introduced](https://www.home-assistant.io/blog/2023/04/27/year-of-the-voice-chapter-2/#composing-voice-assistants) to [Home Assistant](https://www.home-assistant.io/), people wanted to use good microphones and speakers for this purpose, but this is, yet, a work in progress.
Through this project I wanted to add to the voice assistant made in Home Assistant a visual image and random personalized responses that are displayed on an android tablet.
The purpose of this [ESPHome](https://www.esphome.io/) config is to be able to use such a modded Nest Mini as a voice satellite in Home Assistant. Here's a small demo:

https://youtu.be/fuX6IYa79gA

## Features

- wake word, push to talk, on-demand and continuous conversation support
- response playback
- audio media player
- service exposed in HA to start and stop the voice assistant from another device/trigger
- visual feedback of the wake word listening/audio recording/success/error status via the Mini's onboard top LEDs
- uses all 3 of the original Mini's touch controls as volume controls and a means of manually starting the assistant and setting the volume
- uses the original Mini's microphone mute button to prevent the wake word engine from starting unintendedly
- automatic continuous touch control calibration

## Pre-requisites

- Home Assistant 2023.11.3 or newer
- A voice assistant [configured in HA](https://my.home-assistant.io/redirect/voice_assistants/) with STT and TTS in a language of your choice
- ESPHome 2023.11.6 or newer

## Known issues and limitations

- you have to be able to retrofit an Onju Voice PCB inside a 2nd generation Google Nest Mini.
- ~~the `media_player` component in ESPHome [does not play raw audio coming from Piper TTS](https://github.com/home-assistant/core/issues/92969). It works with any STT that outputs mp3 by default, though~~ [fixed](https://github.com/home-assistant/core/pull/102814) in HA 2023.12
