#!/usr/bin/env bash
cd /share/voice_assistant/
filesAwake=(awake_message/*.mp4)
cp "${filesAwake[RANDOM % ${#filesAwake[@]}]}" awake.mp4







