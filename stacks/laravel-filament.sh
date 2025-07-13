#!/bin/bash

# Laravel Filament stack-specific checks and configurations

# Stack-specific lint checks for Filament
filament_lint_checks() {
    local file=$1
    local has_issues=false
    
    # Filament includes Livewire, so run Livewire checks too
    if command_exists livewire_lint_checks; then
        livewire_lint_checks "$file" || has_issues=true
    fi
    
    # Check for proper resource structure
    if [[ "$file" == *"app/Filament/Resources/"* ]]; then
        # Check for direct database queries in form/table methods
        if grep -qE "(public function form|public function table)" "$file"; then
            local method_content=$(awk '/public function (form|table)/{p=1} p&&/^[[:space:]]*\}/{p=0} p' "$file")
            
            if echo "$method_content" | grep -qE "(DB::|->get\(\)|->first\(\)|->find\(|->all\(\))" 2>/dev/null; then
                print_color "red" "❌ FORBIDDEN PATTERN: Direct database query in Filament resource method in $file"
                print_color "yellow" "   Use relationships or query callbacks instead"
                has_issues=true
            fi
        fi
        
        # Check for polling in tables (should use broadcasting)
        if grep -qE "->poll\(" "$file" 2>/dev/null; then
            print_color "red" "❌ FORBIDDEN PATTERN: Polling detected in Filament resource $file"
            print_color "yellow" "   Use Laravel Echo/Reverb for real-time updates"
            has_issues=true
        fi
    fi
    
    # Check for proper action classes
    if [[ "$file" == *"app/Filament/Actions/"* ]]; then
        # Ensure actions follow Filament conventions
        if ! grep -q "extends .*Action" "$file" 2>/dev/null && [[ "$file" == *.php ]]; then
            print_color "yellow" "ℹ️  Filament action should extend appropriate Action class in $file"
        fi
    fi
    
    # Check for enum usage instead of constants
    if [[ "$file" == *"app/Filament/"* ]]; then
        if grep -qE "const [A-Z_]+ = ['\"]" "$file" 2>/dev/null; then
            print_color "red" "❌ FORBIDDEN PATTERN: String constants detected in $file"
            print_color "yellow" "   Use Enum classes with getLabel(), getColor(), getIcon() methods"
            has_issues=true
        fi
    fi
    
    if $has_issues; then
        return 1
    else
        return 0
    fi
}

# Stack-specific test patterns for Filament
filament_test_patterns() {
    echo "tests/Feature/Filament tests/Feature/Livewire tests/Unit/Filament app/Filament"
}

# Stack-specific file patterns to test for Filament
filament_should_test_file() {
    local file=$1
    
    # Test Filament resources
    if [[ "$file" == *"app/Filament/Resources/"* ]]; then
        return 0
    fi
    
    # Test Filament pages
    if [[ "$file" == *"app/Filament/Pages/"* ]]; then
        return 0
    fi
    
    # Test Filament widgets
    if [[ "$file" == *"app/Filament/Widgets/"* ]]; then
        return 0
    fi
    
    # Also test Livewire components since Filament uses Livewire
    if command_exists livewire_should_test_file; then
        livewire_should_test_file "$file" && return 0
    fi
    
    return 1
}

# Export functions
export -f filament_lint_checks
export -f filament_test_patterns
export -f filament_should_test_file