#!/bin/bash

# ============================================================================
# AWS Security Audit - Prowler Execution Script
# ============================================================================
# 
# Purpose: Execute Prowler security scanner against AWS account
# Tool: Prowler v5.19.0
# Output: JSON (ASFF format) + HTML reports
#
# Usage:
#   ./run-prowler.sh
#   or (on Windows PowerShell):
#   docker run --rm -e AWS_ACCESS_KEY_ID=$env:AWS_ACCESS_KEY_ID ...
#
# ============================================================================

# Configuration
REGION="us-east-1"
OUTPUT_DIR="./prowler-output"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DOCKER_IMAGE="toniblyx/prowler:latest"

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "=========================================="
echo "AWS Security Audit - Prowler Scanner"
echo "=========================================="
echo "Start Time: $(date)"
echo "Region: $REGION"
echo "Output Directory: $OUTPUT_DIR"
echo "=========================================="

# Option 1: Linux/Mac bash execution
# Uncomment and use if running on Linux/Mac with Docker

docker run --rm \
  -e AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
  -e AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
  -e AWS_DEFAULT_REGION="$REGION" \
  -v "$OUTPUT_DIR:/tmp/prowler" \
  "$DOCKER_IMAGE" \
  -p aws \
  --output-formats json-asff html \
  -o /tmp/prowler

# ============================================================================
# WINDOWS POWERSHELL EQUIVALENT:
# ============================================================================
#
# docker run --rm `
#   -e AWS_ACCESS_KEY_ID=$env:AWS_ACCESS_KEY_ID `
#   -e AWS_SECRET_ACCESS_KEY=$env:AWS_SECRET_ACCESS_KEY `
#   -e AWS_DEFAULT_REGION=$env:AWS_DEFAULT_REGION `
#   toniblyx/prowler:latest `
#   -p aws `
#   --output-formats json-asff html
#
# ============================================================================

echo ""
echo "=========================================="
echo "Scan Completed"
echo "End Time: $(date)"
echo "=========================================="
echo ""
echo "Output Files:"
ls -lh "$OUTPUT_DIR/"
echo ""
echo "Next Steps:"
echo "1. Review HTML report: open prowler-output/*.html"
echo "2. Analyze JSON output: python parse-results.py"
echo "3. Generate analysis: python parse-results.py --detailed"