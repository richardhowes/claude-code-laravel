#!/bin/bash

# Claude Code Hook Script for Crono
# This script sends session transcripts to your Crono dashboard
#
# Installation:
# 1. Copy this entire script
# 2. Go to Claude Code settings by running /hooks
# 3. Select "Stop" hook event
# 4. Add a new hook with this script as the command
#
# The script will run after each Claude Code session ends

# Configuration
API_TOKEN=""
API_URL="https://usecrono.com/api/transcripts"

# Read JSON input from stdin
json_input=$(cat)

# Extract data from JSON
session_id=$(echo "$json_input" | jq -r '.session_id')
transcript_path=$(echo "$json_input" | jq -r '.transcript_path')
stop_hook_active=$(echo "$json_input" | jq -r '.stop_hook_active')

# Expand tilde in path
transcript_path="${transcript_path/#\~/$HOME}"

# Check if transcript file exists
if [ ! -f "$transcript_path" ]; then
    # The current claude code hook system has a bug where the transcript path
    # points to a file that doesn't exist if a session is reused / cleared.
    # In this case, search inside the base path of the transcript path for a file
    # that contains the session_id
    transcript_path="${transcript_path%/*}"
    transcript_path=$(find "$transcript_path" -type f -exec grep -l "$session_id" {} + | head -n1)

    if [ ! -f "$transcript_path" ]; then
        echo "Error: Transcript file not found at $transcript_path" >&2
        exit 1
    fi
fi

# Create a temporary file for the compressed transcript
temp_file=$(mktemp)
trap "rm -f $temp_file" EXIT

# Compress the transcript file with gzip
gzip -c "$transcript_path" > "$temp_file"

# Send to API as multipart form data with gzip compression
response=$(curl -s -w "\n%{http_code}" -X POST \
    -H "Authorization: Bearer $API_TOKEN" \
    -H "Content-Encoding: gzip" \
    -F "transcript=@$temp_file;type=application/gzip" \
    -F "session_id=$session_id" \
    -F "stop_hook_active=$stop_hook_active" \
    "$API_URL")

# Extract HTTP status code
http_code=$(echo "$response" | tail -n1)
response_body=$(echo "$response" | head -n-1)

# Check response
if [ "$http_code" -eq 200 ] || [ "$http_code" -eq 201 ]; then
    echo "Session data sent successfully to Crono"
    exit 0
else
    echo "Failed to send session data. HTTP status: $http_code" >&2
    echo "Response: $response_body" >&2
    exit 1
fi