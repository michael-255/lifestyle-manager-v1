# Lifestlye Manager

Lifestyle Manager is a project for managing your daily activities, health, and wellness.

## Fitness App

### TODO - General

- Seed the database with a User and Data
- Use a view to get the counts for reminder notifications on apps

### TODO - New Packages

```sh
npm i @tanstack/vue-query
npm i @observablehq/plot
```

### TODO - Dialogs

#### Create/Edit Workout

- [@] `item-created-date.vue`
- [@] `item-name.vue`
- [@] `item-description.vue`
- [@] `item-schedule.vue`
- [@] `item-workout-exercises.vue`

#### ~~Create Workout Results~~

- ~~[ ] `item-parent-workout.vue`~~
- ~~[@] `item-created-date.vue`~~
- ~~[ ] `item-finished-date.vue`~~
- ~~[ ] `item-orphaned-exercise-results.vue` (Would have to look at the Parent Workout exercises)~~
- ~~[@] `item-note.vue`~~

#### Edit Workout Results

- ~~`item-parent-workout.vue`~~ (cant't edit parent once created)
- [@] `item-created-date.vue`
- [@] `item-finished-date.vue`
- [@] `item-note.vue`
- ~~[ ] `item-workout-result-exercise-results.vue`~~

#### Create Exercise

- [@] `item-created-date.vue`
- [@] `item-name.vue`
- [@] `item-description.vue`
- [@] `item-exercise-type.vue`
- [ ] `item-checklist-labels.vue`
- [ ] `item-default-sets.vue`
- [ ] `item-rest-timer.vue`

#### Edit Exercise

- [@] `item-created-date.vue`
- [@] `item-name.vue`
- [@] `item-description.vue`
- ~~`item-exercise-type.vue`~~ (cant't edit type once created)
- ~~`item-checklist-labels.vue`~~
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
  - [ ] `item-exercise-data-checklist.vue`
  - [ ] `item-exercise-data-cardio.vue`
  - [ ] `item-exercise-data-weightlifting.vue`
  - [ ] `item-exercise-data-sided-weightlifting.vue`
  - [ ] `item-exercise-data-climbing.vue`

### TODO - Data Tables

The following options should be on the data tables:

- `Create`
- `Start` (Workout/Exercise)
- `Charts`
- `Inspect`
- `Edit`
- `Delete`

### TODO - Active Workout

- Use a route param with the id of the active workout
- If the workout is not locked, or does not exist, then redirect to the Todays Plan page

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
