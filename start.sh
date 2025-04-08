#!/bin/bash
# Run a Minecraft server in a tmux session called Caves

# Change to the Minecraft server directory
cd /home/asdf/fabric || {
    echo "Failed to change to /home/asdf/fabric"
    exit 1
}

# Kill existing tmux session if it exists
tmux has-session -t Caves 2>/dev/null
if [ $? -eq 0 ]; then
    tmux kill-session -t Caves
fi

# Start the server in a new detached tmux session
tmux new-session -d -s Caves "java -Xmx8G -Xms8G -jar /home/asdf/fabric/server.jar nogui"