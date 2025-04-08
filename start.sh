#!/bin/bash
# Run a Minecraft server in a screen called Caves
screen -dmS Caves
screen -S Caves -p 0 -X stuff "java -Xmx6G -Xms6G -jar /home/asdf/fabric/server.jar nogui\n"