#!/usr/bin/env bash

# Claude Code Laravel Configuration - Uninstall Script
# This script removes the globally installed Laravel Claude Code configuration

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$HOME/.claude-uninstall-backup-$(date +%Y%m%d-%H%M%S)"

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

# Function to confirm uninstallation
confirm_uninstall() {
    echo ""
    echo -e "${YELLOW}⚠️  This will remove the Claude Code Laravel configuration from:${NC}"
    echo -e "${YELLOW}   $CLAUDE_DIR${NC}"
    echo ""
    echo -e "${BLUE}A backup will be created at:${NC}"
    echo -e "${BLUE}   $BACKUP_DIR${NC}"
    echo ""
    
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Uninstallation cancelled"
        exit 0
    fi
}

# Function to backup before removal
backup_configuration() {
    if [[ -d "$CLAUDE_DIR" ]]; then
        print_status "Creating backup..."
        cp -r "$CLAUDE_DIR" "$BACKUP_DIR"
        print_success "Backup created at $BACKUP_DIR"
    else
        print_warning "No Claude Code configuration found at $CLAUDE_DIR"
        exit 0
    fi
}

# Function to remove configuration
remove_configuration() {
    print_status "Removing Claude Code Laravel configuration..."
    
    if [[ -d "$CLAUDE_DIR" ]]; then
        rm -rf "$CLAUDE_DIR"
        print_success "Configuration removed"
    else
        print_warning "Configuration directory not found"
    fi
}

# Function to clean up example files
cleanup_examples() {
    local example_dir="$HOME/Desktop/laravel-project-example"
    
    if [[ -d "$example_dir" ]]; then
        print_status "Removing example configuration files..."
        
        read -p "Remove example files at $example_dir? (y/N): " -n 1 -r
        echo ""
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$example_dir"
            print_success "Example files removed"
        else
            print_status "Example files kept at $example_dir"
        fi
    fi
}

# Function to verify removal
verify_removal() {
    if [[ ! -d "$CLAUDE_DIR" ]]; then
        print_success "Claude Code Laravel configuration successfully removed"
    else
        print_error "Failed to completely remove configuration"
        exit 1
    fi
}

# Function to print post-uninstall information
print_post_uninstall() {
    echo ""
    print_success "Uninstallation completed!"
    echo ""
    echo -e "${BLUE}📁 Backup Location:${NC} $BACKUP_DIR"
    echo ""
    echo -e "${YELLOW}📝 Note:${NC} Project-specific configurations (.claude-hooks-config.sh, .claude-hooks-ignore)"
    echo "   in your Laravel projects are not affected by this uninstallation."
    echo ""
    echo -e "${YELLOW}🔄 To reinstall:${NC}"
    echo "   curl -fsSL https://raw.githubusercontent.com/your-username/claude-code-laravel/main/install.sh | bash"
    echo ""
    echo -e "${YELLOW}♻️  To restore from backup:${NC}"
    echo "   mv $BACKUP_DIR $CLAUDE_DIR"
    echo "   chmod +x $CLAUDE_DIR/hooks/*.sh"
    echo ""
}

# Main uninstallation function
main() {
    echo ""
    echo -e "${RED}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║       Claude Code Laravel Configuration Uninstaller     ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Run uninstallation steps
    confirm_uninstall
    backup_configuration
    remove_configuration
    cleanup_examples
    verify_removal
    print_post_uninstall
}

# Handle script interruption
trap 'print_error "Uninstallation interrupted"; exit 1' INT TERM

# Check if running with bash
if [[ "${BASH_VERSION:-}" == "" ]]; then
    print_error "This script requires bash"
    exit 1
fi

# Run main function
main "$@"