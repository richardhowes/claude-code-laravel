#!/usr/bin/env bash
# smart-test.sh - Automatically run tests for files edited by Claude Code
#
# SYNOPSIS
#   PostToolUse hook that runs relevant tests when files are edited
#
# DESCRIPTION
#   When Claude edits a file, this hook intelligently runs associated tests:
#   - Focused tests for the specific file
#   - Package-level tests (with optional race detection)
#   - Full project tests (optional)
#   - Integration tests (if available)
#   - Configurable per-project via .claude-hooks-config.sh
#
# CONFIGURATION
#   CLAUDE_HOOKS_TEST_ON_EDIT - Enable/disable (default: true)
#   CLAUDE_HOOKS_TEST_MODES - Comma-separated: focused,package,all,integration
#   CLAUDE_HOOKS_ENABLE_RACE - Enable race detection (default: true)
#   CLAUDE_HOOKS_FAIL_ON_MISSING_TESTS - Fail if test file missing (default: false)

set -euo pipefail

# Debug trap (disabled)
# trap 'echo "DEBUG: Error on line $LINENO" >&2' ERR

# Source common helpers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common-helpers.sh"

# ============================================================================
# SETUP FUNCTIONS
# ============================================================================


# ============================================================================
# CONFIGURATION LOADING
# ============================================================================

load_config() {
    # Global defaults
    export CLAUDE_HOOKS_TEST_ON_EDIT="${CLAUDE_HOOKS_TEST_ON_EDIT:-true}"
    export CLAUDE_HOOKS_TEST_MODES="${CLAUDE_HOOKS_TEST_MODES:-focused,package}"
    export CLAUDE_HOOKS_ENABLE_RACE="${CLAUDE_HOOKS_ENABLE_RACE:-true}"
    export CLAUDE_HOOKS_FAIL_ON_MISSING_TESTS="${CLAUDE_HOOKS_FAIL_ON_MISSING_TESTS:-false}"
    export CLAUDE_HOOKS_TEST_VERBOSE="${CLAUDE_HOOKS_TEST_VERBOSE:-false}"

    # Load project config
    load_project_config

    # Quick exit if disabled
    if [[ "$CLAUDE_HOOKS_TEST_ON_EDIT" != "true" ]]; then
        echo "DEBUG: Test on edit disabled, exiting" >&2
        exit 0
    fi
}

# ============================================================================
# HOOK INPUT PARSING
# ============================================================================

# Check if we have input (hook mode) or running standalone (CLI mode)
if [ -t 0 ]; then
    # No input on stdin - CLI mode
    FILE_PATH="./..."
else
    # Read JSON input from stdin
    INPUT=$(cat)

    # Check if input is valid JSON
    if echo "$INPUT" | jq . >/dev/null 2>&1; then
        # Extract relevant fields
        TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
        TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input // empty')

        # Only process edit-related tools
        if [[ ! "$TOOL_NAME" =~ ^(Edit|Write|MultiEdit)$ ]]; then
            exit 0
        fi

        # Extract file path(s)
        if [[ "$TOOL_NAME" == "MultiEdit" ]]; then
            # MultiEdit has a different structure
            FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty')
        else
            FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty')
        fi

        # Skip if no file path
        [[ -z "$FILE_PATH" ]] && exit 0
    else
        # Not valid JSON - treat as CLI mode
        FILE_PATH="./..."
    fi
fi

# Load configuration
load_config


# ============================================================================
# TEST EXCLUSION PATTERNS
# ============================================================================

should_skip_test_requirement() {
    local file="$1"
    local base=$(basename "$file")
    local dir=$(dirname "$file")

    # Skip if in specific directories
    if [[ "$dir" =~ /(vendor|testdata|examples|gen|generated|.gen)(/|$) ]]; then
        return 0
    fi

    # Skip if it's a test file itself (will be handled differently)
    if [[ "$file" =~ _test\.(py|js|ts)$ ]]; then
        return 0
    fi

    return 1
}

# ============================================================================
# TEST OUTPUT FORMATTING
# ============================================================================

