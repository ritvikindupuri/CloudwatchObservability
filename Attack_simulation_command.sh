#!/bin/bash

# ==============================================================================
# Script Name: simulation_command.sh
# Description: Triggers the AWS Lambda function to generate simulated IAM security events.
# Usage: ./simulation_command.sh
# ==============================================================================

# 1. 'aws lambda invoke' is the primary command to trigger a function.

# 2. '--function-name' dynamically constructs the target function name:
#    - $(aws sts get-caller-identity ...): Fetches the current 12-digit AWS Account ID.
#    - '-generate-security-events': Appends the suffix to match the deployed function name.

# 3. 'response.json' saves the synchronous execution result to a local file.

# 4. '&& cat response.json' prints the output immediately for verification.

echo "Triggering security event simulation..."

aws lambda invoke \
    --function-name $(aws sts get-caller-identity --query Account --output text)-generate-security-events \
    response.json && cat response.json && echo

echo "Simulation complete. Metrics should appear in CloudWatch shortly."
