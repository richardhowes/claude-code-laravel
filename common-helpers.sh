#!/bin/bash

# Common helper functions for Claude Code Laravel hooks

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a file exists
file_exists() {
    [ -f "$1" ]
}

# Function to check if a directory exists
dir_exists() {
    [ -d "$1" ]
}

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    case $color in
        "red") echo -e "\033[0;31m${message}\033[0m" ;;
        "green") echo -e "\033[0;32m${message}\033[0m" ;;
        "yellow") echo -e "\033[0;33m${message}\033[0m" ;;
        "blue") echo -e "\033[0;34m${message}\033[0m" ;;
        *) echo "$message" ;;
    esac
}

# Function to check if a package exists in composer.json
composer_has_package() {
    local package=$1
    if file_exists "composer.json"; then
        grep -q "\"$package\"" composer.json
    else
        return 1
    fi
}

# Function to check if a package exists in package.json
npm_has_package() {
    local package=$1
    if file_exists "package.json"; then
        grep -q "\"$package\"" package.json
    else
        return 1
    fi
}

# Function to detect Laravel frontend stack
detect_laravel_stack() {
    local stack="unknown"
    
    # Check if it's a Laravel project first
    if ! file_exists "artisan" || ! file_exists "composer.json"; then
        echo "none"
        return
    fi
    
    # Check for forced stack via environment variable
    if [ -n "$CLAUDE_HOOKS_LARAVEL_STACK" ]; then
        echo "$CLAUDE_HOOKS_LARAVEL_STACK"
        return
    fi
    
    # Auto-detect stack based on installed packages
    if composer_has_package "filament/filament"; then
        stack="filament"
    elif composer_has_package "livewire/livewire"; then
        stack="livewire"
    elif composer_has_package "inertiajs/inertia-laravel"; then
        # Determine if it's Vue or React
        if npm_has_package "@inertiajs/vue3" || npm_has_package "@inertiajs/inertia-vue3"; then
            stack="inertia-vue"
        elif npm_has_package "@inertiajs/react" || npm_has_package "@inertiajs/inertia-react"; then
            stack="inertia-react"
        else
            stack="inertia"
        fi
    else
        # Default to API-only if no frontend framework detected
        stack="api"
    fi
    
    echo "$stack"
}

# Function to get test paths for a specific stack
get_test_paths_for_stack() {
    local stack=$1
    local paths=""
    
    # Check for custom test paths in config
    if [ -n "$CLAUDE_HOOKS_INERTIA_TEST_PATHS" ] && [[ "$stack" == "inertia"* ]]; then
        echo "$CLAUDE_HOOKS_INERTIA_TEST_PATHS"
        return
    fi
    
    case $stack in
        "livewire")
            paths="tests/Feature/Livewire tests/Unit/Livewire"
            ;;
        "filament")
            paths="tests/Feature/Filament tests/Feature/Livewire tests/Unit/Filament"
            ;;
        "inertia-vue")
            paths="tests/Feature/Pages tests/JavaScript resources/js/__tests__ resources/js/**/*.spec.js resources/js/**/*.test.js"
            ;;
        "inertia-react")
            paths="tests/Feature/Pages tests/JavaScript resources/js/__tests__ resources/js/**/*.spec.tsx resources/js/**/*.test.tsx resources/js/**/*.spec.jsx resources/js/**/*.test.jsx"
            ;;
        "api")
            paths="tests/Feature/Api tests/Unit"
            ;;
        *)
            paths="tests/Feature tests/Unit"
            ;;
    esac
    
    echo "$paths"
}

# Function to check if stack-specific checks are enabled
is_stack_enabled() {
    local stack=$1
    local env_var_name="CLAUDE_HOOKS_$(echo $stack | tr '[:lower:]' '[:upper:]' | tr '-' '_')_ENABLED"
    local enabled=$(eval echo \$$env_var_name)
    
    # Default to true if not explicitly disabled
    if [ -z "$enabled" ] || [ "$enabled" = "true" ] || [ "$enabled" = "1" ]; then
        return 0
    else
        return 1
    fi
}

# Function to load stack-specific module
load_stack_module() {
    local stack=$1
    local hooks_dir=$(dirname "${BASH_SOURCE[0]}")
    local module_path="$hooks_dir/stacks/laravel-${stack}.sh"
    
    if file_exists "$module_path"; then
        source "$module_path"
        return 0
    else
        return 1
    fi
}

# Export functions for use in other scripts
export -f command_exists
export -f file_exists
export -f dir_exists
export -f print_color
export -f composer_has_package
export -f npm_has_package
export -f detect_laravel_stack
export -f get_test_paths_for_stack
export -f is_stack_enabled
export -f load_stack_module