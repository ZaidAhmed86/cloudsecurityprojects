#!/usr/bin/env python3

"""
AWS Prowler Output Analysis Script
===================================

Purpose: Parse and analyze Prowler JSON output to extract, categorize, and 
         prioritize security findings.

Tool: Prowler v5.19.0
Output Format: ASFF (AWS Security Findings Format)

Usage:
    python parse-results.py                          # Summary statistics
    python parse-results.py --severity               # By severity level
    python parse-results.py --status                 # By pass/fail
    python parse-results.py --unique-critical        # Unique CRITICAL issues
    python parse-results.py --unique-high            # Unique HIGH issues
    python parse-results.py --unique-medium          # Unique MEDIUM issues
    python parse-results.py --unique-low             # Unique LOW issues
    python parse-results.py --critical-detail        # Detailed CRITICAL findings
    python parse-results.py --high-detail N          # First N HIGH findings in detail

Author: Cloud Security Audit
Date: February 2026
"""

import json
import sys
from collections import defaultdict
from pathlib import Path

# ============================================================================
# Configuration
# ============================================================================

PROWLER_OUTPUT_FILE = "prowler-output/prowler-output-621715857254-20260209093927.asff.json"

SEVERITY_LEVELS = ["CRITICAL", "HIGH", "MEDIUM", "LOW", "INFORMATIONAL"]

# ============================================================================
# Utility Functions
# ============================================================================

def load_findings(filepath):
    """Load Prowler JSON output file."""
    try:
        with open(filepath, 'r') as f:
            data = json.load(f)
        # Handle both list and dict formats
        findings = data if isinstance(data, list) else data.get('Findings', [])
        return findings
    except FileNotFoundError:
        print(f"Error: File not found: {filepath}")
        sys.exit(1)
    except json.JSONDecodeError:
        print(f"Error: Invalid JSON in {filepath}")
        sys.exit(1)

def filter_by_severity(findings, severity):
    """Filter findings by severity level."""
    return [f for f in findings if f.get('Severity', {}).get('Label') == severity]

def filter_by_status(findings, status):
    """Filter findings by compliance status (PASSED/FAILED)."""
    return [f for f in findings if f.get('Compliance', {}).get('Status') == status]

def get_unique_findings(findings):
    """Group findings by title to identify unique issue types."""
    unique = {}
    for f in findings:
        title = f.get('Title', 'Unknown')
        status = f.get('Compliance', {}).get('Status', 'Unknown')
        if title not in unique:
            unique[title] = {'count': 0, 'status': status, 'example': f}
        unique[title]['count'] += 1
    return unique

# ============================================================================
# Analysis Functions
# ============================================================================

def summary_statistics(findings):
    """Print overall statistics."""
    print("\n" + "="*70)
    print("PROWLER AUDIT SUMMARY".center(70))
    print("="*70 + "\n")
    
    total = len(findings)
    passed = len(filter_by_status(findings, "PASSED"))
    failed = len(filter_by_status(findings, "FAILED"))
    
    print(f"Total Findings: {total}")
    print(f"  ✓ PASSED: {passed} ({passed/total*100:.1f}%)")
    print(f"  ✗ FAILED: {failed} ({failed/total*100:.1f}%)")
    print()
    
    for severity in SEVERITY_LEVELS:
        count = len(filter_by_severity(findings, severity))
        print(f"{severity:15} Findings: {count}")

def severity_breakdown(findings):
    """Show breakdown by severity and pass/fail."""
    print("\n" + "="*70)
    print("FINDINGS BY SEVERITY & STATUS".center(70))
    print("="*70 + "\n")
    
    for severity in SEVERITY_LEVELS:
        severity_findings = filter_by_severity(findings, severity)
        if not severity_findings:
            continue
        
        passed = len(filter_by_status(severity_findings, "PASSED"))
        failed = len(filter_by_status(severity_findings, "FAILED"))
        
        print(f"{severity}")
        print(f"  Total: {len(severity_findings)} | PASSED: {passed} | FAILED: {failed}")

