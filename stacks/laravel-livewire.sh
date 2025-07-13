#!/bin/bash

# Laravel Livewire stack-specific checks and configurations

# Stack-specific lint checks for Livewire
livewire_lint_checks() {
    local file=$1
    local has_issues=false
    
    # Check for database queries in render methods
    if [[ "$file" == *"app/Livewire/"* ]] || [[ "$file" == *"app/Http/Livewire/"* ]]; then
        if grep -q "public function render" "$file"; then
            # Look for DB queries in render method
            local render_start=$(grep -n "public function render" "$file" | cut -d: -f1)
            local render_content=$(sed -n "${render_start},/^[[:space:]]*}/p" "$file")
            
            if echo "$render_content" | grep -qE "(DB::|->get\(\)|->first\(\)|->find\(|->all\(\)|->paginate\()" 2>/dev/null; then
                print_color "red" "❌ FORBIDDEN PATTERN: Database query in Livewire render method in $file"
                print_color "yellow" "   Move queries to computed properties or component methods"
                has_issues=true
            fi
        fi
    fi
    
    # Check for polling usage (should use Laravel Echo instead)
    if grep -qE "wire:poll|wire:poll\." "$file" 2>/dev/null; then
        print_color "red" "❌ FORBIDDEN PATTERN: Polling detected in $file"
        print_color "yellow" "   Use Laravel Echo/Reverb for real-time updates"
        has_issues=true
    fi
    
    # Check for proper action methods
    if [[ "$file" == *"app/Livewire/"* ]] || [[ "$file" == *"app/Http/Livewire/"* ]]; then
        # Check if public methods that aren't lifecycle hooks use proper naming
        if grep -qE "public function [a-z]" "$file" 2>/dev/null; then
            # Exclude common lifecycle methods
            local public_methods=$(grep -E "public function [a-z]" "$file" | grep -vE "(mount|render|updated|updating|hydrate|dehydrate|boot)")
            if [ -n "$public_methods" ]; then
                # This is just a warning, not a blocking error
                print_color "yellow" "ℹ️  Consider using action naming convention for Livewire methods in $file"
            fi
        fi
    fi
    
    if $has_issues; then
        return 1
    else
        return 0
    fi
}

# Stack-specific test patterns for Livewire
livewire_test_patterns() {
    echo "tests/Feature/Livewire tests/Unit/Livewire app/Livewire app/Http/Livewire"
}

# Stack-specific file patterns to test for Livewire
livewire_should_test_file() {
    local file=$1
    
    # Test Livewire components
    if [[ "$file" == *"app/Livewire/"* ]] || [[ "$file" == *"app/Http/Livewire/"* ]]; then
        return 0
    fi
    
    # Test Livewire-related files
    if [[ "$file" == *"resources/views/livewire/"* ]]; then
        return 0
    fi
    
    return 1
}

# Export functions
export -f livewire_lint_checks
export -f livewire_test_patterns
export -f livewire_should_test_file