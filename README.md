# Claude Code - Laravel Development Configuration

A comprehensive Claude Code configuration optimized for Laravel, Livewire, and Filament development with automated quality checks, testing, and real-time development patterns.

## 🚀 Quick Start

```bash
# Install globally to ~/.claude from this directory
./install.sh

# Or manual installation
cp -r . ~/.claude
chmod +x ~/.claude/hooks/*.sh

# Test installation
~/.claude/hooks/smart-lint.sh --help
```

## 📋 Requirements

### Basic Requirements
- **macOS** (tested on macOS 14+, may work on other Unix systems)
- **Homebrew** for package management
- **Claude Code CLI** installed globally
- **Git** for version control

### Optional Components
- **Crono Integration** - Automatically send session transcripts to your Crono dashboard
- **Laravel Development Stack** - Enhanced support for Laravel projects:
  - PHP 8.2+ with Composer
  - Laravel quality tools (phpstan/larastan, laravel/pint, rector/rector, pestphp/pest)
  - Laravel Herd for local development
- **Node.js** for frontend assets (if needed)

## 🛠 Installation

### Step 1: Install Dependencies

```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Claude Code CLI
brew install claude-code

# Install Laravel Herd (recommended for local Laravel development)
brew install --cask herd
```

### Step 2: Clone and Install

```bash
# Clone the repository
git clone https://github.com/your-username/claude-code-enhanced.git
cd claude-code-enhanced

# Run the installation script
./install.sh

# Or manual installation
cp -r . ~/.claude
chmod +x ~/.claude/hooks/*.sh

# Verify installation
ls -la ~/.claude/
~/.claude/hooks/smart-lint.sh --help
```

