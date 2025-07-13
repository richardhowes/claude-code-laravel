#!/bin/bash

# Laravel Inertia + React stack-specific checks and configurations

# Stack-specific lint checks for Inertia + React
inertia_react_lint_checks() {
    local file=$1
    local has_issues=false
    
    # Check for proper Inertia page component structure
    if [[ "$file" == *"resources/js/Pages/"* ]] && ([[ "$file" == *.jsx ]] || [[ "$file" == *.tsx ]]); then
        # Check for proper React component patterns
        if ! grep -qE "(function|const) .* = .* => {|export default function" "$file" 2>/dev/null; then
            print_color "yellow" "ℹ️  Use function components in React in $file"
        fi
        
        # Check for layout usage
        if ! grep -qE "\.layout = |Layout>|layout:" "$file" 2>/dev/null; then
            print_color "yellow" "ℹ️  Consider defining a layout for Inertia page $file"
        fi
    fi
    
    # Check for React hooks usage
    if [[ "$file" == *.jsx ]] || [[ "$file" == *.tsx ]]; then
        # Check for class components (discouraged)
        if grep -qE "class .* extends (React\.Component|Component)" "$file" 2>/dev/null; then
            print_color "yellow" "ℹ️  Consider using function components with hooks in $file"
        fi
        
        # Check for hooks rules violations
        if grep -qE "(useState|useEffect|useMemo|useCallback)" "$file" 2>/dev/null; then
            # Basic check for hooks in conditionals (very basic, not comprehensive)
            if grep -qE "if.*use[A-Z]" "$file" 2>/dev/null; then
                print_color "red" "❌ Possible React hooks rule violation in $file"
                print_color "yellow" "   Hooks must not be called conditionally"
                has_issues=true
            fi
        fi
    fi
    
    # Check for direct API calls from components
    if [[ "$file" == *.jsx ]] || [[ "$file" == *.tsx ]] || [[ "$file" == *.js ]] || [[ "$file" == *.ts ]]; then
        if grep -qE "(axios\.|fetch\(|\\$\.ajax)" "$file" 2>/dev/null; then
            if grep -qE "(axios\.(get|post|put|delete)\(['\"]\/|fetch\(['\"]\/)" "$file" 2>/dev/null; then
                print_color "yellow" "ℹ️  Consider using Inertia visits instead of direct API calls in $file"
            fi
        fi
    fi
    
    # Check PHP controllers for proper Inertia usage (same as Vue)
    if [[ "$file" == *"app/Http/Controllers/"* ]]; then
        if grep -q "return Inertia::render" "$file" 2>/dev/null; then
            if grep -qE "Inertia::render\([^,]+,\s*\[" "$file" 2>/dev/null; then
                :
            elif grep -qE "Inertia::render\([^)]+\)" "$file" 2>/dev/null; then
                :
            else
                print_color "yellow" "ℹ️  Check Inertia::render usage in $file"
            fi
        fi
        
        if grep -q "return response()->json" "$file" 2>/dev/null; then
            print_color "yellow" "ℹ️  Consider if this should be an Inertia response in $file"
        fi
    fi
    
    # Check for TypeScript usage
    if [[ "$file" == *.tsx ]] || [[ "$file" == *.ts ]]; then
        # Check for any usage
        if grep -qE ": any|as any|<any>" "$file" 2>/dev/null; then
            print_color "yellow" "ℹ️  Avoid using 'any' type in TypeScript in $file"
        fi
        
        # Check for proper prop types
        if [[ "$file" == *"resources/js/Pages/"* ]] && ! grep -qE "(interface|type) .*(Props|PageProps)" "$file" 2>/dev/null; then
            print_color "yellow" "ℹ️  Consider defining TypeScript interfaces for props in $file"
        fi
    fi
    
    # Check for React-specific patterns
    if [[ "$file" == *.jsx ]] || [[ "$file" == *.tsx ]]; then
        # Check for proper key props in lists
        if grep -qE "\.map\(" "$file" 2>/dev/null && ! grep -qE "key=" "$file" 2>/dev/null; then
            print_color "yellow" "ℹ️  Ensure list items have key props in $file"
        fi
    fi
    
    if $has_issues; then
        return 1
    else
        return 0
    fi
}

# Stack-specific test patterns for Inertia + React
inertia_react_test_patterns() {
    echo "tests/Feature/Pages tests/JavaScript resources/js/__tests__ resources/js/**/*.spec.tsx resources/js/**/*.test.tsx resources/js/**/*.spec.jsx resources/js/**/*.test.jsx tests/Unit/JavaScript"
}

# Stack-specific file patterns to test for Inertia + React
inertia_react_should_test_file() {
    local file=$1
    
    # Test React components
    if [[ "$file" == *.jsx ]] || [[ "$file" == *.tsx ]]; then
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

# Additional helper to run React/JavaScript tests
inertia_react_run_js_tests() {
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
export -f inertia_react_lint_checks
export -f inertia_react_test_patterns
export -f inertia_react_should_test_file
export -f inertia_react_run_js_tests