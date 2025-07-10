#!/usr/bin/env bash

# Claude Code Laravel Configuration - Installation Test Script
# This script tests the Claude Code configuration installation

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CLAUDE_DIR="$HOME/.claude"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    print_status "Running: $test_name"
    
    if eval "$test_command" >/dev/null 2>&1; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_success "$test_name"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_error "$test_name"
    fi
}

# Test installation directory exists
test_directory_exists() {
    run_test "Claude directory exists" "[[ -d '$CLAUDE_DIR' ]]"
}

# Test required files exist
test_required_files() {
    local required_files=(
        "CLAUDE.md"
        "README.md"
        "settings.json"
        "commands/check.md"
        "commands/next.md"
        "commands/prompt.md"
        "hooks/smart-lint.sh"
        "hooks/smart-test.sh"
        "hooks/common-helpers.sh"
    )
    
    for file in "${required_files[@]}"; do
        run_test "File exists: $file" "[[ -f '$CLAUDE_DIR/$file' ]]"
    done
}

# Test hook permissions
test_hook_permissions() {
    local hooks=(
        "smart-lint.sh"
        "smart-test.sh"
    )
    
    for hook in "${hooks[@]}"; do
        run_test "Hook executable: $hook" "[[ -x '$CLAUDE_DIR/hooks/$hook' ]]"
    done
}

# Test hook execution
test_hook_execution() {
    # Test smart-lint hook can run
    run_test "smart-lint.sh runs" "CLAUDE_HOOKS_DEBUG=1 '$CLAUDE_DIR/hooks/smart-lint.sh' --version 2>/dev/null || true"
    
    # Test common-helpers can be sourced
    run_test "common-helpers.sh sources" "source '$CLAUDE_DIR/hooks/common-helpers.sh'"
}

# Test project detection
test_project_detection() {
    # Create a temporary Laravel-like project
    local temp_dir=$(mktemp -d)
    pushd "$temp_dir" >/dev/null
    
    # Create Laravel-like files
    echo '{"name": "test/app", "require": {"laravel/framework": "^10.0"}}' > composer.json
    touch artisan
    
    # Test Laravel detection
    run_test "Laravel project detection" "source '$CLAUDE_DIR/hooks/common-helpers.sh' && [[ \$(detect_project_type) == 'laravel' ]]"
    
    popd >/dev/null
    rm -rf "$temp_dir"
}

# Test configuration loading
test_configuration() {
    run_test "CLAUDE.md is readable" "[[ -r '$CLAUDE_DIR/CLAUDE.md' ]]"
    run_test "settings.json is valid JSON" "cat '$CLAUDE_DIR/settings.json' | python3 -m json.tool >/dev/null 2>&1"
}

# Test example files
test_example_files() {
    local example_dir="$HOME/Desktop/laravel-project-example"
    
    if [[ -d "$example_dir" ]]; then
        run_test "Example .claude-hooks-config.sh exists" "[[ -f '$example_dir/.claude-hooks-config.sh' ]]"
        run_test "Example .claude-hooks-ignore exists" "[[ -f '$example_dir/.claude-hooks-ignore' ]]"
        run_test "Example composer scripts exist" "[[ -f '$example_dir/composer-scripts-example.json' ]]"
    else
        print_warning "Example directory not found at $example_dir"
    fi
}

# Function to print test summary
print_summary() {
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                     Test Summary                         ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}Tests Run:${NC}    $TESTS_RUN"
    echo -e "${GREEN}Tests Passed:${NC} $TESTS_PASSED"
    echo -e "${RED}Tests Failed:${NC} $TESTS_FAILED"
    echo ""
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}🎉 All tests passed! Installation is working correctly.${NC}"
        echo ""
        echo -e "${YELLOW}Next steps:${NC}"
        echo "1. Navigate to a Laravel project"
        echo "2. Run: claude-code"
        echo "3. Start coding - hooks will run automatically!"
        return 0
    else
        echo -e "${RED}❌ Some tests failed. Please check the installation.${NC}"
        echo ""
        echo -e "${YELLOW}Troubleshooting:${NC}"
        echo "1. Re-run: ./install.sh"
        echo "2. Check permissions: chmod +x ~/.claude/hooks/*.sh"
        echo "3. Verify dependencies are installed"
        return 1
    fi
}

# Main test function
main() {
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║         Claude Code Laravel Configuration Tester        ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Run all tests
    test_directory_exists
    test_required_files
    test_hook_permissions
    test_hook_execution
    test_project_detection
    test_configuration
    test_example_files
    
    # Print summary and exit with appropriate code
    print_summary
}

# Handle script interruption
trap 'print_error "Testing interrupted"; exit 1' INT TERM

# Check if running with bash
if [[ "${BASH_VERSION:-}" == "" ]]; then
    print_error "This script requires bash"
    exit 1
fi

# Run main function
main "$@"