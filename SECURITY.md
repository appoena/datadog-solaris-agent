# Security Policy

Appoena takes security seriously.

## Reporting a Vulnerability

Security vulnerabilities must be reported exclusively through the
GitHub repository using the "Security Vulnerability" issue template.

Do not report security issues through email or other channels unless
explicitly requested by Appoena.

Include:

- description of the vulnerability
- affected version(s)
- reproduction steps
- potential impact
- references to CVEs and other relevant links
- suggested mitigation if known
- runtime debug logs
- any other relevant information

## Responsible Disclosure

Users are expected to follow responsible disclosure practices and
must not publicly disclose vulnerabilities until a fix or mitigation
has been released.

## Security Model

The Telemetry Agent:

- operates with minimal privileges
- requires write permissions only within its installation directory
- transmits telemetry only to endpoints configured by the customer
- does not transmit data to Appoena infrastructure