format_test_output() {
    local output="$1"
    local test_type="$2"

    # If output is empty, say so
    if [[ -z "$output" ]]; then
        echo "(no output captured)"
        return
    fi

    # Show the full output - no truncation when tests fail
    echo "$output"
}

# ============================================================================
# TEST RUNNERS BY LANGUAGE
# ============================================================================

run_javascript_tests() {
    local file="$1"
    local dir=$(dirname "$file")
    local base=$(basename "$file" | sed 's/\.[tj]sx\?$//' | sed 's/\.(test|spec)$//')

    # If this IS a test file, run it directly
    if [[ "$file" =~ \.(test|spec)\.[tj]sx?$ ]]; then
        echo -e "${BLUE}🧪 Running test file directly: $file${NC}" >&2

        local test_output
        if [[ -f "package.json" ]] && jq -e '.scripts.test' package.json >/dev/null 2>&1; then
            if ! test_output=$(
                npm test -- "$file" 2>&1); then
                echo -e "${RED}❌ Tests failed in $file${NC}" >&2
                echo -e "\n${RED}Failed test output:${NC}" >&2
                format_test_output "$test_output" "javascript" >&2
                return 1
            fi
        elif command -v jest >/dev/null 2>&1; then
            if ! test_output=$(
                jest "$file" 2>&1); then
                echo -e "${RED}❌ Tests failed in $file${NC}" >&2
                echo -e "\n${RED}Failed test output:${NC}" >&2
                format_test_output "$test_output" "javascript" >&2
                return 1
            fi
        fi
        echo -e "${GREEN}✅ Tests passed in $file${NC}" >&2
        return 0
    fi

    # Check if we should require tests
    local require_tests=true
    # JS/TS files that typically don't need tests
    if [[ "$base" =~ ^(index|main|app|config|setup|webpack\.config|rollup\.config|vite\.config)$ ]]; then
        require_tests=false
    fi
    if [[ "$dir" =~ /(dist|build|node_modules|coverage|docs|examples|scripts)(/|$) ]]; then
        require_tests=false
    fi
    # Skip declaration files
    if [[ "$file" =~ \.d\.ts$ ]]; then
        require_tests=false
    fi

    # Find test file
    local test_file=""
    local test_candidates=(
        "${dir}/${base}.test.js"
        "${dir}/${base}.spec.js"
        "${dir}/${base}.test.ts"
        "${dir}/${base}.spec.ts"
        "${dir}/${base}.test.jsx"
        "${dir}/${base}.test.tsx"
        "${dir}/__tests__/${base}.test.js"
        "${dir}/__tests__/${base}.spec.js"
        "${dir}/__tests__/${base}.test.ts"
    )

    for candidate in "${test_candidates[@]}"; do
        if [[ -f "$candidate" ]]; then
            test_file="$candidate"
            break
        fi
    done

    local failed=0
    local tests_run=0

    # Check if package.json has test script
    if [[ -f "package.json" ]] && jq -e '.scripts.test' package.json >/dev/null 2>&1; then
        # Parse test modes
        IFS=',' read -ra TEST_MODES <<< "$CLAUDE_HOOKS_TEST_MODES"

        for mode in "${TEST_MODES[@]}"; do
            mode=$(echo "$mode" | xargs)

            case "$mode" in
                "focused")
                    if [[ -n "$test_file" ]]; then
                        echo -e "${BLUE}🧪 Running focused tests for $base...${NC}" >&2
                        tests_run=$((tests_run + 1))

                        local test_output
                        if ! test_output=$(
                            npm test -- "$test_file" 2>&1); then
                            failed=1
                            echo -e "${RED}❌ Focused tests failed for $base${NC}" >&2
                            echo -e "\n${RED}Failed test output:${NC}" >&2
                            format_test_output "$test_output" "javascript" >&2
                            add_error "Focused tests failed for $base"
                        fi
                    elif [[ "$require_tests" == "true" ]]; then
                        echo -e "${RED}❌ Missing required test file for: $file${NC}" >&2
                        echo -e "${YELLOW}📝 Expected one of: ${test_candidates[*]}${NC}" >&2
                        add_error "Missing required test file for: $file"
                        return 2
                    fi
                    ;;

                "package")
                    echo -e "${BLUE}📦 Running all tests...${NC}" >&2
                    tests_run=$((tests_run + 1))

                    local test_output
                    if ! test_output=$(
                        npm test 2>&1); then
                        failed=1
                        echo -e "${RED}❌ Package tests failed${NC}" >&2
                        echo -e "\n${RED}Failed test output:${NC}" >&2
                        format_test_output "$test_output" "javascript" >&2
                        add_error "Package tests failed"
                    fi
                    ;;
            esac
        done
    elif [[ "$require_tests" == "true" && -z "$test_file" ]]; then
        echo -e "${RED}❌ No test runner configured and no tests found${NC}" >&2
        add_error "No test runner configured and no tests found"
        return 2
    fi

    # Summary
    if [[ $tests_run -eq 0 && "$require_tests" == "true" && -z "$test_file" ]]; then
        echo -e "${RED}❌ No tests found for $file (tests required)${NC}" >&2
        add_error "No tests found for $file (tests required)"
        return 2
    elif [[ $failed -eq 0 && $tests_run -gt 0 ]]; then
        log_success "All tests passed for $file"
    fi

    return $failed
}

