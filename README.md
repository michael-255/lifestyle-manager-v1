# Lifestlye Manager

Lifestyle Manager is a project for managing your daily activities, health, and wellness.

## Fitness TODO

**Routing**

- `/fitness/data`
  - Links to access each data table
    - `fitness/view-workouts`
    - `fitness/view-exercises`
  - Data tables give access to all other options
    - `Create`
    - `Start` (Workout/Exercise)
    - `Charts`
    - `Inspect`
    - `Edit`
    - `Delete`
- `/fitness/active-workout`

**Today View**

- Show all workouts that contain a schedule for the current day
- Need the following data:
  - `id`
  - `name`
  - `description`
  - `schedule`
  - `is_locked`
  - Some data from the most recent `workout_result`, if any:
    - `last_id`
    - `last_created_at`
    - `last_note`

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
