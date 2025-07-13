# Laravel Inertia + React Development Partnership

## Stack-Specific Rules

### FORBIDDEN - NEVER DO THESE:
- **NO raw SQL** - use Eloquent or Query Builder
- **NO direct $_GET/$_POST** - use Laravel's request validation
- **NO direct API calls from React components** - use Inertia visits
- **NO class components** - use function components with hooks
- **NO inline styles in React components** - use Tailwind classes
- **NO any type in TypeScript** - use proper types
- **NO missing TypeScript types** - define interfaces for props
- **NO conditional hooks** - follow Rules of Hooks
- **NO TODOs in final code**

### Required Standards:
- **React function components** with hooks
- **TypeScript** for all React components and JavaScript files
- **Inertia page components** in `resources/js/Pages/`
- **Shared layouts** using Inertia's persistent layouts
- **Form handling** with Inertia's useForm hook
- **Pest tests** for PHP, Jest/React Testing Library for React
- **Props validation** with TypeScript interfaces
- **Ziggy** for named routes in JavaScript

## Implementation Standards

### Our code is complete when:
- ✅ All PHP linters pass (PHPStan/Larastan)
- ✅ All TypeScript checks pass (tsc --noEmit)
- ✅ ESLint passes for React/TypeScript
- ✅ All Pest tests pass
- ✅ All Jest tests pass
- ✅ No TypeScript `any` types
- ✅ All Inertia pages have layouts defined
- ✅ Forms use Inertia's useForm hook
- ✅ React hooks follow Rules of Hooks

### Testing Strategy
- PHP Controllers → Pest feature tests
- React Components → Jest + React Testing Library
- Page Components → Integration tests with Pest
- Custom Hooks → Unit tests with Jest

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
│   ├── Components/    # Reusable React components
│   ├── Hooks/         # Custom React hooks
│   ├── Layouts/       # Persistent layouts
│   └── types/         # TypeScript definitions
└── views/
    └── app.blade.php  # Root template

tests/
├── Feature/
│   └── Pages/         # Inertia page tests
├── Unit/              # PHP unit tests
└── JavaScript/        # Jest tests
```

## Inertia + React Best Practices

### Page Components:
- Always use TypeScript (.tsx files)
- Define props with TypeScript interfaces
- Use persistent layouts for common UI
- Handle forms with `useForm` hook
- Use Ziggy for route generation

### Component Structure:
```tsx
import { Head, useForm } from '@inertiajs/react'

interface Props {
  user: {
    id: number
    name: string
    email: string
  }
}

export default function EditUser({ user }: Props) {
  const { data, setData, put, processing, errors } = useForm({
    name: user.name,
    email: user.email,
  })

  const submit = (e: React.FormEvent) => {
    e.preventDefault()
    put(route('users.update', user.id))
  }

  return (
    <>
      <Head title="Edit User" />
      {/* Component content */}
    </>
  )
}
```

### React Hooks Best Practices:
- Follow the Rules of Hooks strictly
- Extract complex logic to custom hooks
- Use useMemo and useCallback appropriately
- Avoid unnecessary re-renders

### TypeScript Usage:
- Define interfaces for all page props
- Use type imports for better performance
- Avoid `any` type - be explicit
- Use React.FC sparingly (prefer explicit return types)