def unique_findings_analysis(findings, severity):
    """Show unique issue types for a specific severity."""
    severity_findings = filter_by_severity(findings, severity)
    unique = get_unique_findings(severity_findings)
    
    print(f"\n{'='*70}")
    print(f"UNIQUE {severity} FINDINGS ({len(unique)} unique types)".center(70))
    print("="*70 + "\n")
    
    for i, (title, data) in enumerate(
        sorted(unique.items(), key=lambda x: x[1]['count'], reverse=True), 1
    ):
        print(f"{i}. [{data['count']}x] {title}")
        print(f"   Status: {data['status']}\n")

def detailed_finding(finding, index=None):
    """Print detailed information about a single finding."""
    if index:
        print(f"\n[{index}] {finding.get('Title')}")
    else:
        print(f"\nTitle: {finding.get('Title')}")
    
    print(f"    Status: {finding.get('Compliance', {}).get('Status')}")
    print(f"    Severity: {finding.get('Severity', {}).get('Label')}")
    print(f"    Resource: {finding.get('Resources', [{}])[0].get('Id', 'N/A')}")
    print(f"    Description: {finding.get('Description', 'N/A')}")

def critical_findings_detail(findings):
    """Show all CRITICAL findings with details."""
    critical = filter_by_severity(findings, "CRITICAL")
    
    print(f"\n{'='*70}")
    print(f"CRITICAL FINDINGS - DETAILED VIEW ({len(critical)} total)".center(70))
    print("="*70)
    
    for i, finding in enumerate(critical, 1):
        detailed_finding(finding, i)

def high_findings_sample(findings, num=5):
    """Show first N HIGH findings with details."""
    high = filter_by_severity(findings, "HIGH")
    
    print(f"\n{'='*70}")
    print(f"HIGH FINDINGS - SAMPLE ({num} of {len(high)})".center(70))
    print("="*70)
    
    for i, finding in enumerate(high[:num], 1):
        detailed_finding(finding, i)

def failures_by_severity(findings):
    """Show actual FAILED findings by severity."""
    print(f"\n{'='*70}")
    print(f"ACTUAL FAILURES BY SEVERITY".center(70))
    print("="*70 + "\n")
    
    for severity in SEVERITY_LEVELS:
        severity_findings = filter_by_severity(findings, severity)
        failed = len(filter_by_status(severity_findings, "FAILED"))
        print(f"{severity:15} FAILED: {failed}")

# ============================================================================
# Command Line Interface
# ============================================================================

def print_help():
    """Print usage information."""
    print(__doc__)

def main():
    """Main execution."""
    findings = load_findings(PROWLER_OUTPUT_FILE)
    
    # Default: summary
    if len(sys.argv) < 2:
        summary_statistics(findings)
        severity_breakdown(findings)
        failures_by_severity(findings)
        return
    
    # Parse command line arguments
    command = sys.argv[1].lower()
    
    if command == "--help" or command == "-h":
        print_help()
    
    elif command == "--summary":
        summary_statistics(findings)
    
    elif command == "--severity":
        severity_breakdown(findings)
    
    elif command == "--status":
        failures_by_severity(findings)
    
    elif command == "--unique-critical":
        unique_findings_analysis(findings, "CRITICAL")
    
    elif command == "--unique-high":
        unique_findings_analysis(findings, "HIGH")
    
    elif command == "--unique-medium":
        unique_findings_analysis(findings, "MEDIUM")
    
    elif command == "--unique-low":
        unique_findings_analysis(findings, "LOW")
    
    elif command == "--critical-detail":
        critical_findings_detail(findings)
    
    elif command == "--high-detail":
        num = int(sys.argv[2]) if len(sys.argv) > 2 else 5
        high_findings_sample(findings, num)
    
    elif command == "--all":
        summary_statistics(findings)
        print("\n")
        severity_breakdown(findings)
        print("\n")
        failures_by_severity(findings)
        print("\n")
        unique_findings_analysis(findings, "CRITICAL")
        print("\n")
        unique_findings_analysis(findings, "HIGH")
    
    else:
        print(f"Unknown command: {command}")
        print_help()
        sys.exit(1)

# ============================================================================
# Script Execution
# ============================================================================

if __name__ == "__main__":
    main()