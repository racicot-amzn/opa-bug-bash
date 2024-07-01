#!/bin/bash

# Set the prefix (folder name)
PREFIX="opa-bug-bash/"

# List all objects in the specified prefix
OBJECTS=$(aws s3 ls "s3://$OPA_BUG_BASH_S3_BUCKET/$PREFIX" --recursive --human-readable)

# Check if there are any objects to delete
if [ -z "$OBJECTS" ]; then
    echo "No objects found in the $PREFIX folder."
    exit 0
fi

# Print the list of objects to be deleted
echo "The following objects will be deleted from the $PREFIX folder in the $OPA_BUG_BASH_S3_BUCKET bucket:"
echo "$OBJECTS"

# Prompt for confirmation
read -p "Are you sure you want to delete these objects? (y/n) " -n 1 -r
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

echo "Disabling the hook..."

# Define the JSON structure with placeholders
type_config=$(cat << EOF
{
    "CloudFormationConfiguration": {
        "HookConfiguration": {
            "TargetStacks": "NONE",
            "Properties": {
                "bundleLocation": "$s3_uri",
                "resultQuery": "$result_query"
            },
            "FailureMode": "WARN"
        }
    }
}
EOF
)

# Write the output to a new file
echo "$type_config" > typeConfiguration.json

aws cloudformation set-type-configuration --configuration file://typeConfiguration.json --type-arn $OPA_BUG_BUSH_HOOK_ARN --region us-east-1  