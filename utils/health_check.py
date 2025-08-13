#!/usr/bin/env python3
"""
Utility script to check service health.
Can be extended to monitor multiple services.
"""

import subprocess
import sys

SERVICES = ["sshd", "firewalld", "auditd"]

def check_service(service):
    try:
        status = subprocess.run(
            ["systemctl", "is-active", service],
            capture_output=True,
            text=True
        )
        if status.returncode == 0:
            print(f"[OK] {service} is running.")
        else:
            print(f"[FAIL] {service} is NOT running.")
    except Exception as e:
        print(f"[ERROR] Could not check {service}: {e}")

if __name__ == "__main__":
    print("Starting health check...")
    for svc in SERVICES:
        check_service(svc)