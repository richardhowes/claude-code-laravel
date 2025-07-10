#!/usr/bin/env bash
# smart-lint.sh - Intelligent project-aware code quality checks for Claude Code
#
# SYNOPSIS
#   smart-lint.sh [options]
#
# DESCRIPTION
#   Automatically detects project type and runs ALL quality checks.
#   Every issue found is blocking - code must be 100% clean to proceed.
#
# OPTIONS
#   --debug       Enable debug output
#   --fast        Skip slow checks (import cycles, security scans)
#
# EXIT CODES
#   0 - Success (all checks passed - everything is ✅ GREEN)
#   1 - General error (missing dependencies, etc.)
#   2 - ANY issues found - ALL must be fixed
#
# CONFIGURATION
#   Project-specific overrides can be placed in .claude-hooks-config.sh
#   See inline documentation for all available options.

# Don't use set -e - we need to control exit codes carefully
set +e

# ============================================================================
# COLOR DEFINITIONS AND UTILITIES
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Debug mode
CLAUDE_HOOKS_DEBUG="${CLAUDE_HOOKS_DEBUG:-0}"

# Logging functions
log_debug() {
    [[ "$CLAUDE_HOOKS_DEBUG" == "1" ]] && echo -e "${CYAN}[DEBUG]${NC} $*" >&2
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $*" >&2
}

# Performance timing
time_start() {
    if [[ "$CLAUDE_HOOKS_DEBUG" == "1" ]]; then
        echo $(($(date +%s%N)/1000000))
    fi
}

time_end() {
    if [[ "$CLAUDE_HOOKS_DEBUG" == "1" ]]; then
        local start=$1
        local end=$(($(date +%s%N)/1000000))
        local duration=$((end - start))
        log_debug "Execution time: ${duration}ms"
    fi
}

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# ============================================================================
# PROJECT DETECTION
# ============================================================================

