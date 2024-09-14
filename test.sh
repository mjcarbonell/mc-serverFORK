#!/usr/bin/env bash

set_world_folder() {
    WORLD_PATH="/world"

    if [ -d "$WORLD_PATH" ]; then
        if [ ! -f server.properties ]; then
            echo "Creating server.properties file..."
            echo "level-name=$WORLD_PATH" > server.properties
        else
            echo "Setting level-name in server.properties..."
            if grep -q "level-name=" server.properties; then
                sed -i "s|level-name=.*|level-name=$WORLD_PATH|" server.properties
            else
                echo "level-name=$WORLD_PATH" >> server.properties
            fi
        fi
        echo "World folder found, configured to load from $WORLD_PATH"
    else
        echo "World folder does not exist. Skipping world loading configuration."
    fi
}
set_world_folder