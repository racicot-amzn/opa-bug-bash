#!/bin/bash

# Set the prefix (folder name)
PREFIX="opa-bug-bash/"

# List all objects in the specified prefix
OBJECTS=$(aws s3 ls "s3://$OPA_BUG_BASH_S3_BUCKET/$PREFIX" --recursive --human-readable --summarize | grep "Total Objects" | awk '{print $3}')

# Check if there are any objects to delete
if [ "$OBJECTS" -eq 0 ]; then
    echo "No objects found in the $PREFIX folder."
    exit 0
fi

# Prompt for confirmation
read -p "Are you sure you want to delete $OBJECTS objects from the $PREFIX folder in the $BUCKET_NAME bucket? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborting."
    exit 1
fi

# Delete objects
aws s3 rm "s3://$OPA_BUG_BASH_S3_BUCKET/$PREFIX" --recursive

# Check the exit status
if [ $? -eq 0 ]; then
    echo "Objects deleted successfully."
else
    echo "Failed to delete objects."
fi