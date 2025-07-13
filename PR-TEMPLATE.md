# Pull Request: Add Multi-Stack Support for Laravel Projects

## Summary

This PR adds automatic multi-stack support to the Laravel Claude Code development system, enabling it to work seamlessly with different Laravel frontend stacks including Inertia (Vue/React) and API-only projects, while maintaining full backward compatibility with existing Livewire/Filament setups.

## Changes

### Core Features
- **Automatic Stack Detection**: Detects Laravel frontend stack based on installed packages
- **Modular Architecture**: Stack-specific rules and checks in separate modules
- **Dynamic Test Paths**: Test runner adapts to different stack structures
- **Configuration Options**: Manual overrides and stack-specific settings

### New Files
- `common-helpers.sh`: Stack detection and utility functions
- `stacks/`: Directory with stack-specific modules
  - `laravel-livewire.sh`: Livewire-specific checks
  - `laravel-filament.sh`: Filament-specific checks
  - `laravel-inertia-vue.sh`: Inertia + Vue checks
  - `laravel-inertia-react.sh`: Inertia + React checks
  - `laravel-api.sh`: API-only project checks
- `MULTI-STACK-SUPPORT.md`: Comprehensive documentation
- `claude-md-stacks/`: Stack-specific development guidelines

### Modified Files
- `hooks/smart-lint.sh`: Updated to use modular stack system
- `hooks/smart-test.sh`: Updated to use dynamic test paths
- `hooks/example-claude-hooks-config.sh`: Added stack configuration options
- `README.md`: Updated with multi-stack information

## Supported Stacks

1. **Livewire** (original) - Server-side rendering with real-time updates
2. **Filament** (original) - Admin panel framework
3. **Inertia + Vue** (new) - SPA with Vue 3 Composition API
4. **Inertia + React** (new) - SPA with React hooks
5. **API-only** (new) - RESTful API development

## Benefits

- **Zero Configuration**: Works out of the box with auto-detection
- **Backward Compatible**: Existing projects continue working unchanged
- **Stack-Appropriate Rules**: Each stack gets relevant checks and patterns
- **Extensible Design**: Easy to add support for new stacks
- **Improved DX**: Better support for modern Laravel development patterns

## Testing

The implementation has been tested with:
- [x] Existing Livewire projects (backward compatibility)
- [x] Existing Filament projects (backward compatibility)
- [ ] New Inertia + Vue projects
- [ ] New Inertia + React projects
- [ ] API-only projects

## Breaking Changes

None. The implementation is fully backward compatible.

## Configuration Examples

```bash
# Force a specific stack (optional)
export CLAUDE_HOOKS_LARAVEL_STACK="inertia-vue"

# Disable specific stack checks (optional)
export CLAUDE_HOOKS_INERTIA_VUE_ENABLED=false

# Custom test paths for Inertia projects (optional)
export CLAUDE_HOOKS_INERTIA_TEST_PATHS="resources/js/__tests__,tests/JavaScript"
```

## Future Enhancements

- Support for additional stacks (Vue without Inertia, Alpine.js only)
- Stack-specific command snippets
- Enhanced JavaScript/TypeScript linting for frontend stacks
- Integration with Vite/Mix detection

## Checklist

- [x] Code follows project conventions
- [x] All existing tests pass
- [x] Documentation is complete
- [x] Backward compatibility maintained
- [ ] Tested on real projects
- [ ] Community feedback incorporated

## Notes for Reviewers

- The modular design allows easy addition of new stacks without modifying core files
- Stack detection is based on package detection, which is reliable but can be overridden
- All new features are opt-in through auto-detection or configuration
- The implementation follows the existing philosophy of zero-tolerance quality checks

Please review and let me know if any adjustments are needed to better fit the project's goals and standards.