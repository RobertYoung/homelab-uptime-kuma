# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Single-host Ansible project deploying Uptime Kuma via Docker Compose on `uptime-kuma.local.iamrobertyoung.co.uk`. Secrets are stored in AWS SSM Parameter Store.

## Key Commands

All commands require AWS credentials via aws-vault for SSM parameter lookups.

```bash
# Test connectivity
aws-vault exec iamrobertyoung:home-assistant-production:p -- ansible uptime_kuma -m ping

# Run full playbook
aws-vault exec iamrobertyoung:home-assistant-production:p -- ansible-playbook playbooks/site.yml

# Run specific role only
aws-vault exec iamrobertyoung:home-assistant-production:p -- ansible-playbook playbooks/site.yml --tags uptime-kuma

# Install external dependencies (roles)
aws-vault exec iamrobertyoung:home-assistant-production:p -- ansible-galaxy install -r requirements.yml -p .roles

# Create new custom role
aws-vault exec iamrobertyoung:home-assistant-production:p -- ansible-galaxy init roles/role_name
```

## Architecture

### Deployment Stack
The main playbook (`playbooks/site.yml`) applies these roles in order:
1. `configure-system` - Base system configuration
2. `shell` - Shell setup for users (noxious, root)
3. `docker` - Docker installation
4. `telegraf` - Metrics collection to InfluxDB
5. `step-ca-client` - TLS certificates from Step CA
6. `syslog` - Syslog configuration
7. `uptime-kuma` - Uptime Kuma deployment (Docker Compose with systemd service)

### Uptime Kuma Role Structure
The `roles/uptime-kuma` role deploys Uptime Kuma via Docker Compose:
- `tasks/main.yml` - Main task orchestration
- `defaults/main.yml` - Default variables
- `templates/` - Jinja2 templates for configuration
- `handlers/main.yml` - Service handlers

Installation directory: `/opt/uptime-kuma`

### Secrets Management
Passwords are stored in AWS SSM (region: eu-west-2).
Ansible retrieves them via `lookup('amazon.aws.aws_ssm', ...)`.

### External Dependencies
Dependencies in `requirements.yml` are installed to `.roles/` (gitignored):
- `configure-system` role from GitHub
- `shell` role from GitHub
- `docker` role from GitHub
- `telegraf` role from GitHub
- `step-ca-client` role from GitHub
- `syslog` role from GitHub

### Available Tags
Run specific parts with `--tags`: `configure-system`, `shell`, `docker`, `telegraf`, `step-ca-client`, `syslog`, `uptime-kuma`

### Tool Versions (mise.toml)
- ansible 13.1.0
- pipx 1.8.0
- uv 0.9.18
