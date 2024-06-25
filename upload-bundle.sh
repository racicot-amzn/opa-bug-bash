#!/bin/bash

# Define the usage function
usage() {
    echo "Usage: $0 --dir <dir_name> --bucket <s3_bucket_name> --result-query <result_query> --hook-arn <hook_arn>"
    exit 1
}

# Initialize variables
dir_name=""
s3_bucket_name=""
result_query=""
hook_arn=""

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dir)
            dir_name="$2"
            shift 2
            ;;
        --bucket)
            s3_bucket_name="$2"
            shift 2
            ;;
        --result-query)
            result_query="$2"
            shift 2
            ;;
        --hook-arn)
            hook_arn="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            usage
            ;;
    esac
done

# Check if required arguments are provided
if [[ -z "$dir_name" || -z "$s3_bucket_name" || -z "$result_query" ]]; then
    echo "Error: All arguments (--dir, --bucket, --result-query) are required."
    usage
fi

bundle_file_name="$dir_name.tar.gz"

# Build the OPA file
opa_build_output="$(opa build -b $dir_name -o $bundle_file_name)"

# Check if the build was successful
if [ $? -ne 0 ]; then
    echo "Error: opa build failed for $dir_name"
    echo "$opa_build_output"
    exit 1
fi

# Upload the tar.gz file to S3
aws s3 cp "$bundle_file_name" "s3://$s3_bucket_name/opa-bug-bash/$bundle_file_name"

# Check if the upload was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to upload $tar_gz_file to s3://$s3_bucket_name/opa-bug-bash/$bundle_file_name"
    exit 1
fi

# Output the S3 URI of the uploaded object
s3_uri="s3://$s3_bucket_name/opa-bug-bash/$bundle_file_name"

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

aws cloudformation set-type-configuration --configuration file://typeConfiguration.json --type-arn $hook_arn --region us-east-1  