# Lifestlye Manager

Lifestyle Manager is a project for managing your daily activities, health, and wellness.

## Fitness App

- RPC for notifications of workouts that need to be done
- Fix for workouts that are done `Weekly`
- Need to test the app now

## Journaling App

- Add link to `Journal` on dashboard
- `writing` - Home route, defaults to a writing inputs
  - Store `type`, `subject`, and `content` in Dexie (recallable, offline first)
  - Push to Postgres on save, but only clear Dexie after save is confirmed
  - Have a random writing prompt that can be rotated through
  - Have a badge that lets you know how many writings you've done today/week/month/year/all time
- `writing/new` - create a new writing
- `writing/read/:id` - read a specific writing
- `writing/edit/:id` - edit a specific writing
- `writings/search` - search writings
- Button to export writings to JSON

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
