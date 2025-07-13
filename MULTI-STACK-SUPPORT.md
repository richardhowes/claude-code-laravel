# Multi-Stack Support for Laravel Claude Code Hooks

This Laravel development system now supports multiple frontend stacks, automatically detecting and applying appropriate rules and checks for each stack.

## Supported Stacks

### 1. **Livewire** (Original)
- Server-side rendered components
- Real-time updates via Laravel Echo/Reverb
- Blade templates with Alpine.js

### 2. **Filament** (Original)
- Admin panel framework built on Livewire
- Resource-based architecture
- Form builders and table components

### 3. **Inertia + Vue** (New)
- Modern SPA with Vue 3 Composition API
- TypeScript support
- Server-side routing with client-side rendering

### 4. **Inertia + React** (New)
- Modern SPA with React function components
- TypeScript support
- React hooks and modern patterns

### 5. **API-only** (New)
- RESTful API development
- API resources and versioning
- No frontend framework

## How It Works

### Automatic Stack Detection

The system automatically detects your Laravel stack by checking installed packages:

```bash
# Detection logic:
- Filament: Checks for filament/filament in composer.json
- Livewire: Checks for livewire/livewire in composer.json
- Inertia + Vue: Checks for inertiajs/inertia-laravel + @inertiajs/vue3
- Inertia + React: Checks for inertiajs/inertia-laravel + @inertiajs/react
- API-only: No frontend packages detected
```

### Stack-Specific Checks

Each stack has its own set of rules and checks:

#### Livewire Stack
- No database queries in render() methods
- No polling (use Laravel Echo instead)
- Proper action method naming
- Blade template standards

#### Filament Stack
- Inherits all Livewire checks
- Resource structure validation
- No polling in tables
- Enum usage for labels/colors/icons

#### Inertia + Vue Stack
- Vue 3 Composition API enforcement
- TypeScript requirements
- No direct API calls (use Inertia visits)
- Proper page component structure
- Form handling with useForm composable

#### Inertia + React Stack
- Function components only (no classes)
- React hooks best practices
- TypeScript requirements
- No direct API calls (use Inertia visits)
- Proper page component structure

#### API-only Stack
- RESTful conventions
- API resource usage
- Proper status codes
- Version handling recommendations

## Configuration

### Force a Specific Stack

If auto-detection doesn't work or you want to override it:

```bash
# In .claude-hooks-config.sh
export CLAUDE_HOOKS_LARAVEL_STACK="inertia-vue"
```

### Enable/Disable Stack Checks

Control which stack-specific checks are active:

```bash
# In .claude-hooks-config.sh
export CLAUDE_HOOKS_LIVEWIRE_ENABLED=true
export CLAUDE_HOOKS_FILAMENT_ENABLED=true
export CLAUDE_HOOKS_INERTIA_VUE_ENABLED=true
export CLAUDE_HOOKS_INERTIA_REACT_ENABLED=true
```

### Custom Test Paths

For Inertia projects with custom test structures:

```bash
# In .claude-hooks-config.sh
export CLAUDE_HOOKS_INERTIA_TEST_PATHS="resources/js/__tests__,tests/JavaScript"
```

## File Structure by Stack

### Livewire/Filament
```
app/Livewire/           # Livewire components
app/Filament/           # Filament resources
resources/views/        # Blade templates
tests/Feature/Livewire/ # Component tests
```

### Inertia + Vue
```
resources/js/Pages/      # Inertia page components
resources/js/Components/ # Reusable Vue components
resources/js/Composables/# Vue composables
resources/js/Layouts/    # Persistent layouts
tests/JavaScript/        # Vitest tests
```

### Inertia + React
```
resources/js/Pages/      # Inertia page components
resources/js/Components/ # Reusable React components
resources/js/Hooks/      # Custom React hooks
resources/js/Layouts/    # Persistent layouts
tests/JavaScript/        # Jest tests
```

## Testing Integration

The test runner automatically adapts to your stack:

### PHP Tests (All Stacks)
- Uses Pest for all PHP testing
- Blocks PHPUnit syntax
- Runs focused tests for edited files

### JavaScript Tests (Inertia Stacks)
- Detects and runs Vitest for Vue
- Detects and runs Jest for React
- Integrates with npm test scripts
- Runs both PHP and JS tests for full-stack changes

## Migration Guide

### From Livewire to Inertia

1. Install Inertia packages:
   ```bash
   composer require inertiajs/inertia-laravel
   npm install @inertiajs/vue3  # or @inertiajs/react
   ```

2. The hooks will automatically detect the new stack

3. Follow the new rules enforced by the system

### Adding to Existing Projects

1. Copy the updated hooks to your project
2. The system will auto-detect your stack
3. Optionally create `.claude-hooks-config.sh` to customize

## Troubleshooting

### Stack Not Detected

If your stack isn't being detected properly:

1. Check that packages are in composer.json/package.json
2. Force the stack in configuration:
   ```bash
   export CLAUDE_HOOKS_LARAVEL_STACK="your-stack"
   ```

### Custom Project Structures

For non-standard project structures:

1. Override test paths in configuration
2. Disable specific checks that don't apply
3. Create custom ignore patterns in `.claude-hooks-ignore`

### Mixed Stacks

For projects using multiple stacks (e.g., Livewire + Inertia):

1. The system will detect the primary stack
2. You can enable multiple stack checks:
   ```bash
   export CLAUDE_HOOKS_LIVEWIRE_ENABLED=true
   export CLAUDE_HOOKS_INERTIA_VUE_ENABLED=true
   ```

## Contributing

To add support for a new stack:

1. Create a new stack module in `stacks/laravel-{stack}.sh`
2. Implement the required functions:
   - `{stack}_lint_checks()`
   - `{stack}_test_patterns()`
   - `{stack}_should_test_file()`
3. Update detection logic in `common-helpers.sh`
4. Add documentation

## Benefits

- **Automatic Adaptation**: No manual configuration needed
- **Stack-Specific Rules**: Each stack gets appropriate checks
- **Backward Compatible**: Existing projects continue working
- **Extensible**: Easy to add new stacks
- **Consistent Quality**: All stacks follow Laravel best practices