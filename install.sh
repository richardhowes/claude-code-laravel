#!/usr/bin/env bash

# Claude Code Laravel Configuration - Global Installation Script
# This script installs the Laravel-optimized Claude Code configuration globally

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CLAUDE_DIR="$HOME/.claude"
REPO_URL="https://github.com/your-username/claude-code-laravel.git"
BACKUP_DIR="$HOME/.claude-backup-$(date +%Y%m%d-%H%M%S)"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to backup existing configuration
backup_existing() {
    if [[ -d "$CLAUDE_DIR" ]]; then
        print_warning "Existing ~/.claude directory found"
        print_status "Creating backup at $BACKUP_DIR"
        cp -r "$CLAUDE_DIR" "$BACKUP_DIR"
        print_success "Backup created successfully (original preserved)"
    fi
}

# Function to check dependencies
check_dependencies() {
    print_status "Checking dependencies..."
    
    local missing_deps=()
    
    # Check for git
    if ! command_exists git; then
        missing_deps+=("git")
    fi
    
    # Check for curl
    if ! command_exists curl; then
        missing_deps+=("curl")
    fi
    
    # Check for Claude Code CLI (optional but recommended)
    if ! command_exists claude-code; then
        print_warning "Claude Code CLI not found. Install with: brew install claude-code"
    fi
    
    # Check for PHP and Composer (for Laravel development)
    if ! command_exists php; then
        print_warning "PHP not found. Install with: brew install php"
    fi
    
    if ! command_exists composer; then
        print_warning "Composer not found. Install from: https://getcomposer.org/"
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        print_error "Please install missing dependencies and try again"
        exit 1
    fi
    
    print_success "All required dependencies found"
}

