# HA-Visual-Voice-Assistant

# Introduction

Ever since voice satellites [were introduced](https://www.home-assistant.io/blog/2023/04/27/year-of-the-voice-chapter-2/#composing-voice-assistants) to [Home Assistant](https://www.home-assistant.io/), people wanted to use good microphones and speakers for this purpose, but this is, still, a work in progress.
Through this project I wanted to add to the voice assistant made in Home Assistant a visual image and random personalized responses that are displayed on an android tablet.
To achieve this, I will use an esp32 satellite programmed with [ESPHome](https://www.esphome.io/). and a androit wall mounted tablet.
 Here's a small demo:

https://youtu.be/fuX6IYa79gA

## Features

- wake word, push to talk, on-demand and continuous conversation support
- service exposed in HA to start and stop the voice assistant from another device/trigger
- visual feedback of the wake word listening/audio recording/success/error status via the satellite LEDs
- visual feedback on the tablet display
- uses touch control on the satellite for toggle wake word activation with long touch, and start/stop listening when wake word detection is off with short touch.

## Pre-requisites

- Home Assistant 2023.11.3 or newer
- A voice assistant [configured in HA](https://my.home-assistant.io/redirect/voice_assistants/) with STT and TTS in a language of your choice
- ESPHome 2023.11.6 or newer

## Instructions
- Install Fully kiosk browser on android tablet and Fully Kiosk Browser integration on Home Assistant. The fully kiosk media player of android tablet will be used to stream aduio tts responses.
- Install Browser Mod integration with HACS. The browser mod media player of android tablet will be used to stream video files awake.mp4 - whtn wake word is detected, and no_sound_speech.mp4 - when audio tts is streamed.
- Mount the esp32 satellite as in the diagram or, if you have already done one, modify the microphone L/R pin to be connected to a digital pin which is then added in code to mute_pin.
![DIAGRAMA ESP32 + MIC + LED+MUTE PIN](https://github.com/relust/HA-Visual-Voice-Assistant/assets/71765276/ef8ceb16-26eb-4534-bd59-bb8b53847da5)

- In the EspHome addon interface to the satellite you are making, copy the code from the ”Visual EspVoice” file and and modify the code with your data.
  
- If you already have your Esp32 satellite setup, make the following changes:
- Add the following lines of code to the substitutions:
```
substitutions:
  awake_video: "media-source://media_source/assist_responses/en/awake.mp4"
  speech_video: "media-source://media_source/assist_responses/en/no_sound_speech.mp4" 
  external_media_player_audio: "media_player.ha_display"
  external_media_player_video: "media_player.ha_display_browser_2"
  display_switch: "switch.ha_display_ecran"
```
- At "microphone" change the channel to "left"
```
microphone:
  - platform: i2s_audio
    id: board_microphone
    adc_type: external
    i2s_din_pin: GPIO16
    pdm: false
    channel: left
```
- To "on_wake_word_detected" add these lines of code
```
  on_wake_word_detected:
    - switch.turn_on: mute_pin
    - delay: 100ms
    - homeassistant.service:  
        service: homeassistant.turn_on
        data: 
          entity_id: ${display_switch}      
    - delay: 100ms
    - homeassistant.service:        
        service: media_player.play_media
        data:
          entity_id: ${external_media_player_video}
          media_content_id: ${awake_video}
          media_content_type: video/mp4
    - delay: 3s      
    - switch.turn_off: mute_pin
```
- If you don't have the possibility to modify the microphone wiring, you can put instead of "switch.turn_on: mute_pin" - "- switch.turn_off: use_wake_word" and instead of "switch.turn_off: mute_pin" - "- voice_assistant.start". It works but stopping and restarting the "use_wake_word" service can cause some problems when listening to the wake word is restarted if the delay times are not set properly.
  ```
  on_wake_word_detected:
    - switch.turn_off: use_wake_word
    - delay: 100ms
    - homeassistant.service:        
        service: media_player.play_media
        data:
          entity_id: ${external_media_player_video}
          media_content_id: ${awake_video}
          media_content_type: video/mp4
    - delay: 3s        
    - voice_assistant.start
  ```
- These lines of code are added to "on_tts_end"
```
  on_tts_end: 
    - delay: 200ms
    - light.turn_on:
        id: led
        blue: 0%
        red: 0%
        green: 100%
        brightness: 60%
        effect: none
    - delay: 200ms
    - homeassistant.service:        
        service: media_player.turn_off
        data:
          entity_id: ${external_media_player_video}
    - delay: 200ms
    - homeassistant.service:        
        service: media_player.play_media
        data:
          entity_id: ${external_media_player_video}
          media_content_id: ${speech_video}
          media_content_type: video/mp4    
    - delay: 600ms
    - homeassistant.service:        
        service: media_player.play_media
        data:
          entity_id: ${external_media_player_audio}
          media_content_id: !lambda return x;
          media_content_type: audio/mpeg 
```
- Add these lines of code to "on_tts_stream_end"
```
  on_tts_stream_end:
    - delay: 800ms
    - homeassistant.service:        
        service: media_player.turn_off
        data:
          entity_id: ${external_media_player_video}
#    - delay: 100ms
#    - script.execute: reset_led 
```
- Then these lines of code are added to "on__end"
```
 on_end:
    - delay: 100ms
    - homeassistant.service:        
        service: media_player.turn_off
        data:
          entity_id: ${external_media_player_video}
```
- If you don't use the "mute_pin" switch, add the wake word listening restart to "on_end"
```
on_end:
    - delay: 2s
    - switch.turn_on: use_wake_word 
``` 
- And at the end, add the mute_pin switch
```
switch:
  - platform: gpio
    pin: 
      number: GPIO17
      inverted: true
    name: MUTE
    id: mute_pin
    restore_mode: RESTORE_DEFAULT_OFF
```
- Press "Save" and "Install" on EspHome addon interface.
- Configure EspVoice satellite in "settings/integrations" page of home assistant.
- Check "Allow the device to make Home Assistant service calls" from the "CONFIGURE" button of the Esp32 satellite.
- On share directory of Home Assistant, create a new directory ”voice_assistant” where copy the content of [share/voice_assistant directory](https://github.com/relust/HA-Visual-Voice-Assistant/tree/main/share/voice_assistant) from this github page.
- Copy content of  [configuration.yaml](https://github.com/relust/HA-Visual-Voice-Assistant/blob/main/configuration.yaml) to configuration.yaml directory of Home Assistant to make the shell services to run "random.sh" and change language scripts from share/voice_assistant directory.
- Copy content of  [automation.yaml](https://github.com/relust/HA-Visual-Voice-Assistant/blob/main/automation.yaml) and make the necessary changes according to your configuration to make automations for change video responses when wake word is detected and, optionally, to change assistants.
- Restart Home Assistant
- On Developer Tools/services page tape "shell_command.random_responses" and CALL SERVICE and check if the script is executed.
- On "Settings/automations" page search "Assist change language" automation and and check if the automation and check if the automation is good and is executed when the wake word is detected.
