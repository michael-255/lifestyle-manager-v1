# Lifestlye Manager

Lifestyle Manager is a project for managing your daily activities, health, and wellness.

## Fitness App

### TODO - Dialogs

Consider using `tanstack/vue-query` soon!

```sh
npm i @tanstack/vue-query
```

#### Create/Edit Workout

- [@] `item-created-date.vue`
- [@] `item-name.vue`
- [@] `item-description.vue`
- [@] `item-schedule.vue`
- [ ] `item-workout-exercises.vue` (adding/removing exercises from workout)
  - [ ] Create an RPC function to handle adding/removing exercises from a workout and updating the
        workout record

#### ~~Create Workout Results~~

- ~~[ ] `item-parent-workout.vue`~~
- ~~[@] `item-created-date.vue`~~
- ~~[ ] `item-finished-date.vue`~~
- ~~[@] `item-note.vue`~~

#### Edit Workout Results

- ~~`item-parent-workout.vue`~~ (cant't edit parent once created)
- [@] `item-created-date.vue`
- [ ] `item-finished-date.vue`
- [@] `item-note.vue`
- ~~[ ] `item-workout-result-exercise-results.vue`~~

#### Create Exercise

- [@] `item-created-date.vue`
- [@] `item-name.vue`
- [@] `item-description.vue`
- [ ] `item-exercise-type.vue`
- [ ] `item-default-sets.vue`
- [ ] `item-rest-timer.vue`

#### Edit Exercise

- [@] `item-created-date.vue`
- [@] `item-name.vue`
- [@] `item-description.vue`
- ~~`item-exercise-type.vue`~~ (cant't edit type once created)
- [ ] `item-default-sets.vue`
- [ ] `item-rest-timer.vue`

#### ~~Create Exercise Results~~

- ~~[ ] `item-parent-exercise.vue`~~
- ~~[@] `item-created-date.vue`~~
- ~~[@] `item-note.vue`~~
- ~~[ ] `item-exercise-data.vue` (may break this up into multiple components)~~

#### Edit Exercise Results

- ~~`item-parent-exercise.vue`~~ (cant't edit parent once created)
- [@] `item-created-date.vue`
- [@] `item-note.vue`
- [ ] `item-exercise-data.vue` (may break this up into multiple components)

### TODO - Data Tables

The following options should be on the data tables:

- `Create`
- `Start` (Workout/Exercise)
- `Charts`
- `Inspect`
- `Edit`
- `Delete`

### TODO - Active Workout

- WIP

### TODO - Charts

Try Observable Plot for Charts:

```sh
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
