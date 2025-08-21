# Lifestlye Manager

Lifestyle Manager is a project for managing your daily activities, health, and wellness.

## Fitness App

### General

- Use a view to get the counts for reminder notifications on apps
- Implement the Active Workout footer timer component
- Work on active workout exercise components

### Exercise Result

#### Dialog Components

`EDIT`

- ~~`item-parent-exercise.vue`~~ (cant't edit parent once created)
- [@] `item-created-date.vue`
- [@] `item-note.vue`
- [ ] `item-exercise-data.vue` (may break this up into multiple components)
  - [ ] `item-exercise-data-checklist.vue`
  - [ ] `item-exercise-data-weightlifting.vue`
  - [ ] `item-exercise-data-sided-weightlifting.vue`

#### RPC Functions

- [ ] `create_exercise_result`
- [ ] `inspect_exercise_result`
- [ ] `edit_exercise_result`

### Workout Result

#### Dialog Components

`EDIT`

- ~~`item-parent-workout.vue`~~ (cant't edit parent once created)
- [@] `item-created-date.vue`
- [@] `item-finished-date.vue`
- [@] `item-note.vue`
- ~~[ ] `item-workout-result-exercise-results.vue`~~ (Can't edit associated exercises once created)

#### RPC Functions

- [ ] `create_workout_result`
- [ ] `inspect_workout_result`
- [ ] `edit_workout_result`

### Data Tables

The following options should be on the data tables:

- `Create`
- `Start` (Workout/Exercise)
- `Charts`
- `Inspect`
- `Edit`
- `Delete`

### Other Packages

```sh
npm i @tanstack/vue-query
npm i @observablehq/plot
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
