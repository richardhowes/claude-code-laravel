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

# Forbidden patterns for Laravel projects
# export CLAUDE_HOOKS_LARAVEL_CHECK_RAW_SQL=true
# export CLAUDE_HOOKS_LARAVEL_CHECK_DIRECT_GLOBALS=true
# export CLAUDE_HOOKS_LARAVEL_CHECK_POLLING=true
# export CLAUDE_HOOKS_LARAVEL_CHECK_INLINE_COMMENTS=true
# export CLAUDE_HOOKS_LARAVEL_CHECK_CONSTANTS=true

# Livewire/Filament specific checks
# export CLAUDE_HOOKS_LARAVEL_CHECK_LIVEWIRE_RENDER=true
# export CLAUDE_HOOKS_LARAVEL_CHECK_FILAMENT_PATTERNS=true

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

