# Lifestlye Manager

Lifestyle Manager is a project for managing your daily activities, health, and wellness.

## Fitness App

### Work in Progress

Need data tables working first before working on the dialogs and other features.

RPC functions?

- [@] `table_counts`
- [ ] `workouts_table`
- [ ] `exercises_table`
- [ ] `workout_results_table`
- [ ] `exercise_results_table`

- [@] `inspect_workout`
- [@] `create_workout`
- [@] `edit_workout`

- [ ] `inspect_exercise`
- [ ] `create_exercise`
- [ ] `edit_exercise`

- [ ] `inspect_workout_result`
- [ ] `create_workout_result`
- [ ] `edit_workout_result`

- [ ] `inspect_exercise_result`
- [ ] `create_exercise_result`
- [ ] `edit_exercise_result`

- [ ] `start_workout`
  - Gets the workout
  - Gets all assoicated exercises (full data)
  - Gets the last workout results (previous duration and notes)
  - Gets all last exercise results for the exercises (previous values and notes)
  - Locks the workout
  - locks all associated exercises
  - Creates placeholder workout_result (locked?)
  - Creates placeholder exercise_results for each exercise (locked?)
- [ ] `finish_workout`
  - Saves the workout_result
  - Saves the exercise_results
  - Unlocks the workout
  - Unlocks the exercises
  - Unlocks the workout_result
  - Unlocks the exercise_results

### TODO - General

- Seed the database with a User and Data
- Use a view to get the counts for reminder notifications on apps
- Create RPC functions for some DB interactions
- Implement real-time updates for tables

```sql
begin;
-- remove the supabase_realtime publication
drop
  publication if exists supabase_realtime;
-- re-create the supabase_realtime publication with no tables
create publication supabase_realtime;
commit;
-- add a table called 'messages' to the publication
-- (update this to match your tables)
alter
  publication supabase_realtime add table workouts;
```

### TODO - New Packages

```sh
npm i @tanstack/vue-query
npm i @observablehq/plot
```

### TODO - Dialogs

#### `inspect_exercise`

- All exercise rows
- `total_results` (count of exercise results)
- `workouts_used` (list of workouts that use this exercise)
  - `id`
  - `name`

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

#### Create Workout Result

- [ ] `item-parent-workout.vue`
- [@] `item-created-date.vue`
- [ ] `item-finished-date.vue`
- [ ] `item-orphaned-exercise-results.vue` (Would have to look at the Parent Workout exercises)
- [@] `item-note.vue`

#### Edit Workout Result

- ~~`item-parent-workout.vue`~~ (cant't edit parent once created)
- [@] `item-created-date.vue`
- [@] `item-finished-date.vue`
- [@] `item-note.vue`
- ~~[ ] `item-workout-result-exercise-results.vue`~~ (Can't edit associated exercises once created)

#### Create Exercise Result

- [ ] `item-parent-exercise.vue`
- [@] `item-created-date.vue`
- [@] `item-note.vue`
- [ ] `item-exercise-data.vue` (may break this up into multiple components)
  - [ ] `item-exercise-data-checklist.vue`
  - [ ] `item-exercise-data-cardio.vue`
  - [ ] `item-exercise-data-weightlifting.vue`
  - [ ] `item-exercise-data-sided-weightlifting.vue`
  - [ ] `item-exercise-data-climbing.vue`

#### Edit Exercise Result

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