# ============================================================================
# PEST VS PHPUNIT DETECTION
# ============================================================================

check_test_file_uses_pest() {
    local test_file="$1"

    # Skip if file doesn't exist
    [[ ! -f "$test_file" ]] && return 0

    # Check for PHPUnit patterns
    local phpunit_patterns=(
        "extends.*TestCase"
        "use.*PHPUnit.*TestCase"
        "public function test"
        "function test.*\(\)"
        "@test"
        "\$this->assert"
        "setUp\(\).*void"
        "tearDown\(\).*void"
    )

    local pest_patterns=(
        "it\("
        "test\("
        "describe\("
        "beforeEach\("
        "afterEach\("
        "expect\("
        "uses\("
    )

    local has_phpunit=false
    local has_pest=false

    # Check for PHPUnit patterns
    for pattern in "${phpunit_patterns[@]}"; do
        if grep -E "$pattern" "$test_file" >/dev/null 2>&1; then
            has_phpunit=true
            break
        fi
    done

    # Check for Pest patterns
    for pattern in "${pest_patterns[@]}"; do
        if grep -E "$pattern" "$test_file" >/dev/null 2>&1; then
            has_pest=true
            break
        fi
    done

    # If it has PHPUnit patterns but no Pest patterns, it's likely PHPUnit
    if [[ "$has_phpunit" == "true" && "$has_pest" == "false" ]]; then
        echo -e "${RED}❌ PHPUnit test detected: $test_file${NC}" >&2
        echo -e "${YELLOW}📝 This project requires Pest tests. Please rewrite using Pest syntax:${NC}" >&2
        echo -e "${YELLOW}   - Use test() or it() instead of public function testX()${NC}" >&2
        echo -e "${YELLOW}   - Use expect() assertions instead of \$this->assertX()${NC}" >&2
        echo -e "${YELLOW}   - Use beforeEach() instead of setUp()${NC}" >&2
        echo -e "${YELLOW}   See: https://pestphp.com/docs/writing-tests${NC}" >&2
        add_error "PHPUnit test file detected: $test_file (must use Pest)"
        return 1
    fi

    return 0
}

# ============================================================================
# LARAVEL/PHP TESTS
# ============================================================================

