# Inertia + Vue Quick Start Guide

## Setting Up for Inertia + Vue Development

### 1. Install the Updated Hooks

```bash
# From this directory
./install.sh

# Or manually
cp -r . ~/.claude
chmod +x ~/.claude/hooks/*.sh
```

### 2. Automatic Detection

When you open a Laravel project with Inertia + Vue, the system automatically detects it:

```bash
cd ~/Projects/my-inertia-vue-app
claude-code

# The hooks will detect:
# - inertiajs/inertia-laravel in composer.json
# - @inertiajs/vue3 in package.json
# → Activates Inertia + Vue stack
```

### 3. What Gets Enforced

#### Vue Components
- ✅ Must use `<script setup lang="ts">` syntax
- ✅ No Options API allowed
- ✅ TypeScript required for all components
- ✅ Proper prop type definitions

#### Inertia Pages
- ✅ Located in `resources/js/Pages/`
- ✅ Must define layouts properly
- ✅ Use `useForm` composable for forms
- ✅ No direct API calls - use Inertia visits

#### Example Page Component
```vue
<script setup lang="ts">
import { Head, useForm } from '@inertiajs/vue3'
import AppLayout from '@/Layouts/AppLayout.vue'

interface Props {
  user: {
    id: number
    name: string
    email: string
  }
}

defineProps<Props>()

const form = useForm({
  name: '',
  email: ''
})

const submit = () => {
  form.post(route('users.store'))
}
</script>

<template>
  <AppLayout>
    <Head title="Create User" />
    
    <form @submit.prevent="submit">
      <!-- Form fields -->
    </form>
  </AppLayout>
</template>
```

### 4. Testing

The system runs both PHP and JavaScript tests:

```bash
# When you edit a Vue component
resources/js/Pages/Users/Create.vue

# The hooks will:
1. Run ESLint with Vue rules
2. Run TypeScript checks
3. Run Vitest for component tests
4. Check for related PHP controller tests
```

### 5. Custom Configuration (Optional)

Create `.claude-hooks-config.sh` in your project:

```bash
# Force Inertia + Vue mode (if detection fails)
export CLAUDE_HOOKS_LARAVEL_STACK="inertia-vue"

# Custom test paths
export CLAUDE_HOOKS_INERTIA_TEST_PATHS="tests/Vue,resources/js/tests"

# Disable specific checks if needed
export CLAUDE_HOOKS_CHECK_VUE_COMPOSITION_API=false
```

### 6. Common Enforcements

#### ❌ This will be blocked:
```vue
<!-- Options API -->
<script>
export default {
  data() {
    return { count: 0 }
  }
}
</script>

<!-- Direct API call -->
<script setup>
import axios from 'axios'
const users = await axios.get('/api/users')
</script>

<!-- Missing TypeScript -->
<script setup>
const props = defineProps(['user'])
</script>
```

#### ✅ This is correct:
```vue
<script setup lang="ts">
import { router } from '@inertiajs/vue3'

interface Props {
  users: User[]
}

defineProps<Props>()

// Use Inertia for navigation
const deleteUser = (id: number) => {
  router.delete(route('users.destroy', id))
}
</script>
```

### 7. Development Workflow

1. **Edit a file** → Hooks run automatically
2. **TypeScript errors** → Must fix before continuing
3. **Vue linting issues** → Auto-fixed when possible
4. **Test failures** → Blocked until tests pass
5. **All green** → Continue development

### 8. Benefits for Inertia + Vue

- **Type Safety**: Enforced TypeScript for all components
- **Modern Patterns**: Composition API only
- **Inertia Best Practices**: Proper data flow patterns
- **Integrated Testing**: Both PHP and Vue tests run together
- **Consistent Quality**: Same high standards as Livewire/Filament

## Troubleshooting

### Stack Not Detected

Check packages are installed:
```bash
composer show inertiajs/inertia-laravel
npm list @inertiajs/vue3
```

### Force Stack Mode
```bash
# In .claude-hooks-config.sh
export CLAUDE_HOOKS_LARAVEL_STACK="inertia-vue"
```

### Disable Vue Checks Temporarily
```bash
export CLAUDE_HOOKS_INERTIA_VUE_ENABLED=false
```

## Next Steps

1. Start coding - the hooks handle the rest!
2. Follow the enforced patterns for consistency
3. Let the automated checks guide you
4. Enjoy faster, cleaner development

The system is designed to make Inertia + Vue development as smooth and error-free as possible while maintaining Laravel best practices.