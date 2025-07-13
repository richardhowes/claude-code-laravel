# Laravel Inertia + Vue Development Partnership

## Stack-Specific Rules

### FORBIDDEN - NEVER DO THESE:
- **NO raw SQL** - use Eloquent or Query Builder
- **NO direct $_GET/$_POST** - use Laravel's request validation
- **NO direct API calls from Vue components** - use Inertia visits
- **NO Options API in Vue** - use Composition API with `<script setup>`
- **NO inline styles in Vue components** - use Tailwind classes
- **NO any type in TypeScript** - use proper types
- **NO missing TypeScript types** - define interfaces for props
- **NO TODOs in final code**

### Required Standards:
- **Vue 3 Composition API** with `<script setup>` syntax
- **TypeScript** for all Vue components and JavaScript files
- **Inertia page components** in `resources/js/Pages/`
- **Shared layouts** using Inertia's persistent layouts
- **Form handling** with Inertia's form helpers
- **Pest tests** for PHP, Vitest for Vue components
- **Props validation** with TypeScript interfaces
- **Ziggy** for named routes in JavaScript

## Implementation Standards

### Our code is complete when:
- ✅ All PHP linters pass (PHPStan/Larastan)
- ✅ All TypeScript checks pass (tsc --noEmit)
- ✅ ESLint passes for Vue/TypeScript
- ✅ All Pest tests pass
- ✅ All Vitest tests pass
- ✅ No TypeScript `any` types
- ✅ All Inertia pages have layouts defined
- ✅ Forms use Inertia's useForm composable

### Testing Strategy
- PHP Controllers → Pest feature tests
- Vue Components → Vitest component tests
- Page Components → Integration tests with Pest
- Composables → Unit tests with Vitest

### Project Structure
```
app/
├── Http/
│   └── Controllers/     # Return Inertia::render()
├── Models/             # Eloquent models
└── Services/           # Business logic

resources/
├── js/
│   ├── Pages/         # Inertia page components
│   ├── Components/    # Reusable Vue components
│   ├── Composables/   # Vue composables
│   ├── Layouts/       # Persistent layouts
│   └── types/         # TypeScript definitions
└── views/
    └── app.blade.php  # Root template

tests/
├── Feature/
│   └── Pages/         # Inertia page tests
├── Unit/              # PHP unit tests
└── JavaScript/        # Vitest tests
```

## Inertia + Vue Best Practices

### Page Components:
- Always use `<script setup lang="ts">`
- Define props with TypeScript interfaces
- Use persistent layouts for common UI
- Handle forms with `useForm` composable
- Use Ziggy for route generation

### Data Flow:
- Controllers pass props via Inertia::render()
- Use Inertia's partial reloads for efficiency
- Implement proper error handling
- Use shared data for common props

### Form Handling:
```vue
<script setup lang="ts">
import { useForm } from '@inertiajs/vue3'

const form = useForm({
  name: '',
  email: ''
})

const submit = () => {
  form.post(route('users.store'))
}
</script>
```

### TypeScript Usage:
- Define interfaces for all page props
- Use type imports for better performance
- Avoid `any` type - be explicit
- Use Vue's PropType when needed