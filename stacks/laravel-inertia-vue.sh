#!/bin/bash

# Laravel Inertia + Vue stack-specific checks and configurations

# Stack-specific lint checks for Inertia + Vue
inertia_vue_lint_checks() {
    local file=$1
    local has_issues=false
    
    # Check for proper Inertia page component structure
    if [[ "$file" == *"resources/js/Pages/"* ]] && [[ "$file" == *.vue ]]; then
        # Check for script setup usage (Vue 3 best practice)
        if ! grep -q "<script setup" "$file" 2>/dev/null && grep -q "<script>" "$file" 2>/dev/null; then
            print_color "yellow" "ℹ️  Consider using <script setup> syntax in $file"
        fi
        
        # Check for layout definition
        if ! grep -qE "(definePageProps|layout:|Layout)" "$file" 2>/dev/null; then
            print_color "yellow" "ℹ️  Consider defining a layout for Inertia page $file"
        fi
    fi
    
    # Check for direct API calls from components (should use controllers)
    if [[ "$file" == *.vue ]] || [[ "$file" == *.js ]] || [[ "$file" == *.ts ]]; then
        if grep -qE "(axios\.|fetch\(|\\$\.ajax)" "$file" 2>/dev/null; then
            # Check if it's calling external APIs or internal endpoints
            if grep -qE "(axios\.(get|post|put|delete)\(['\"]\/|fetch\(['\"]\/)" "$file" 2>/dev/null; then
                print_color "yellow" "ℹ️  Consider using Inertia visits instead of direct API calls in $file"
            fi
        fi
    fi
    
    # Check PHP controllers for proper Inertia usage
    if [[ "$file" == *"app/Http/Controllers/"* ]]; then
        # Check for proper Inertia response usage
        if grep -q "return Inertia::render" "$file" 2>/dev/null; then
            # Check if props are properly structured
            if grep -qE "Inertia::render\([^,]+,\s*\[" "$file" 2>/dev/null; then
                # This is good - using array for props
                :
            elif grep -qE "Inertia::render\([^)]+\)" "$file" 2>/dev/null; then
                # Only component name, no props - this is fine
                :
            else
                print_color "yellow" "ℹ️  Check Inertia::render usage in $file"
            fi
        fi
        
        # Check for JSON responses that should be Inertia responses
        if grep -q "return response()->json" "$file" 2>/dev/null; then
            print_color "yellow" "ℹ️  Consider if this should be an Inertia response in $file"
        fi
    fi
    
    # Check for Vue 3 Composition API patterns
    if [[ "$file" == *.vue ]]; then
        # Check for Options API usage (not recommended for new code)
        if grep -qE "(export default \{|data\(\)|methods:|computed:|watch:)" "$file" 2>/dev/null && ! grep -q "<script setup" "$file" 2>/dev/null; then
            print_color "yellow" "ℹ️  Consider migrating to Composition API in $file"
        fi
    fi
    
    # Check for proper TypeScript usage if applicable
    if [[ "$file" == *.ts ]] || [[ "$file" == *.vue ]]; then
        if grep -q "<script setup lang=\"ts\"" "$file" 2>/dev/null || [[ "$file" == *.ts ]]; then
            # Check for any usage
            if grep -qE ": any|as any|<any>" "$file" 2>/dev/null; then
                print_color "yellow" "ℹ️  Avoid using 'any' type in TypeScript in $file"
            fi
        fi
    fi
    
    if $has_issues; then
        return 1
    else
        return 0
    fi
}

# Stack-specific test patterns for Inertia + Vue
inertia_vue_test_patterns() {
    echo "tests/Feature/Pages tests/JavaScript resources/js/__tests__ resources/js/**/*.spec.js resources/js/**/*.test.js tests/Unit/JavaScript"
}

# Stack-specific file patterns to test for Inertia + Vue
inertia_vue_should_test_file() {
    local file=$1
    
    # Test Vue components
    if [[ "$file" == *.vue ]]; then
        return 0
    fi
    
    # Test JavaScript/TypeScript files in resources
    if [[ "$file" == *"resources/js/"* ]] && ([[ "$file" == *.js ]] || [[ "$file" == *.ts ]]); then
        # Skip config files
        if [[ "$file" == *".config.js" ]] || [[ "$file" == *".config.ts" ]]; then
            return 1
        fi
        return 0
    fi
    
    # Test controllers that render Inertia pages
    if [[ "$file" == *"app/Http/Controllers/"* ]] && grep -q "Inertia::render" "$file" 2>/dev/null; then
        return 0
    fi
    
    return 1
}

# Additional helper to run Vue/JavaScript tests
inertia_vue_run_js_tests() {
    local test_command=""
    
    # Determine which test runner to use
    if file_exists "vitest.config.js" || file_exists "vitest.config.ts"; then
        test_command="npm run test"
    elif file_exists "jest.config.js"; then
        test_command="npm run test"
    elif grep -q "\"test\":" "package.json" 2>/dev/null; then
        test_command="npm run test"
    fi
    
    if [ -n "$test_command" ]; then
        echo "$test_command"
    fi
}

# Export functions
export -f inertia_vue_lint_checks
export -f inertia_vue_test_patterns
export -f inertia_vue_should_test_file
export -f inertia_vue_run_js_tests