detect_project_type() {
    local project_type="unknown"
    local types=()
    
    # Laravel project (check first - most specific)
    if [[ -f "artisan" ]] && [[ -f "composer.json" ]] && grep -q "laravel/framework" composer.json 2>/dev/null; then
        types+=("laravel")
    # PHP project (general)
    elif [[ -f "composer.json" ]] || [[ -n "$(find . -maxdepth 3 -name "*.php" -type f -print -quit 2>/dev/null)" ]]; then
        types+=("php")
    fi
    
    # JavaScript/TypeScript project
    if [[ -f "package.json" ]] || [[ -f "tsconfig.json" ]] || [[ -n "$(find . -maxdepth 3 \( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" \) -type f -print -quit 2>/dev/null)" ]]; then
        types+=("javascript")
    fi
    
    # Return primary type or "mixed" if multiple
    if [[ ${#types[@]} -eq 1 ]]; then
        project_type="${types[0]}"
    elif [[ ${#types[@]} -gt 1 ]]; then
        project_type="mixed:$(IFS=,; echo "${types[*]}")"
    fi
    
    log_debug "Detected project type: $project_type"
    echo "$project_type"
}

# Get list of modified files (if available from git)
get_modified_files() {
    if [[ -d .git ]] && command_exists git; then
        # Get files modified in the last commit or currently staged/modified
        git diff --name-only HEAD 2>/dev/null || true
        git diff --cached --name-only 2>/dev/null || true
    fi
}

# Check if we should skip a file
should_skip_file() {
    local file="$1"
    
    # Check .claude-hooks-ignore if it exists
    if [[ -f ".claude-hooks-ignore" ]]; then
        while IFS= read -r pattern; do
            # Skip comments and empty lines
            [[ -z "$pattern" || "$pattern" =~ ^[[:space:]]*# ]] && continue
            
            # Check if file matches pattern
            if [[ "$file" == $pattern ]]; then
                log_debug "Skipping $file due to .claude-hooks-ignore pattern: $pattern"
                return 0
            fi
        done < ".claude-hooks-ignore"
    fi
    
    # Check for inline skip comments
    if [[ -f "$file" ]] && head -n 5 "$file" 2>/dev/null | grep -q "claude-hooks-disable"; then
        log_debug "Skipping $file due to inline claude-hooks-disable comment"
        return 0
    fi
    
    return 1
}

# ============================================================================
# ERROR TRACKING
# ============================================================================

declare -a CLAUDE_HOOKS_SUMMARY=()
declare -i CLAUDE_HOOKS_ERROR_COUNT=0

add_error() {
    local message="$1"
    CLAUDE_HOOKS_ERROR_COUNT+=1
    CLAUDE_HOOKS_SUMMARY+=("${RED}❌${NC} $message")
}

print_summary() {
    if [[ $CLAUDE_HOOKS_ERROR_COUNT -gt 0 ]]; then
        # Only show failures when there are errors
        echo -e "\n${BLUE}═══ Summary ═══${NC}" >&2
        for item in "${CLAUDE_HOOKS_SUMMARY[@]}"; do
            echo -e "$item" >&2
        done
        
        echo -e "\n${RED}Found $CLAUDE_HOOKS_ERROR_COUNT issue(s) that MUST be fixed!${NC}" >&2
        echo -e "${RED}════════════════════════════════════════════${NC}" >&2
        echo -e "${RED}❌ ALL ISSUES ARE BLOCKING ❌${NC}" >&2
        echo -e "${RED}════════════════════════════════════════════${NC}" >&2
        echo -e "${RED}Fix EVERYTHING above until all checks are ✅ GREEN${NC}" >&2
    fi
}

# ============================================================================
# CONFIGURATION LOADING
# ============================================================================

load_config() {
    # Default configuration
    export CLAUDE_HOOKS_ENABLED="${CLAUDE_HOOKS_ENABLED:-true}"
    export CLAUDE_HOOKS_FAIL_FAST="${CLAUDE_HOOKS_FAIL_FAST:-false}"
    export CLAUDE_HOOKS_SHOW_TIMING="${CLAUDE_HOOKS_SHOW_TIMING:-false}"
    
    # Language enables
    export CLAUDE_HOOKS_LARAVEL_ENABLED="${CLAUDE_HOOKS_LARAVEL_ENABLED:-true}"
    export CLAUDE_HOOKS_PHP_ENABLED="${CLAUDE_HOOKS_PHP_ENABLED:-true}"
    export CLAUDE_HOOKS_JS_ENABLED="${CLAUDE_HOOKS_JS_ENABLED:-true}"
    
    # Laravel-specific configuration
    export CLAUDE_HOOKS_LARAVEL_LINT_CMD="${CLAUDE_HOOKS_LARAVEL_LINT_CMD:-composer test:types}"
    export CLAUDE_HOOKS_LARAVEL_FORMAT_CMD="${CLAUDE_HOOKS_LARAVEL_FORMAT_CMD:-composer refactor:lint}"
    export CLAUDE_HOOKS_LARAVEL_REFACTOR_CMD="${CLAUDE_HOOKS_LARAVEL_REFACTOR_CMD:-composer refactor:rector}"
    export CLAUDE_HOOKS_LARAVEL_ANNOTATE_CMD="${CLAUDE_HOOKS_LARAVEL_ANNOTATE_CMD:-composer refactor:annotate}"
    export CLAUDE_HOOKS_LARAVEL_TEST_CMD="${CLAUDE_HOOKS_LARAVEL_TEST_CMD:-composer test:pest}"
    
    # Project-specific overrides
    if [[ -f ".claude-hooks-config.sh" ]]; then
        source ".claude-hooks-config.sh" || {
            log_error "Failed to load .claude-hooks-config.sh"
            exit 2
        }
    fi
    
    # Quick exit if hooks are disabled
    if [[ "$CLAUDE_HOOKS_ENABLED" != "true" ]]; then
        log_info "Claude hooks are disabled"
        exit 0
    fi
}

# ============================================================================
# LARAVEL LINTING
# ============================================================================

lint_laravel() {
    if [[ "${CLAUDE_HOOKS_LARAVEL_ENABLED:-true}" != "true" ]]; then
        log_debug "Laravel linting disabled"
        return 0
    fi
    
    log_info "Running Laravel formatting and linting..."
    log_info "Using Composer scripts"

    # Refactor with Rector
    local refactor_output
    log_info "Running Laravel Refactor $CLAUDE_HOOKS_LARAVEL_REFACTOR_CMD"
    if ! refactor_output=$($CLAUDE_HOOKS_LARAVEL_REFACTOR_CMD 2>&1); then
        add_error "PHP refactoring failed ($CLAUDE_HOOKS_LARAVEL_REFACTOR_CMD)"
        echo "$refactor_output" >&2
    fi
    
    # Format with Pint
    local format_output
    log_info "Running Laravel Format $CLAUDE_HOOKS_LARAVEL_FORMAT_CMD"
    if ! format_output=$($CLAUDE_HOOKS_LARAVEL_FORMAT_CMD 2>&1); then
        add_error "PHP formatting failed ($CLAUDE_HOOKS_LARAVEL_FORMAT_CMD)"
        echo "$format_output" >&2
    fi
    
    # Lint with PHPStan/Larastan
    local lint_output
    log_info "Running Laravel Lint $CLAUDE_HOOKS_LARAVEL_LINT_CMD"
    if ! lint_output=$($CLAUDE_HOOKS_LARAVEL_LINT_CMD 2>&1); then
        add_error "PHP linting failed ($CLAUDE_HOOKS_LARAVEL_LINT_CMD)"
        echo "$lint_output" >&2
    fi
    
    # Generate docblocks (optional - just check if command exists)
    if command_exists composer && composer run-script --list | grep -q "refactor:annotate"; then
        local annotate_output
         log_info "Running Laravel Annotate $CLAUDE_HOOKS_LARAVEL_ANNOTATE_CMD"
        if ! annotate_output=$($CLAUDE_HOOKS_LARAVEL_ANNOTATE_CMD 2>&1); then
            log_debug "Docblock annotation failed (non-blocking): $annotate_output"
        fi
    fi
}

# ============================================================================
# PHP LINTING (General)
# ============================================================================

lint_php() {
    if [[ "${CLAUDE_HOOKS_PHP_ENABLED:-true}" != "true" ]]; then
        log_debug "PHP linting disabled"
        return 0
    fi
    
    log_info "Running PHP linting..."
    
    # Check if it's actually a Laravel project that was misdetected
    if [[ -f "artisan" ]] && [[ -f "composer.json" ]]; then
        log_info "Detected Laravel project, switching to Laravel linting"
        lint_laravel
        return
    fi
    
    # For general PHP projects, use basic composer commands if available
    if [[ -f "composer.json" ]]; then
        # Try Laravel Pint first (works for general PHP too)
        if command_exists composer && composer run-script --list | grep -q "format"; then
            local format_output
            if ! format_output=$(composer format 2>&1); then
                add_error "PHP formatting failed (composer format)"
                echo "$format_output" >&2
            fi
        fi
        
        # Try PHPStan
        if command_exists composer && composer run-script --list | grep -q "lint"; then
            local lint_output
            if ! lint_output=$(composer lint 2>&1); then
                add_error "PHP linting failed (composer lint)"
                echo "$lint_output" >&2
            fi
        fi
    else
        log_info "No composer.json found, skipping PHP quality checks"
    fi
}


# ============================================================================
# OTHER LANGUAGE LINTERS
# ============================================================================

lint_javascript() {
    if [[ "${CLAUDE_HOOKS_JS_ENABLED:-true}" != "true" ]]; then
        log_debug "JavaScript linting disabled"
        return 0
    fi
    
    log_info "Running JavaScript/TypeScript linters..."
    
    # Check for ESLint
    if [[ -f "package.json" ]] && grep -q "eslint" package.json 2>/dev/null; then
        if command_exists npm; then
            local eslint_output
            if ! eslint_output=$(npm run lint --if-present 2>&1); then
                add_error "ESLint found issues"
                echo "$eslint_output" >&2
            fi
        fi
    fi
    
    # Prettier
    if [[ -f ".prettierrc" ]] || [[ -f "prettier.config.js" ]] || [[ -f ".prettierrc.json" ]]; then
        if command_exists prettier; then
            local prettier_output
            if ! prettier_output=$(prettier --check . 2>&1); then
                # Apply formatting and capture any errors
                local format_output
                if ! format_output=$(prettier --write . 2>&1); then
                    add_error "Prettier formatting failed"
                    echo "$format_output" >&2
                fi
            fi
        elif command_exists npx; then
            local prettier_output
            if ! prettier_output=$(npx prettier --check . 2>&1); then
                # Apply formatting and capture any errors
                local format_output
                if ! format_output=$(npx prettier --write . 2>&1); then
                    add_error "Prettier formatting failed"
                    echo "$format_output" >&2
                fi
            fi
        fi
    fi
    
    return 0
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

# Parse command line options
FAST_MODE=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --debug)
            export CLAUDE_HOOKS_DEBUG=1
            shift
            ;;
        --fast)
            FAST_MODE=true
            shift
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 2
            ;;
    esac
done

# Print header
echo "" >&2
echo "🔍 Style Check - Validating code formatting..." >&2
echo "────────────────────────────────────────────" >&2

# Load configuration
load_config

# Start timing
START_TIME=$(time_start)

# Detect project type
PROJECT_TYPE=$(detect_project_type)
log_info "Project type: $PROJECT_TYPE"

# Main execution
main() {
    # Handle mixed project types
    if [[ "$PROJECT_TYPE" == mixed:* ]]; then
        local types="${PROJECT_TYPE#mixed:}"
        IFS=',' read -ra TYPE_ARRAY <<< "$types"
        
        for type in "${TYPE_ARRAY[@]}"; do
            case "$type" in
                "laravel") lint_laravel ;;
                "php") lint_php ;;
                "javascript") lint_javascript ;;
            esac
            
            # Fail fast if configured
            if [[ "$CLAUDE_HOOKS_FAIL_FAST" == "true" && $CLAUDE_HOOKS_ERROR_COUNT -gt 0 ]]; then
                break
            fi
        done
    else
        # Single project type
        case "$PROJECT_TYPE" in
            "laravel") lint_laravel ;;
            "php") lint_php ;;
            "javascript") lint_javascript ;;
            "unknown") 
                log_info "No recognized project type, skipping checks"
                ;;
        esac
    fi
    
    # Show timing if enabled
    time_end "$START_TIME"
    
    # Print summary
    print_summary
    
    # Return exit code - any issues mean failure
    if [[ $CLAUDE_HOOKS_ERROR_COUNT -gt 0 ]]; then
        return 2
    else
        return 0
    fi
}

# Run main function
main
exit_code=$?

# Final message and exit
if [[ $exit_code -eq 2 ]]; then
    echo -e "\n${RED}🛑 FAILED - Fix all issues above! 🛑${NC}" >&2
    echo -e "${YELLOW}📋 NEXT STEPS:${NC}" >&2
    echo -e "${YELLOW}  1. Fix the issues listed above${NC}" >&2
    echo -e "${YELLOW}  2. Verify the fix by running the lint command again${NC}" >&2
    echo -e "${YELLOW}  3. Continue with your original task${NC}" >&2
    exit 2
else
    # Always exit with 2 so Claude sees the continuation message
    echo -e "\n${YELLOW}👉 Style clean. Continue with your task.${NC}" >&2
    exit 2
fi