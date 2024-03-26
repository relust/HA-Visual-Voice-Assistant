# HA-Visual-Voice-Assistant

# Introduction

Ever since voice satellites [were introduced](https://www.home-assistant.io/blog/2023/04/27/year-of-the-voice-chapter-2/#composing-voice-assistants) to [Home Assistant](https://www.home-assistant.io/), people wanted to use good microphones and speakers for this purpose, but this is, still, a work in progress.
Through this project I wanted to add to the voice assistant made in Home Assistant a visual image and random personalized responses that are displayed on an google home display or a tablet with browser mod integration.
To achieve this, I will use an esp32 satellite programmed with [ESPHome](https://www.esphome.io/). 

![Rommie_tubnail](https://github.com/relust/HA-Visual-Voice-Assistant/assets/71765276/afee3608-5bfd-4cc1-88f2-278d1601d02c)

![vs240326-001](https://github.com/relust/HA-Visual-Voice-Assistant/assets/71765276/536f8132-3528-4861-ada1-321ff7859fde)


 Here's a video tutorial:

[https://www.youtube.com/watch?v=1bBOoUhnF4A&t=166s](https://www.youtube.com/watch?v=1bBOoUhnF4A&t=166s)

## Features

- wake word, push to talk, on-demand and continuous conversation support
- service exposed in HA to start and stop the voice assistant from another device/trigger
- visual feedback of the wake word listening/audio recording/success/error status via the satellite LEDs
- visual feedback on the tablet display
- changing assistants and language from the graphical interface or with voice commands.
- uses touch control on the satellite for toggle wake word activation with long touch, and start/stop listening when wake word detection is off with short touch.


## Pre-requisites

- Home Assistant 2023.11.3 or newer
- For tablets with browser or Home Assistant companion app, install Browser Mod integration with HACS. 
- A voice assistant [configured in HA](https://my.home-assistant.io/redirect/voice_assistants/) with STT and TTS in a language of your choice
- ESPHome 2023.11.6 or newer

## Instructions

- Mount the esp32 satellite as in the diagram or, if you have already done one, modify the microphone L/R pin to be connected to a digital pin which is then added in code to mute_pin.
![DIAGRAMA ESP32 + MIC + LED+MUTE PIN](https://github.com/relust/HA-Visual-Voice-Assistant/assets/71765276/ef8ceb16-26eb-4534-bd59-bb8b53847da5)

- In the EspHome addon interface to the satellite you are making, copy the code from the ”Visual EspVoice” file and and modify the code with your data.
  
- If you already have your Esp32 satellite setup, make the following changes:
- Add the following lines of code to the substitutions and globals and complete with your data:
```
substitutions:
  external_media_player: "media_player.ha_display_browser"
  browser_id: "ha_display_browser" #android tablet browser_id from browser_mod
  display_switch: "light.ha_display_browser_screen"# android tablet display switch from fully kiosk browser
  gifs_dir: "http://192.168.0.xxx:8123/local/gifs/"
  silent_sound: "media-source://media_source/gifs/5minsilence.wav"
  assistant1: "Jarvis" # the name exactly as it is in the gifs directory without "_speech.gif"
  assistant2: "JarvisEn"
  assistant3: "Roomie"
  assistant4: "Sheila"
  tts_service: "edge_tts"
  tts_language1: "ro-RO-EmilNeural"  #en-US-ChristopherNeural / ro-RO-EmilNeural
  tts_language2: "en-US-ChristopherNeural" #en-US-MichelleNeural / ro-RO-AlinaNeural
  tts_language3: "ro-RO-AlinaNeural" #en-US-JennyNeural / ro-RO-AlinaNeural
  tts_language4: "ro-RO-AlinaNeural" #en-US-JennyNeural / ro-RO-AlinaNeural
  random_messages1: "{{ ['cu ce pot să te ajut', 'spune te rog', 'da, te ascult'] | random }}"  
  random_messages2: "{{ ['how can I help you', 'yes, im listening', 'how can assist you'] | random }}" 
  random_messages3: "{{ ['cu ce pot să te ajut', 'spune te rog', 'da, te ascult'] | random }}"
  random_messages4: "{{ ['cu ce pot să te ajut', 'spune te rog', 'da, te ascult'] | random }}"
globals:
  - id: speech_url
    type: std::string
    restore_value: no
  - id: listen_url
    type: std::string
    restore_value: no
  - id: tts_language
    type: std::string
    restore_value: no
  - id: random_messages
    type: std::string
    restore_value: no
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
    - script.execute: assistant_set
    - switch.turn_on: mute_pin 
    #- switch.turn_off: use_wake_word" #If you don't have the possibility to modify the microphone wiring for mute switch
 #   - delay: 100ms
 #   - homeassistant.service:  
 #       service: homeassistant.turn_on
 #       data: 
 #         entity_id: ${display_switch}      
    - delay: 100ms
    - homeassistant.service:
        service: media_player.play_media      
        data_template:
          entity_id: ${external_media_player}
          media_content_id: !lambda |-
            return "media-source://tts/${tts_service}?message= \"" + id(random_messages) + "\"&language=" + id(tts_language);
          media_content_type: "audio" 
          extra: !lambda |-
            return "{\"metadata\": {\"metadataType\": 3, \"title\": \" \", \"images\": [{\"url\": \"" + id(speech_url) + "\" }]}}";
      
          
    - delay: 100ms
#    - homeassistant.service:
#        service: browser_mod.popup     
#       data_template:
#          entity_id: ${external_media_player}
#          browser_id: ${browser_id}
#          content: !lambda |-
#            return "{\"type\": \"picture\", \"image\": \"" + id(speech_url) + "\"}";
#          style: "--popup-min-width: 800px"



#########  THIS IS FOR GOOGLE HOME SPEAKERS CHIME SOUND #######
#    - if:
#        condition:
#          switch.is_on: google_speaker_status
#        then:
#          - delay: 200ms 
#        else:
#          - delay: 2s
#    - delay: 1300ms             
    - homeassistant.service:
        service: media_player.play_media      
        data_template:
          entity_id: ${external_media_player}
          media_content_id: ${silent_sound}
          media_content_type: "audio"
          extra: !lambda |-
            return "{\"metadata\": {\"metadataType\": 3, \"title\": \" \", \"images\": [{\"url\": \"" + id(listen_url) + "\" }]}}";
    - delay: 100ms
#    - homeassistant.service:
#        service: browser_mod.popup     
#        data_template:
#          entity_id: ${external_media_player}
#          browser_id: ${browser_id}
#          content: !lambda |-
#            return "{\"type\": \"picture\", \"image\": \"" + id(listen_url) + "\"}";
#         style: "--popup-min-width: 800px" 
    - switch.turn_off: mute_pin
    #- voice_assistant.start#If you don't have the possibility to modify the microphone wiring for mute switch
```
- If you don't have the possibility to modify the microphone wiring, you can put instead of "switch.turn_on: mute_pin" - "- switch.turn_off: use_wake_word" and instead of "switch.turn_off: mute_pin" - "- voice_assistant.start". It works but stopping and restarting the "use_wake_word" service can cause some problems when listening to the wake word is restarted if the delay times are not set properly.
- If you use a google display or a google speaker, uncomment section provided that the delay is longer if initially the speaker is turned off and because of this it will play the chime sounds first.
- If you're using a tablet with a browser running the Home Assistant interface or the Home Assistant app, uncomment sections with the browser_mod.popup service and with tablet display turn_on switch.
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
        service: media_player.play_media
        data_template:
          entity_id: ${external_media_player}
          media_content_id: !lambda return x;
          media_content_type: "music"
          extra: !lambda |-
            return "{\"metadata\": {\"metadataType\": 3, \"title\": \" \", \"images\": [{\"url\": \"" + id(speech_url) + "\" }]}}";

#    - delay: 100ms
#    - homeassistant.service:
#        service: browser_mod.popup     
#        data_template:
#         entity_id: ${external_media_player}
#          browser_id: ${browser_id}
#          content: !lambda |-
#            return "{\"type\": \"picture\", \"image\": \"" + id(speech_url) + "\"}";
#          style: "--popup-min-width: 800px"
```
- If you're using a tablet with a browser running the Home Assistant interface or the Home Assistant app, uncomment sections with the browser_mod.popup service
- If you're using a tablet with a browser running the Home Assistant interface or the Home Assistant app, add these lines of code to "on_tts_stream_end"  with the browser_mod.close_popup service
```
  on_tts_stream_end:
    - delay: 100ms
    - script.execute: reset_led
#    - delay: 100ms
#    - homeassistant.service:
#        service: browser_mod.close_popup     
#        data_template:
#          entity_id: ${external_media_player}
#          browser_id: ${browser_id}
    - delay: 100ms             
    - homeassistant.service:
        service: media_player.play_media      
        data_template:
          entity_id: ${external_media_player}
          media_content_id: ${silent_sound}
          media_content_type: "audio"
          extra: !lambda |-
            return "{\"metadata\": {\"metadataType\": 3, \"title\": \" \", \"images\": [{\"url\": \"" + id(listen_url) + "\" }]}}"; 
```
- Then these lines of code are added to "on__end"
```
 on_end:
    - delay: 100ms
    - script.execute: reset_led
    - delay: 100ms
    - switch.turn_off: mute_pin 
#    - switch.turn_on: use_wake_word # this is if not have mute switch
    - delay: 100ms 
    - homeassistant.service:
        service: browser_mod.close_popup     
        data_template:
          entity_id: ${external_media_player}
          browser_id: ${browser_id}
```
- If you don't use the "mute_pin" switch, uncomment the wake word listening restart to "on_end"

- On script add assistant_set script

 ```
script:  
  - id: assistant_set
    then:    
      - lambda: |-
          std::string selected_language;
          if (id(assistant_select).state == "${assistant1}") {
            selected_language = "${tts_language1}";
          } else if (id(assistant_select).state == "${assistant2}") {
            selected_language = "${tts_language2}";
          } else if (id(assistant_select).state == "${assistant3}") {
            selected_language = "${tts_language3}";
          } else if (id(assistant_select).state == "${assistant4}") {
            selected_language = "${tts_language4}";            
          } else {
            selected_language = "${tts_language1}";
          }
          id(tts_language) = selected_language;

      - lambda: |-
          std::string selected_message;
          if (id(assistant_select).state == "${assistant1}") {
            selected_message = "${random_messages1}";
          } else if (id(assistant_select).state == "${assistant2}") {
            selected_message = "${random_messages2}";
          } else if (id(assistant_select).state == "${assistant3}") {
            selected_message = "${random_messages3}";
          } else if (id(assistant_select).state == "${assistant4}") {
            selected_message = "${random_messages4}";            
          } else {
            selected_message = "${random_messages1}";
          }
          id(random_messages) = selected_message;

      - lambda: |-
          std::string image_url = "${gifs_dir}";
          image_url += id(assistant_select).state;
          image_url += "_speech.gif";
          id(speech_url) = image_url;
      - lambda: |-
          std::string image_url = "${gifs_dir}";
          image_url += id(assistant_select).state;
          image_url += "_listen.gif";
          id(listen_url) = image_url;
```
- Add assistants selector

```
select:
  - platform: template
    id: assistant_select
    name: "Assistant select"
    optimistic: true
    restore_value: true
    options:
      - "${assistant1}"
      - "${assistant2}"
      - "${assistant3}"
      - "${assistant4}"
```
- To the "switch" section add mute switch. This is done by connecting the L/R pin from the microphone to a digital pin. When that pin is powered, the microphone is turned on.
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

- If you use a display or a google speaker, in the switch sectionn, add a virtual switch that we will use in the automation that will transmit to the Esp32 satellite if the google speaker is on or off to adjust the delay for the initial response
 ``` 
switch:
  - platform: template
    name: Google speaker status
    id: google_speaker_status
    optimistic: true
    restore_mode: RESTORE_DEFAULT_ON
 ``` 
- Press "Save" and "Install" on EspHome addon interface.
- Configure EspVoice satellite in "settings/integrations" page of home assistant.
- Check "Allow the device to make Home Assistant service calls" from the "CONFIGURE" button of the Esp32 satellite.
- On local directory of Home Assistant, `/config/www`, create a new directory ”gifs” where copy the content of [www/gifs directory](https://github.com/relust/HA-Visual-Voice-Assistant/tree/main/www/gifs) from this github page.
- Copy content of  [configuration.yaml](https://github.com/relust/HA-Visual-Voice-Assistant/blob/main/configuration.yaml) to configuration.yaml directory of Home Assistant to make the shell services  change assistants scripts from `/config/www/gifs` directory.
- Copy content of  [automation.yaml](https://github.com/relust/HA-Visual-Voice-Assistant/blob/main/automation.yaml) and make the necessary changes according to your configuration to make automations for change assistants and google speaker status.
- Restart Home Assistant.
- On "Settings/automations" page search "Assist Google speaker status" automation and  check if the Esp32 satellite Google speaker status switch is updated when the associated google speaker is turned off or on.
- On "Settings/automations" page search "Assist Change Assistants" automation and check if assistants and pipelines are changed by voice commands.
