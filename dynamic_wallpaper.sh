#!/bin/bash

# Directory containing the text files
WALLPAPERS_DIR="$HOME/Documents/dynamic-wallpapers"

# Directory to store generated wallpapers
OUTPUT_DIR="$HOME/.cache/dynamic-wallpapers"

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Log file to track the last run date
LOG_FILE="$HOME/.cache/wallpaper_log.txt"

# Get the current date
CURRENT_DATE=$(date +%Y-%m-%d)

# Check if the script has already run today
if grep -q "$CURRENT_DATE" "$LOG_FILE"; then
    echo "Script has already run today, therefore the wallpaper displayed will not change!"
    exit 0
fi

# Select a random text file from the directory
RANDOM_TEXT_FILE=$(find "$WALLPAPERS_DIR" -type f -name "*.txt" | shuf -n 1)

# Extract the text from the file
CITATION=$(cat "$RANDOM_TEXT_FILE")

# Define the output image path with a unique name based on the current timestamp
OUTPUT_IMAGE="$OUTPUT_DIR/wallpaper_$CURRENT_DATE.png"

# Get screen dimensions
SCREEN_WIDTH=$(xdpyinfo | awk '/dimensions:/ {print $2}' | cut -d'x' -f1)
SCREEN_HEIGHT=$(xdpyinfo | awk '/dimensions:/ {print $2}' | cut -d'x' -f2)

# Define the margin (for example, 20 pixels)
MARGIN=20

# Calculate the text width by subtracting the margin from the screen width
TEXT_WIDTH=$((SCREEN_WIDTH - 2 * MARGIN))


# Create an image with the citation taking into account potential text overflow
convert -size ${SCREEN_WIDTH}x${SCREEN_HEIGHT} xc:black -gravity center \
    	-font Ubuntu -pointsize 36 -fill white \
	    -annotate +0+0 "$(
        	echo "$CITATION" |
        	sed -E 's/(.{1,'$((SCREEN_WIDTH / 20))'})( |\$|\r|\n|,|!|\?|\.|$)/\1\n/g' |
        	sed 's/'\''/\\x27/g' |
        	sed 's/"/\\"/g'
	        )" \
	        "$OUTPUT_IMAGE"


# Check if the image was created successfully
if [ -f "$OUTPUT_IMAGE" ]; then
    # Set the generated image as wallpaper
    feh --bg-scale "$OUTPUT_IMAGE"
    
    # Log the date of this run
    echo "$CURRENT_DATE" > "$LOG_FILE"
else
    echo "Failed to create the wallpaper image."
fi
