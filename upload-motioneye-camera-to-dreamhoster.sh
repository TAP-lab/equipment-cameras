#!/bin/bash
# These are hardcoded configuration. Change them if need be
AUTH_KEY=""
BASE_DIR=""
ENDPOINT=""

usage() {
    echo "Usage: upload-motioneye-camera-to-dreamhoster.sh <CAMERA_NAME> [MINIMUM_UPLOAD_INTERVAL]"
    echo "  CAMERA_NAME: Name of the camera"
    echo "  MINIMUM_UPLOAD_INTERVAL: Image must be newer than last uploaded by this in seconds (optional, defaults to 60)"
    exit 1
}

# Check if the number of arguments provided is correct
if [ "$#" -lt 1 ]; then
    usage
fi

CAMERA_NAME="$1"
MINIMUM_UPLOAD_INTERVAL="${2:-60}"
CAMERA_DIR="$BASE_DIR/$CAMERA_NAME"
IMAGE_PATH="$CAMERA_DIR/image.jpg"
LOG_PATH="$CAMERA_DIR/upload.log"
LOCKFILE="$CAMERA_DIR/lock"

# Check if the file exists
if [ ! -e "$IMAGE_PATH" ]; then
    echo "Error: File to upload '$IMAGE_PATH' does not exist." | tee -a "$LOG_PATH"
    exit 1
fi

if [ -e "$LOCKFILE" ]; then
    echo "$LOCKFILE already exists"
    exit 1  # already running
fi

touch "$LOCKFILE"

IMAGE_TIMESTAMP=$(stat -c "%Y" "$IMAGE_PATH")  # gives you UNIX time in seconds
LAST_UPLOADED=`cat "$CAMERA_DIR/last_uploaded_at" 2>/dev/null`  # or blank if doesnt exist
DIFFERENCE=$((IMAGE_TIMESTAMP - LAST_UPLOADED))

# Check if the time difference is greater than MINIMUM_UPLOAD_INTERVAL seconds
if [ $DIFFERENCE -gt $MINIMUM_UPLOAD_INTERVAL ]; then
    echo "=====================" | tee -a "$LOG_PATH"
    date | tee -a "$LOG_PATH"
    echo "Last image updated at: $(date -d @"$LAST_UPLOADED" "+%Y-%m-%d %H:%M:%S")" | tee -a "$LOG_PATH"
    echo "Current image updated at: $(date -d @"$IMAGE_TIMESTAMP" "+%Y-%m-%d %H:%M:%S")" | tee -a "$LOG_PATH"
    # proceed with upload
    curl -X POST -F "image=@$IMAGE_PATH" -F "key=$AUTH_KEY" -F "dir=$CAMERA_NAME" "$ENDPOINT" --connect-timeout 10 2>&1 | tee -a "$LOG_PATH"
    if [ $? -eq 0 ]; then
        echo "$IMAGE_PATH uploaded."
        echo $IMAGE_TIMESTAMP > "$CAMERA_DIR/last_uploaded_at"
    fi
fi

rm -f "$LOCKFILE"