# Function to install configuration
install_config() {
    print_status "Installing Claude Code Laravel configuration..."
    
    # Create temporary directory for installation
    local temp_dir="/tmp/claude-install-$$"
    
    # Clone the repository or copy from local
    if [[ -n "${REPO_URL:-}" ]] && [[ "$REPO_URL" != "https://github.com/your-username/claude-code-laravel.git" ]]; then
        print_status "Cloning from $REPO_URL"
        git clone "$REPO_URL" "$temp_dir"
    else
        # For local installation, copy from current directory
        if [[ -f "$(dirname "$0")/CLAUDE.md" ]]; then
            print_status "Installing from local directory"
            cp -r "$(dirname "$0")" "$temp_dir"
            # Remove git files if copying locally
            rm -rf "$temp_dir/.git" 2>/dev/null || true
        else
            print_error "Repository URL not configured and local files not found"
            print_error "Please set REPO_URL or run from the source directory"
            exit 1
        fi
    fi
    
    # Create ~/.claude directory if it doesn't exist
    mkdir -p "$CLAUDE_DIR"
    
    # Copy files from temp directory to ~/.claude, overwriting existing files
    print_status "Copying configuration files..."
    cp -rf "$temp_dir"/* "$CLAUDE_DIR"/
    
    # Clean up temporary directory
    rm -rf "$temp_dir"
    
    print_success "Configuration files installed"
}

# Function to set permissions
set_permissions() {
    print_status "Setting executable permissions for hooks..."
    
    chmod +x "$CLAUDE_DIR"/hooks/*.sh
    
    # Verify permissions
    if [[ -x "$CLAUDE_DIR/hooks/smart-lint.sh" ]]; then
        print_success "Hook permissions set correctly"
    else
        print_error "Failed to set hook permissions"
        exit 1
    fi
}

# Function to verify installation
verify_installation() {
    print_status "Verifying installation..."
    
    local required_files=(
        "CLAUDE.md"
        "settings.json"
        "commands/check.md"
        "commands/next.md"
        "commands/prompt.md"
        "hooks/smart-lint.sh"
        "hooks/smart-test.sh"
        "hooks/common-helpers.sh"
    )
    
    local missing_files=()
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$CLAUDE_DIR/$file" ]]; then
            missing_files+=("$file")
        fi
    done
    
    if [[ ${#missing_files[@]} -gt 0 ]]; then
        print_error "Missing required files: ${missing_files[*]}"
        exit 1
    fi
    
    # Test hook execution
    print_status "Testing hook functionality..."
    if CLAUDE_HOOKS_DEBUG=1 "$CLAUDE_DIR/hooks/smart-lint.sh" --test 2>/dev/null; then
        print_success "Hooks are working correctly"
    else
        print_warning "Hook test failed, but installation completed"
    fi
    
    print_success "Installation verification completed"
}

# Function to add Crono hook to settings.json
add_crono_hook_to_settings() {
    local settings_file="$CLAUDE_DIR/settings.json"
    
    # Check if jq is available for JSON manipulation
    if command_exists jq; then
        # Use jq for cleaner JSON manipulation
        jq '.hooks.Stop = [{"matcher": "", "hooks": [{"type": "command", "command": "~/.claude/hooks/crono.sh"}]}]' "$settings_file" > "$settings_file.tmp" && mv "$settings_file.tmp" "$settings_file"
    elif command_exists python3; then
        # Use Python for JSON manipulation
        python3 -c "
import json
import sys

with open('$settings_file', 'r') as f:
    data = json.load(f)

data['hooks']['Stop'] = [{
    'matcher': '',
    'hooks': [{
        'type': 'command',
        'command': '~/.claude/hooks/crono.sh'
    }]
}]

with open('$settings_file', 'w') as f:
    json.dump(data, f, indent=2)
"
    else
        # Fallback: Create a new settings.json with Crono hook
        cat > "$settings_file" << 'EOF'
{
  "model": "opus",
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/smart-lint.sh"
          },
          {
            "type": "command",
            "command": "~/.claude/hooks/smart-test.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/crono.sh"
          }
        ]
      }
    ]
  }
}
EOF
    fi
}

# Function to configure Crono integration
configure_crono() {
    print_status "Configuring Crono integration (optional)..."
    
    echo ""
    echo -e "${YELLOW}🔗 Crono Integration Setup${NC}"
    echo ""
    echo "Crono allows you to automatically send Claude Code session transcripts"
    echo "to your dashboard for analysis and tracking."
    echo ""
    
    read -p "Would you like to configure Crono integration? (y/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo "To get your API token:"
        echo "1. Visit https://usecrono.com"
        echo "2. Sign up or log in to your account"
        echo "3. Go to your dashboard settings"
        echo "4. Copy your API token"
        echo ""
        
        read -p "Enter your Crono API token: " -r crono_token
        
        if [[ -n "$crono_token" ]]; then
            # Update the crono.sh script with the user's API token
            sed -i.bak "s/API_TOKEN=\"\"/API_TOKEN=\"$crono_token\"/" "$CLAUDE_DIR/hooks/crono.sh"
            rm -f "$CLAUDE_DIR/hooks/crono.sh.bak"
            
            # Add the crono.sh hook to settings.json
            add_crono_hook_to_settings
            
            print_success "Crono integration configured successfully"
            echo ""
            echo "Your session transcripts will now be automatically sent to Crono after each session."
        else
            print_warning "No API token provided, skipping Crono configuration"
        fi
    else
        print_status "Skipping Crono integration"
    fi
}

# Function to create example Laravel project configuration
create_example_config() {
    print_status "Creating example Laravel project configuration..."
    
    local example_dir="$HOME/Desktop/laravel-project-example"
    mkdir -p "$example_dir"
    
    # Copy example configuration files
    cp "$CLAUDE_DIR/hooks/example-claude-hooks-config.sh" "$example_dir/.claude-hooks-config.sh"
    cp "$CLAUDE_DIR/hooks/example-claude-hooks-ignore" "$example_dir/.claude-hooks-ignore"
    
    # Create example composer.json scripts
    cat > "$example_dir/composer-scripts-example.json" << 'EOF'
{
  "scripts": {
    "lint": "phpstan analyse --memory-limit=2G",
    "format": "pint",
    "refactor": "rector process",
    "refactor:annotate": "rector process --dry-run --config=rector-annotate.php",
    "test": "pest"
  }
}
EOF
    
    print_success "Example configuration created at $example_dir"
}

# Function to print usage instructions
print_usage() {
    echo ""
    print_success "Claude Code Laravel Configuration installed successfully!"
    echo ""
    echo -e "${BLUE}📁 Installation Directory:${NC} $CLAUDE_DIR"
    echo -e "${BLUE}📝 Backup Location:${NC} $BACKUP_DIR (if applicable)"
    echo ""
    echo -e "${YELLOW}🚀 Next Steps:${NC}"
    echo ""
    echo "1. Navigate to a Laravel project:"
    echo "   cd ~/Projects/my-laravel-app"
    echo ""
    echo "2. Ensure your project has the required quality tools:"
    echo "   composer require --dev phpstan/larastan laravel/pint rector/rector pestphp/pest"
    echo ""
    echo "3. Add these scripts to your composer.json:"
    echo "   cat $HOME/Desktop/laravel-project-example/composer-scripts-example.json"
    echo ""
    echo "4. Start Claude Code:"
    echo "   claude-code"
    echo ""
    echo "5. Optional - Copy project configuration:"
    echo "   cp $HOME/Desktop/laravel-project-example/.claude-hooks-config.sh ."
    echo "   cp $HOME/Desktop/laravel-project-example/.claude-hooks-ignore ."
    echo ""
    echo -e "${YELLOW}🔧 Testing Installation:${NC}"
    echo ""
    echo "Test the hooks manually:"
    echo "   $CLAUDE_DIR/hooks/smart-lint.sh"
    echo "   CLAUDE_HOOKS_DEBUG=1 $CLAUDE_DIR/hooks/smart-lint.sh"
    echo ""
    echo -e "${YELLOW}📚 Documentation:${NC}"
    echo ""
    echo "View the full README:"
    echo "   cat $CLAUDE_DIR/README.md"
    echo ""
    echo -e "${GREEN}Happy Laravel development with Claude Code! 🎉${NC}"
}

# Main installation function
main() {
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║         Claude Code Laravel Configuration Installer      ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Run installation steps
    check_dependencies
    backup_existing
    install_config
    set_permissions
    verify_installation
    configure_crono
    create_example_config
    print_usage
}

# Handle script interruption
trap 'print_error "Installation interrupted"; exit 1' INT TERM

# Check if running with bash
if [[ "${BASH_VERSION:-}" == "" ]]; then
    print_error "This script requires bash"
    exit 1
fi

# Ensure we're on macOS (optional check)
if [[ "$(uname)" != "Darwin" ]]; then
    print_warning "This script is designed for macOS but may work on other Unix systems"
fi

# Run main function
main "$@"