# Lifestlye Manager

Lifestyle Manager is a project for managing your daily activities, health, and wellness.

## Fitness TODO

- `TODO` Must fully seed the database with mock data.

Refactor dialogs into composables.

```ts
export function useWorkoutDialogs() {
  const $q = useQuasar()

  async function openInspectWorkoutDialog(id: IdType) {
    const { DialogFitnessInspectWorkout } = await import('#components')
    $q.dialog({
      component: DialogFitnessInspectWorkout,
      componentProps: { id },
    })
  }

  return { openWorkoutDialog }
}
```

Get table dialogs working for CRUD operations.

- All inspect dialogs

The following options should all be on the data tables:

- `Create`
- `Start` (Workout/Exercise)
- `Charts`
- `Inspect`
- `Edit`
- `Delete`

Try Observable Plot for Charts:

```sh
npm i @observablehq/plot
```

Try Tanstack for data-layer:

```sh
npm i @tanstack/vue-query
```

## Budget TODO

- UX Design

## Measurements TODO

- UX Design

## Setup

Look at the [Nuxt documentation](https://nuxt.com/docs/getting-started/introduction) to learn more.

Check out the [deployment documentation](https://nuxt.com/docs/getting-started/deployment) for more
information.

```sh
# Install dependencies
npm i

# Start the development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```
