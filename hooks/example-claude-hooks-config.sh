#!/usr/bin/env bash
# Example .claude-hooks-config.sh - Project-specific Claude hooks configuration
#
# Copy this file to your project root as .claude-hooks-config.sh and uncomment
# the settings you want to override.
#
# This file is sourced by smart-lint.sh, so it can override any setting.

# ============================================================================
# COMMON OVERRIDES
# ============================================================================

# Disable all hooks for this project
# export CLAUDE_HOOKS_ENABLED=false

# Enable debug output for troubleshooting
# export CLAUDE_HOOKS_DEBUG=1

# Stop on first issue instead of running all checks
# export CLAUDE_HOOKS_FAIL_FAST=true

# ============================================================================
# LANGUAGE-SPECIFIC OVERRIDES
# ============================================================================

# Disable checks for specific languages
# export CLAUDE_HOOKS_LARAVEL_ENABLED=false
# export CLAUDE_HOOKS_PHP_ENABLED=false
# export CLAUDE_HOOKS_JS_ENABLED=false

# ============================================================================
# LARAVEL-SPECIFIC SETTINGS
# ============================================================================

# Laravel/PHP quality tools
# export CLAUDE_HOOKS_LARAVEL_LINT_CMD="composer lint"
# export CLAUDE_HOOKS_LARAVEL_FORMAT_CMD="composer format"
# export CLAUDE_HOOKS_LARAVEL_REFACTOR_CMD="composer refactor"
# export CLAUDE_HOOKS_LARAVEL_ANNOTATE_CMD="composer refactor:annotate"
# export CLAUDE_HOOKS_LARAVEL_TEST_CMD="composer test"

# ============================================================================
# LARAVEL STACK DETECTION
# ============================================================================

# Force a specific Laravel stack (auto-detected by default)
# Options: livewire, filament, inertia-vue, inertia-react, api
# export CLAUDE_HOOKS_LARAVEL_STACK="inertia-vue"

# Enable/disable specific stack checks
# export CLAUDE_HOOKS_LIVEWIRE_ENABLED=true
# export CLAUDE_HOOKS_FILAMENT_ENABLED=true
# export CLAUDE_HOOKS_INERTIA_VUE_ENABLED=true
# export CLAUDE_HOOKS_INERTIA_REACT_ENABLED=true

# Custom test paths for Inertia projects
# export CLAUDE_HOOKS_INERTIA_TEST_PATHS="resources/js/__tests__,tests/JavaScript"

# ============================================================================
# STACK-SPECIFIC SETTINGS
# ============================================================================

# Forbidden patterns for Laravel projects (applies to all stacks)
# export CLAUDE_HOOKS_LARAVEL_CHECK_RAW_SQL=true
# export CLAUDE_HOOKS_LARAVEL_CHECK_DIRECT_GLOBALS=true
# export CLAUDE_HOOKS_LARAVEL_CHECK_INLINE_COMMENTS=true
# export CLAUDE_HOOKS_LARAVEL_CHECK_CONSTANTS=true

# Livewire/Filament specific checks
# export CLAUDE_HOOKS_LARAVEL_CHECK_LIVEWIRE_RENDER=true
# export CLAUDE_HOOKS_LARAVEL_CHECK_POLLING=true
# export CLAUDE_HOOKS_LARAVEL_CHECK_FILAMENT_PATTERNS=true

# Inertia specific checks
# export CLAUDE_HOOKS_CHECK_INERTIA_PAGE_STRUCTURE=true
# export CLAUDE_HOOKS_CHECK_VUE_COMPOSITION_API=true
# export CLAUDE_HOOKS_CHECK_REACT_HOOKS=true

# ============================================================================
# PERFORMANCE TUNING
# ============================================================================

# Limit file checking for very large repos
# export CLAUDE_HOOKS_MAX_FILES=500

# ============================================================================
# PROJECT-SPECIFIC EXAMPLES
# ============================================================================

# Example: Different settings for different environments
# if [[ "$USER" == "ci" ]]; then
#     export CLAUDE_HOOKS_FAIL_FAST=true
# fi