The installation script will:
- Create a backup of any existing ~/.claude directory
- Install the configuration files
- Optionally configure Crono integration (you'll be prompted for your API token)
- Set up example configurations

### Step 3: Crono Integration (Optional)

If you want to automatically send your Claude Code session transcripts to Crono:

1. **During Installation**: The install script will prompt you to configure Crono
2. **Manual Setup**: Get your API token from [usecrono.com](https://usecrono.com)
3. **Configure Hook**: In Claude Code, run `/hooks`, select "Stop" event, and add `~/.claude/hooks/crono.sh`

### Step 4: Laravel Project Setup (Optional)

For Laravel projects, you can enhance the experience with quality tools:

```bash
# In your Laravel project directory
composer require --dev phpstan/larastan laravel/pint rector/rector pestphp/pest

# Add these scripts to your composer.json
{
  "scripts": {
    "lint": "phpstan analyse",
    "format": "pint", 
    "refactor": "rector process",
    "test": "pest"
  }
}
```

### Step 5: Project Configuration (Optional)

Customize behavior for specific projects:

```bash
# Copy example configuration
cp ~/.claude/hooks/example-claude-hooks-config.sh .claude-hooks-config.sh

# Edit as needed
vim .claude-hooks-config.sh
```

## 🎯 Features

### Smart Development Workflow
- **Automatic Project Detection**: Recognizes Laravel, Node.js, and other project types
- **Quality Pipeline**: Automated formatting, linting, and testing
- **Hook System**: Smart hooks that run appropriate checks based on your project
- **Command Integration**: Special commands like `/check`, `/next`, and `/prompt`

### Session Management
- **Crono Integration**: Optional automatic session transcript upload
- **Memory Management**: Structured approach to handling long conversations
- **Progress Tracking**: Built-in todo system for complex tasks

### Code Quality Standards
- **Multi-language Support**: PHP, JavaScript, TypeScript, and more
- **Framework-Specific Rules**: Enhanced support for Laravel, React, etc.
- **Automated Fixes**: Auto-formatting and code quality improvements
- **Smart Exclusions**: Skips generated files, vendor code, and build artifacts

### Productivity Features
- **Zero Tolerance Quality**: All issues must be fixed before continuing
- **Research → Plan → Implement**: Structured development workflow
- **Agent Delegation**: Leverage multiple agents for complex tasks
- **Real-time Feedback**: Immediate validation and suggestions

## 📁 Directory Structure

```
~/.claude/
├── CLAUDE.md                    # Main configuration and standards
├── README.md                    # This file
├── settings.json                # Claude Code hook configuration
├── install.sh                   # Installation script
├── uninstall.sh                 # Uninstallation script
├── commands/
│   ├── check.md                 # Quality verification command
│   ├── next.md                  # Implementation workflow
│   └── prompt.md                # Prompt synthesis tool
└── hooks/
    ├── smart-lint.sh            # Automated code quality checks
    ├── smart-test.sh            # Automated testing
    ├── crono.sh                 # Crono integration (optional)
    ├── common-helpers.sh        # Shared utilities
    ├── example-claude-hooks-config.sh
    └── example-claude-hooks-ignore
```

## 🔧 Usage

### In Claude Code

The configuration works automatically when you use Claude Code in any project:

```bash
# Navigate to your project
cd ~/Projects/my-project

# Start Claude Code
claude-code

# The hooks will automatically:
# 1. Detect your project type (Laravel, Node.js, etc.)
# 2. Run appropriate quality checks on file edits
# 3. Enforce best practices for your framework
# 4. Run relevant tests and validations
```

### Manual Hook Testing

```bash
# Test the linting hook
~/.claude/hooks/smart-lint.sh

# Test the testing hook
~/.claude/hooks/smart-test.sh

# Debug mode
CLAUDE_HOOKS_DEBUG=1 ~/.claude/hooks/smart-lint.sh
```

### Using Commands

The configuration includes special commands you can use:

- `/check` - Run comprehensive quality checks and fix all issues
- `/next <task>` - Start implementation with proper workflow
- `/prompt <task>` - Generate complete prompts for new conversations

### Crono Integration

If you configured Crono during installation, your session transcripts will automatically be sent to your dashboard after each Claude Code session ends. This helps with:
- Session analysis and review
- Progress tracking across projects
- Learning from past conversations

## ⚙️ Configuration

### Global Settings

Edit `~/.claude/hooks/example-claude-hooks-config.sh` for global defaults.

### Per-Project Settings

Create `.claude-hooks-config.sh` in your project root:

```bash
# Customize Laravel commands
export CLAUDE_HOOKS_LARAVEL_LINT_CMD="composer lint"
export CLAUDE_HOOKS_LARAVEL_FORMAT_CMD="composer format"
export CLAUDE_HOOKS_LARAVEL_REFACTOR_CMD="composer refactor"
export CLAUDE_HOOKS_LARAVEL_TEST_CMD="composer test"

# Disable specific checks
export CLAUDE_HOOKS_LARAVEL_CHECK_POLLING=false

# Enable debug mode
export CLAUDE_HOOKS_DEBUG=1
```

### Ignoring Files

Create `.claude-hooks-ignore` in your project root:

```
# Laravel-specific ignores
vendor/**
bootstrap/cache/**
storage/framework/**
public/hot
_ide_helper.php

# Custom ignores
legacy-code/**
temp-files/**
```

## 🧪 Laravel Project Integration

### Required Composer Scripts

Your Laravel project should have these scripts in `composer.json`:

```json
{
  "scripts": {
    "lint": [
      "phpstan analyse --memory-limit=2G"
    ],
    "format": [
      "pint"
    ],
    "refactor": [
      "rector process"
    ],
    "refactor:annotate": [
      "rector process --dry-run --config=rector-annotate.php"
    ],
    "test": [
      "pest"
    ]
  }
}
```

### Example PHPStan Configuration

Create `phpstan.neon`:

```yaml
includes:
    - vendor/larastan/larastan/extension.neon

parameters:
    paths:
        - app/
        - config/
        - database/
        - resources/
        - routes/
        - tests/

    level: 9
    
    ignoreErrors:
        - '#Call to an undefined method Illuminate\\Database\\Eloquent\\Builder#'
        
    excludePaths:
        - bootstrap/cache/
        - storage/
        - vendor/
```

### Example Rector Configuration

Create `rector.php`:

```php
<?php

declare(strict_types=1);

use Rector\Config\RectorConfig;
use Rector\Laravel\Set\LaravelSetList;
use Rector\Php82\Set\Php82SetList;

return static function (RectorConfig $rectorConfig): void {
    $rectorConfig->paths([
        __DIR__ . '/app',
        __DIR__ . '/config',
        __DIR__ . '/database',
        __DIR__ . '/resources',
        __DIR__ . '/routes',
        __DIR__ . '/tests',
    ]);

    $rectorConfig->sets([
        Php82SetList::PHP_82,
        LaravelSetList::LARAVEL_110,
    ]);

    $rectorConfig->skip([
        __DIR__ . '/bootstrap/cache',
        __DIR__ . '/storage',
        __DIR__ . '/vendor',
    ]);
};
```

## 🔄 Real-time Development

This configuration enforces modern Laravel real-time patterns:

### ❌ Forbidden Patterns
```php
// DON'T: Polling in Livewire
public function refresh() { 
    // Polling logic here
}

// DON'T: Direct database queries in render
public function render() {
    return view('livewire.users', [
        'users' => User::all() // ❌ Query in render
    ]);
}

// DON'T: Class constants for UI
class UserStatus {
    const ACTIVE = 'active';     // ❌
    const INACTIVE = 'inactive'; // ❌
}
```

### ✅ Recommended Patterns
```php
// DO: Use Laravel Echo for real-time updates
protected $listeners = ['user-updated' => 'refreshUser'];

// DO: Use Livewire actions for user interactions
public function deleteUser(User $user) { ... }

// DO: Use Enum classes with methods
enum UserStatus: string {
    case Active = 'active';
    case Inactive = 'inactive';
    
    public function getLabel(): string {
        return match($this) {
            self::Active => 'Active User',
            self::Inactive => 'Inactive User',
        };
    }
    
    public function getColor(): string {
        return match($this) {
            self::Active => 'success',
            self::Inactive => 'danger',
        };
    }
}
```

## 🐛 Troubleshooting

### Common Issues

**Hook not running:**
```bash
# Check permissions
ls -la ~/.claude/hooks/smart-lint.sh
chmod +x ~/.claude/hooks/smart-lint.sh
```

**Laravel not detected:**
```bash
# Verify Laravel detection
cd your-laravel-project
ls -la artisan composer.json
grep "laravel/framework" composer.json
```

**Quality tools missing:**
```bash
# Install missing tools
composer require --dev phpstan/larastan laravel/pint rector/rector pestphp/pest
```

**Hook fails with command not found:**
```bash
# Check if composer is in PATH
which composer
echo $PATH

# Add to ~/.zshrc or ~/.bash_profile if needed
export PATH="$PATH:~/.composer/vendor/bin"
```

### Test Installation

Verify your installation is working correctly:

```bash
# Run the test script
./test-installation.sh

# Or if already installed globally
~/.claude/test-installation.sh
```

### Debug Mode

Enable debug mode for detailed output:

```bash
export CLAUDE_HOOKS_DEBUG=1
~/.claude/hooks/smart-lint.sh
```

### Logs and Output

Hooks output to stderr for visibility in Claude Code:

```bash
# View recent Claude Code logs
tail -f ~/.claude-code/logs/latest.log
```

## 🗑️ Uninstallation

To remove the global Claude Code configuration:

```bash
# Run the uninstall script (creates a backup)
~/.claude/uninstall.sh

# Or manual removal
rm -rf ~/.claude

# Clean up example files (optional)
rm -rf ~/Desktop/laravel-project-example
```

## 🔄 Updates

Keep your configuration up to date:

```bash
# If installed from git repository
cd ~/.claude
git pull origin main
chmod +x hooks/*.sh

# If installed locally, re-run installation
cd /path/to/claude-code-source
./install.sh

# Check for any new requirements
cat ~/.claude/README.md | grep -A 10 "Requirements"
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test with different project types (Laravel, Node.js, etc.)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Development Setup

```bash
# Clone your fork
git clone https://github.com/your-username/claude-code-enhanced.git
cd claude-code-enhanced

# Test your changes
./test-installation.sh

# Install locally for testing
./install.sh
```

## 📄 License

MIT License - see LICENSE file for details.

## 🙏 Acknowledgments

- Inspired by https://github.com/Veraticus/nix-config
- Built for Claude Code CLI
- Optimized for Laravel ecosystem
- Inspired by modern PHP development practices
- Designed for Laravel Herd workflow

---

**Happy Laravel Development with Claude Code!** 🚀

For support or questions, create an issue in the repository or check the [Claude Code documentation](https://docs.anthropic.com/en/docs/claude-code).