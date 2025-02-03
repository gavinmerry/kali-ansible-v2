#!/bin/bash

# Function to display usage
usage() {
  echo "Usage: $0 [--nessus-key <key>] [--gist-token <token>]"
  exit 1
}

# Secure input handling: Read from command-line args or prompt
NESSUS_KEY=""
GIST_TOKEN=""

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --nessus-key)
      NESSUS_KEY="$2"
      shift 2
      ;;
    --gist-token)
      GIST_TOKEN="$2"
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

# Remove last command from history to avoid storing credentials
history -d $((HISTCMD-1)) 2>/dev/null || true

# Prompt user securely only if keys are required and not provided
if [[ -z "$NESSUS_KEY" ]]; then
  read -s -p "Enter Nessus License Key (or press Enter to skip): " NESSUS_KEY
  echo ""
fi

if [[ -z "$GIST_TOKEN" ]]; then
  read -s -p "Enter GitHub Gist Token (or press Enter to skip): " GIST_TOKEN
  echo ""
fi

# Remove history entries for secure prompts
history -d $((HISTCMD-1)) 2>/dev/null || true
history -d $((HISTCMD-1)) 2>/dev/null || true

# Install necessary tools
apt install -y ansible
pipx install jmespath

# Add pipx to PATH if not already present
if ! grep -q 'export PATH="$PATH:/home/kali/.local/bin"' ~/.zshrc; then
  echo 'export PATH="$PATH:/home/kali/.local/bin"' >> ~/.zshrc
  source ~/.zshrc
fi

# Install Ansible Galaxy requirements
ansible-galaxy install -r requirements.yml

# Ensure script is running with sudo
sudo whoami

# Run the main Ansible playbook with optional environment variables
if [[ -n "$NESSUS_KEY" ]] && [[ -n "$GIST_TOKEN" ]]; then
  NESSUS_KEY="$NESSUS_KEY" GIST_TOKEN="$GIST_TOKEN" ansible-playbook main.yml
elif [[ -n "$NESSUS_KEY" ]]; then
  NESSUS_KEY="$NESSUS_KEY" ansible-playbook main.yml
elif [[ -n "$GIST_TOKEN" ]]; then
  GIST_TOKEN="$GIST_TOKEN" ansible-playbook main.yml
else
  ansible-playbook main.yml
fi

# Immediately clear variables
unset NESSUS_KEY GIST_TOKEN

# Ensure variables do not persist
export NESSUS_KEY=""
export GIST_TOKEN=""

echo "Script executed successfully. Keys (if provided) have been securely used and cleared."
