#!/bin/bash

VERSION="1.0"
DRY_RUN=false
LOG_FILE="logs/organizer.log"
CONFIG_FILE="config/organizer.conf"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file not found."
    exit 1
fi

source "$CONFIG_FILE"

get_category() {

    for ext in $IMAGES; do
        if [ "$extension" = "$ext" ]; then
            echo "Images"
            return
        fi
    done

    for ext in $DOCUMENTS; do
        if [ "$extension" = "$ext" ]; then
            echo "Documents"
            return
        fi
    done

    for ext in $VIDEOS; do
        if [ "$extension" = "$ext" ]; then
            echo "Videos"
            return
        fi
    done

    for ext in $MUSIC; do
        if [ "$extension" = "$ext" ]; then
            echo "Music"
            return
        fi
    done

    for ext in $ARCHIVES; do
        if [ "$extension" = "$ext" ]; then
            echo "Archives"
            return
        fi
    done

    for ext in $SCRIPTS; do
        if [ "$extension" = "$ext" ]; then
            echo "Scripts"
            return
        fi
    done

    echo "Others"
}




log_action() {
    local action="$1"
    local filename="$2"
    local destination="$3"

    echo "$(date '+%Y-%m-%d %H:%M:%S') | $action | $filename | $destination" >> "$LOG_FILE"
}

show_help() {
    echo "=========================================="
    echo "        LINUX FILE ORGANIZER"
    echo "=========================================="
    echo ""
    echo "Usage:"
    echo "  ./organizer.sh [OPTION]"
    echo ""
    echo "Options:"
    echo "  --help       Show help information"
    echo "  --version    Show program version"
    echo "  --dry-run    Preview changes without moving files"
    echo ""
    echo "Description:"
    echo "  Automatically organizes files into"
    echo "  folders based on their extensions."
    echo ""
}

case "$1" in

    --help)
        show_help
        exit 0
        ;;

    --version)
        echo "Linux File Organizer v$VERSION"
        exit 0
        ;;

    --dry-run)
        DRY_RUN=true
        ;;

    "")
        # No option provided
        ;;

    *)
        echo "Unknown option: $1"
        echo "Use './organizer.sh --help' for usage information."
        exit 1
        ;;

esac

# ==========================================
# Linux File Organizer
# ==========================================

echo "=========================================="
echo "        LINUX FILE ORGANIZER"
echo "=========================================="

# Ask user for directory
read -p "Enter directory path to organize: " TARGET_DIR

# Check whether directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory does not exist."
    exit 1
fi

echo ""
echo "Selected directory: $TARGET_DIR"
echo "Directory is valid."

if [ "$DRY_RUN" = true ]; then
    echo ""
    echo "DRY RUN MODE"
    echo "No files will be moved."
    echo "------------------------------------------"
fi

# Initialize file counters
images_count=0
documents_count=0
videos_count=0
music_count=0
archives_count=0
scripts_count=0
others_count=0
total_count=0
files_found=0

echo ""
echo "Scanning files..."
echo "------------------------------------------"

for file in "$TARGET_DIR"/*; do

    if [ -f "$file" ]; then

        filename=$(basename "$file")
       extension="${filename##*.}"
extension=$(echo "$extension" | tr '[:upper:]' '[:lower:]')
category=$(get_category)

                echo "File: $filename"
        echo "Extension: .$extension"

      

# Create category folder if it does not exist
category_dir="$TARGET_DIR/$category"

if [ ! -d "$category_dir" ]; then

    if [ "$DRY_RUN" = true ]; then
        echo "Would create folder: $category/"
    else
        mkdir -p "$category_dir"
        echo "Created folder: $category/"
    fi

fi
echo "Category: $category"


# Update category counter
case "$category" in
    Images)
        images_count=$((images_count + 1))
        ;;
    Documents)
        documents_count=$((documents_count + 1))
        ;;
    Videos)
        videos_count=$((videos_count + 1))
        ;;
    Music)
        music_count=$((music_count + 1))
        ;;
    Archives)
        archives_count=$((archives_count + 1))
        ;;
    Scripts)
        scripts_count=$((scripts_count + 1))
        ;;
    Others)
        others_count=$((others_count + 1))
        ;;
esac

total_count=$((total_count + 1))
files_found=$((files_found + 1))

echo ""

# Destination path
# Check for duplicate filename
destination="$category_dir/$filename"

if [ -e "$destination" ]; then

    base_name="${filename%.*}"
    extension="${filename##*.}"
    counter=1

    while [ -e "$category_dir/${base_name}_${counter}.${extension}" ]; do
        counter=$((counter + 1))
    done

    destination="$category_dir/${base_name}_${counter}.${extension}"

   if [ "$DRY_RUN" = true ]; then

    echo "Duplicate found."
    echo "Would move: $filename → $(basename "$destination")"
    log_action "DRY-RUN-DUPLICATE" "$filename" "$(basename "$destination")"

else

    mv "$file" "$destination"

    echo "Duplicate found."
    echo "Moved: $filename → $(basename "$destination")"

    log_action "DUPLICATE" "$filename" "$(basename "$destination")"

fi

else

   if [ "$DRY_RUN" = true ]; then

    echo "Would move: $filename → $category/"
    log_action "DRY-RUN" "$filename" "$category/"

else

    mv "$file" "$destination"
    echo "Moved: $filename → $category/"
    log_action "MOVED" "$filename" "$category/"

fi

fi


echo ""


    fi

done

if [ "$files_found" -eq 0 ]; then
    echo ""
    echo "No files found in the selected directory."
    echo "Nothing to organize."
    exit 0
fi

echo ""
echo "=========================================="
echo "       ORGANIZATION COMPLETE"
echo "=========================================="
echo ""
printf "%-15s : %d\n" "Images" "$images_count"
printf "%-15s : %d\n" "Documents" "$documents_count"
printf "%-15s : %d\n" "Videos" "$videos_count"
printf "%-15s : %d\n" "Music" "$music_count"
printf "%-15s : %d\n" "Archives" "$archives_count"
printf "%-15s : %d\n" "Scripts" "$scripts_count"
printf "%-15s : %d\n" "Others" "$others_count"
echo ""
echo "------------------------------------------"
printf "%-15s : %d\n" "Total Files" "$total_count"
echo "=========================================="