run_laravel_tests() {
    local file="$1"

    # Check if this is a Laravel project
    if [[ ! -f "artisan" ]] || [[ ! -f "composer.json" ]]; then
        # Not a Laravel project, skip
        return 0
    fi

    local dir=$(dirname "$file")
    local base=$(basename "$file" .php)
    local failed=0
    local tests_run=0

    # Laravel-specific files that typically don't need tests
    local skip_patterns=(
        "config/*"          # Configuration files
        "database/migrations/*" # Migrations
        "database/seeders/*"    # Seeders
        "database/factories/*" # Factories
        "bootstrap/*"       # Bootstrap files
        "public/*"          # Public assets
        "storage/*"         # Storage files
        "vendor/*"          # Vendor files
        "resources/views/*" # Blade templates
        "resources/lang/*"  # Language files
        "resources/css/*"   # CSS files
        "resources/js/*"    # JavaScript files
        "*ServiceProvider.php" # Service providers
        "*Middleware.php"   # Middleware (often just routing)
        "routes/*"          # Route files
        "app/Providers/*"   # Providers
        "app/Console/Kernel.php" # Console kernel
        "app/Http/Kernel.php"    # HTTP kernel
        "app/Exceptions/Handler.php" # Exception handler
    )

    # Additional patterns for files that typically have minimal logic
    local minimal_logic_patterns=(
        "*/Enums/*.php"     # Enum classes
        "*/Traits/*.php"    # Traits
        "*/Interfaces/*.php" # Interfaces
        "*/Contracts/*.php" # Contracts/Interfaces
        "*/DTOs/*.php"      # Data Transfer Objects
        "*/ValueObjects/*.php" # Value Objects
        "*/Events/*.php"    # Events (often just property bags)
        "*/Listeners/*.php" # Listeners with minimal logic
        "*/Mail/*.php"      # Mail classes (if using views)
        "*/Notifications/*.php" # Notifications (if using default)
        "*Request.php"      # Form requests (validation rules)
        "*Resource.php"     # API resources (data transformation)
        "*Collection.php"   # Resource collections
        "*Policy.php"       # Policies (if simple checks)
        "*Observer.php"     # Model observers (if simple)
        "*Scope.php"        # Query scopes
        "*Cast.php"         # Custom casts
        "*Rule.php"         # Validation rules (if simple)
    )

    # Check if we should skip testing for this file
    local require_tests=true
    for pattern in "${skip_patterns[@]}"; do
        # Handle both absolute and relative paths with glob patterns
        if [[ "$file" == $pattern ]] || [[ "$file" == */$pattern ]] || [[ "$(basename "$file")" == $pattern ]]; then
            require_tests=false
            break
        fi
    done

    # Also check minimal logic patterns
    if [[ "$require_tests" == "true" ]]; then
        for pattern in "${minimal_logic_patterns[@]}"; do
            # Handle both absolute and relative paths with glob patterns
            if [[ "$file" == $pattern ]] || [[ "$file" == */$pattern ]] || [[ "$(basename "$file")" == $pattern ]]; then
                require_tests=false
                break
            fi
        done
    fi

    # If this IS a test file, run it directly
    if [[ "$file" =~ Test\.php$ ]] || [[ "$dir" =~ /[Tt]ests/ ]]; then
        # First check if it uses Pest syntax
        if ! check_test_file_uses_pest "$file"; then
            return 1
        fi

        echo -e "${BLUE}🧪 Running test file directly: $file${NC}" >&2
        local test_output
        if ! test_output=$(composer test -- "$file" 2>&1); then
            echo -e "${RED}❌ Tests failed in $file${NC}" >&2
            echo -e "\n${RED}Failed test output:${NC}" >&2
            format_test_output "$test_output" "laravel" >&2
            return 1
        fi
        echo -e "${GREEN}✅ Tests passed in $file${NC}" >&2
        return 0
    fi

    # Find corresponding test file
    local test_file=""
    local test_candidates=(
        "tests/Unit/${base}Test.php"
        "tests/Feature/${base}Test.php"
        "tests/Unit/$(basename "$dir")/${base}Test.php"
        "tests/Feature/$(basename "$dir")/${base}Test.php"
    )

    # For Livewire components, check specific patterns
    if [[ "$dir" =~ app/Livewire ]] || [[ "$dir" =~ app/Http/Livewire ]]; then
        test_candidates+=(
            "tests/Feature/Livewire/${base}Test.php"
            "tests/Unit/Livewire/${base}Test.php"
        )
    fi

    # For Filament resources
    if [[ "$dir" =~ app/Filament ]]; then
        test_candidates+=(
            "tests/Feature/Filament/${base}Test.php"
            "tests/Unit/Filament/${base}Test.php"
        )
    fi

    for candidate in "${test_candidates[@]}"; do
        if [[ -f "$candidate" ]]; then
            test_file="$candidate"
            break
        fi
    done

    # Check if composer has a test script
    if command_exists composer && composer run-script --list | grep -q "test"; then
        # Parse test modes (reuse from Go tests)
        IFS=',' read -ra TEST_MODES <<< "$CLAUDE_HOOKS_TEST_MODES"

        for mode in "${TEST_MODES[@]}"; do
            mode=$(echo "$mode" | xargs)

            case "$mode" in
                "focused")
                    if [[ -n "$test_file" ]]; then
                        # Check if test file uses Pest
                        if ! check_test_file_uses_pest "$test_file"; then
                            failed=1
                        else
                            echo -e "${BLUE}🧪 Running focused tests for $base...${NC}" >&2
                            tests_run=$((tests_run + 1))

                            local test_output
                            if ! test_output=$(composer test -- "$test_file" 2>&1); then
                                failed=1
                                echo -e "${RED}❌ Focused tests failed for $base${NC}" >&2
                                echo -e "\n${RED}Failed test output:${NC}" >&2
                                format_test_output "$test_output" "laravel" >&2
                                add_error "Focused tests failed for $base"
                            fi
                        fi
                    elif [[ "$require_tests" == "true" ]]; then
                        echo -e "${RED}❌ Missing required test file for: $file${NC}" >&2
                        echo -e "${YELLOW}📝 Expected one of: ${test_candidates[*]}${NC}" >&2
                        add_error "Missing required test file for: $file"
                        return 2
                    fi
                    ;;

                "package")
                    echo -e "${BLUE}📦 Running all tests...${NC}" >&2
                    tests_run=$((tests_run + 1))

                    local test_output
                    if ! test_output=$(composer test 2>&1); then
                        failed=1
                        echo -e "${RED}❌ Package tests failed${NC}" >&2
                        echo -e "\n${RED}Failed test output:${NC}" >&2
                        format_test_output "$test_output" "laravel" >&2
                        add_error "Package tests failed"
                    fi
                    ;;
            esac
        done
    elif [[ "$require_tests" == "true" && -z "$test_file" ]]; then
        echo -e "${RED}❌ No test runner configured and no tests found${NC}" >&2
        add_error "No test runner configured and no tests found"
        return 2
    fi

    # Summary
    if [[ $tests_run -eq 0 && "$require_tests" == "true" && -z "$test_file" ]]; then
        echo -e "${RED}❌ No tests found for $file (tests required)${NC}" >&2
        add_error "No tests found for $file (tests required)"
        return 2
    elif [[ $failed -eq 0 && $tests_run -gt 0 ]]; then
        log_success "All tests passed for $file"
    fi

    return $failed
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

# Determine file type and run appropriate tests
main() {
    # Print header
    print_test_header

    local failed=0

    # Language-specific test runners - prioritize Laravel detection
    if [[ -f "artisan" && -f "composer.json" ]]; then
        # This is a Laravel project, run Laravel tests
        run_laravel_tests "$FILE_PATH" || failed=1
    elif [[ "$FILE_PATH" =~ \.php$ ]]; then
        # PHP file but not Laravel - could add generic PHP test runner here
        run_laravel_tests "$FILE_PATH" || failed=1
    elif [[ "$FILE_PATH" =~ \.[jt]sx?$ ]]; then
        run_javascript_tests "$FILE_PATH" || failed=1
    else
        # No tests for this file type
        exit 0
    fi

    if [[ $failed -ne 0 ]]; then
        exit_with_test_failure "$FILE_PATH"
    else
        exit_with_success_message "Tests pass. Continue with your task."
    fi
}

# Run main
main
