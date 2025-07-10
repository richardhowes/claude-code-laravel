# Claude Code Hooks

Automated code quality checks that run after Claude Code modifies files, enforcing project standards with zero tolerance for errors.

## Hooks

### `smart-lint.sh`
Intelligent project-aware linting that automatically detects language and runs appropriate checks:
- **PHP/Laravel**: `composer lint` (PHPStan/Larastan), `composer format` (Pint), `composer refactor` (Rector)
- **JavaScript/TypeScript**: `eslint`, `prettier`

Features:
- Detects project type automatically
- Respects project-specific composer scripts (`composer lint`, `composer format`, etc.)
- Smart file filtering (only checks modified files)
- Fast mode available (`--fast` to skip slow checks)
- Exit code 2 means issues found - ALL must be fixed

#### Failure

```
> Edit operation feedback:
  - [~/.claude/hooks/smart-lint.sh]:
  🔍 Style Check - Validating code formatting...
  ────────────────────────────────────────────
  [INFO] Project type: laravel
  [INFO] Running Laravel formatting and linting...
  [INFO] Using Composer scripts

  ═══ Summary ═══
  ❌ PHP linting failed (composer lint)

  Found 1 issue(s) that MUST be fixed!
  ════════════════════════════════════════════
  ❌ ALL ISSUES ARE BLOCKING ❌
  ════════════════════════════════════════════
  Fix EVERYTHING above until all checks are ✅ GREEN

  🛑 FAILED - Fix all issues above! 🛑
  📋 NEXT STEPS:
    1. Fix the issues listed above
    2. Verify the fix by running the lint command again
    3. Continue with your original task
```

#### Success

```
> Task operation feedback:
  - [~/.claude/hooks/smart-lint.sh]:
  🔍 Style Check - Validating code formatting...
  ────────────────────────────────────────────
  [INFO] Project type: laravel
  [INFO] Running Laravel formatting and linting...
  [INFO] Using Composer scripts

  👉 Style clean. Continue with your task.
```

By `exit 2` on success and telling it to continue, we prevent Claude from stopping after it has corrected
the style issues.

## Configuration

### Global Settings
Set environment variables or create project-specific `.claude-hooks-config.sh`:

```bash
CLAUDE_HOOKS_ENABLED=false      # Disable all hooks
CLAUDE_HOOKS_DEBUG=1            # Enable debug output
```

### Per-Project Settings
Create `.claude-hooks-config.sh` in your project root:

```bash
# Language-specific options
CLAUDE_HOOKS_PHP_ENABLED=false
CLAUDE_HOOKS_PHP_COMPLEXITY_THRESHOLD=30
CLAUDE_HOOKS_LARAVEL_ENABLED=false

# See example-claude-hooks-config.sh for all options
```

### Excluding Files
Create `.claude-hooks-ignore` in your project root using gitignore syntax:

```
vendor/**
node_modules/**
*.pb.go
*_generated.go
bootstrap/cache/**
storage/framework/**
```

Add `// claude-hooks-disable` to the top of any file to skip hooks.

## Usage

```bash
./smart-lint.sh           # Auto-runs after Claude edits
./smart-lint.sh --debug   # Debug mode
./smart-lint.sh --fast    # Skip slow checks
```

### Exit Codes
- `0`: All checks passed ✅
- `1`: General error (missing dependencies)
- `2`: Issues found - must fix ALL

## Dependencies

Hooks work best with these tools installed:
- **PHP/Laravel**: `composer` with `phpstan/larastan`, `laravel/pint`, `rector/rector`
- **JavaScript**: `eslint`, `prettier`

Hooks gracefully degrade if tools aren't installed.
