#!/bin/bash

# Laravel API-only stack-specific checks and configurations

# Stack-specific lint checks for API-only Laravel
api_lint_checks() {
    local file=$1
    local has_issues=false
    
    # Check for API controllers
    if [[ "$file" == *"app/Http/Controllers/"* ]]; then
        # Check for proper API responses
        if grep -q "return view(" "$file" 2>/dev/null; then
            print_color "yellow" "ℹ️  API controller returning view in $file - consider returning JSON"
        fi
        
        # Check for resource usage
        if grep -q "return response()->json" "$file" 2>/dev/null; then
            # Check if it's returning raw arrays/models instead of resources
            if ! grep -qE "(Resource::|JsonResource|->toArray\(\))" "$file" 2>/dev/null; then
                print_color "yellow" "ℹ️  Consider using API Resources for consistent responses in $file"
            fi
        fi
        
        # Check for proper status codes
        if grep -qE "return response\(\)->json\([^,)]+\)" "$file" 2>/dev/null; then
            print_color "yellow" "ℹ️  Consider specifying HTTP status codes in API responses in $file"
        fi
    fi
    
    # Check for API routes
    if [[ "$file" == *"routes/api.php" ]]; then
        # Check for versioning
        if ! grep -qE "(prefix\(['\"]v[0-9]|group\(.*/v[0-9])" "$file" 2>/dev/null; then
            print_color "yellow" "ℹ️  Consider implementing API versioning in $file"
        fi
        
        # Check for resource routes
        if grep -q "Route::" "$file" 2>/dev/null && ! grep -q "apiResource" "$file" 2>/dev/null; then
            print_color "yellow" "ℹ️  Consider using Route::apiResource for RESTful routes in $file"
        fi
    fi
    
    # Check for proper request validation
    if [[ "$file" == *"app/Http/Requests/"* ]]; then
        # Check for authorize method
        if ! grep -q "public function authorize" "$file" 2>/dev/null; then
            print_color "yellow" "ℹ️  Missing authorize() method in Form Request $file"
        fi
        
        # Check for API-specific validation
        if ! grep -q "public function messages" "$file" 2>/dev/null; then
            print_color "yellow" "ℹ️  Consider adding custom error messages for API in $file"
        fi
    fi
    
    # Check for API resources
    if [[ "$file" == *"app/Http/Resources/"* ]]; then
        # Check for proper resource structure
        if grep -q "extends JsonResource" "$file" 2>/dev/null; then
            if ! grep -q "public function toArray" "$file" 2>/dev/null; then
                print_color "red" "❌ Missing toArray() method in API Resource $file"
                has_issues=true
            fi
        fi
    fi
    
    # Check for middleware usage
    if [[ "$file" == *"app/Http/Kernel.php" ]] || [[ "$file" == *"app/Http/Middleware/"* ]]; then
        # Check for API throttling
        if [[ "$file" == *"Kernel.php" ]] && ! grep -q "throttle:api" "$file" 2>/dev/null; then
            print_color "yellow" "ℹ️  Consider implementing API rate limiting in $file"
        fi
    fi
    
    # Check for proper exception handling
    if [[ "$file" == *"app/Exceptions/Handler.php" ]]; then
        # Check for API-specific exception handling
        if ! grep -qE "(expectsJson|wantsJson)" "$file" 2>/dev/null; then
            print_color "yellow" "ℹ️  Consider adding API-specific exception handling in $file"
        fi
    fi
    
    if $has_issues; then
        return 1
    else
        return 0
    fi
}

# Stack-specific test patterns for API-only
api_test_patterns() {
    echo "tests/Feature/Api tests/Feature/Http tests/Unit app/Http/Controllers/Api"
}

# Stack-specific file patterns to test for API-only
api_should_test_file() {
    local file=$1
    
    # Test API controllers
    if [[ "$file" == *"app/Http/Controllers/"*"Api"* ]] || [[ "$file" == *"app/Http/Controllers/API/"* ]]; then
        return 0
    fi
    
    # Test API resources
    if [[ "$file" == *"app/Http/Resources/"* ]]; then
        return 0
    fi
    
    # Test API requests
    if [[ "$file" == *"app/Http/Requests/"* ]]; then
        return 0
    fi
    
    # Test API middleware
    if [[ "$file" == *"app/Http/Middleware/"* ]]; then
        return 0
    fi
    
    # Test API routes
    if [[ "$file" == *"routes/api.php" ]]; then
        return 0
    fi
    
    return 1
}

# Export functions
export -f api_lint_checks
export -f api_test_patterns
export -f api_should_test_file