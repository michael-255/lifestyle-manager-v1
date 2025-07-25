# Lifestlye Manager

Lifestyle Manager is a project for managing your daily activities, health, and wellness.

## TODO

- **Supabase**
  - Test SQL for solutions
  - Test doing subscriptions (live queries)

## Fitness

**Design**

- Today's Plan page should only show workouts for today
- Workouts should be sorted alphabetically

**Routing**

- `/fitness` (Today's Plan)
  - Cards for each workout sorted alphabetically
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

## Budget

- UX Design

## Measurements

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
