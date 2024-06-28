#!/bin/bash

usage() {
  echo "Usage: $0 --stack-name <stack-name> --template-body <template-body>"
  exit 1
}

stack_name=""
template_body=""

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --stack-name)
            stack_name="$2"
            shift
            ;;
        --template-body)
            template_body="$2"
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            echo "Usage: $0 --stack-name <stack-name> --template-body <template-body>"
            exit 1
            ;;
    esac
    shift
done

# Check if required arguments are provided
if [ -z "$stack_name" ] || [ -z "$template_body" ]; then
    echo "Usage: $0 --stack-name <stack-name> --template-body <template-body>"
    exit 1
fi

# Create the CloudFormation stack
aws cloudformation create-stack \
    --stack-name "$stack_name" \
    --template-body "file://$template_body" \
    --region us-east-1

echo "Waiting for stack creation to complete..."

# Wait for the stack creation to complete
aws cloudformation wait stack-create-complete --stack-name "$stack_name"

echo "OPA Hook Stack Events:"

# Describe stack events and filter for failed OPA hooks
aws cloudformation describe-stack-events \
    --stack-name "$stack_name" |
    jq '.StackEvents[] | select(.HookType == "AWS::OPA::Hook")'

echo "Deleting stack $stack_name..."

aws cloudformation delete-stack \
    --stack-name "$stack_name"

echo "Waiting for stack deletion to complete..."

aws cloudformation wait stack-delete-complete --stack-name "$stack_name"

echo "Stack deletion completed."
