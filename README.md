# HA-Visual-Voice-Assistant

# Introduction

Ever since voice satellites [were introduced](https://www.home-assistant.io/blog/2023/04/27/year-of-the-voice-chapter-2/#composing-voice-assistants) to [Home Assistant](https://www.home-assistant.io/), people wanted to use good microphones and speakers for this purpose, but this is, still, a work in progress.
Through this project I wanted to add to the voice assistant made in Home Assistant a visual image and random personalized responses that are displayed on an android tablet.
To achieve this, I will use an esp32 satellite programmed with [ESPHome](https://www.esphome.io/). and a androit wall mounted tablet.
 Here's a small demo:

https://youtu.be/fuX6IYa79gA

## Features

- wake word, push to talk, on-demand and continuous conversation support
- response playback
- audio media player
- service exposed in HA to start and stop the voice assistant from another device/trigger
- visual feedback of the wake word listening/audio recording/success/error status via the satellite LEDs
- visual feedback on the tablet display
- uses touch control on the satellite for toggle wake word activation with long touch, and start/stop listening when wake word detection is off with short touch.

## Pre-requisites

- Home Assistant 2023.11.3 or newer
- A voice assistant [configured in HA](https://my.home-assistant.io/redirect/voice_assistants/) with STT and TTS in a language of your choice
- ESPHome 2023.11.6 or newer

## Instructions
- Install Fully kiosk browser on android tablet and Fully Kiosk Browser integration on Home Assistant.
- Install Browser Mod integration with HACS.


