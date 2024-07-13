#!/bin/bash

# Open the Main.lua file in read mode
while IFS= read -r line; do
    # Check if the current line contains _version
    if [[ $line == *_version* ]]; then
        # Get the current version number from the line
        current_version=$(echo $line | cut -d '"' -f 2)

        # Increment the version number by 1
        new_version=$((current_version + 1))

        # Replace the old version number with the new one in the file
        echo "$line" | sed "s/$current_version/$new_version/g" > media/lua/client/Main.lua
    fi
done < media/lua/client/Main.lua


# Open the mod.info file in read mode
while IFS= read -r line; do
    # Check if the current line contains modversion
    if [[ $line == *modversion* ]]; then
        # Get the current version number from the line
        current_version=$(echo $line | cut -d '"' -f 2)

        # Increment the version number by 1
        new_version=$((current_version + 1))

        # Replace the old version number with the new one in the file
        echo "$line" | sed "s/$current_version/$new_version/g" > mod.info
    fi
done < mod.info