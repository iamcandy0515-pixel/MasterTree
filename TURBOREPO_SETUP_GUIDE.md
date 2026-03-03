# Turborepo Integration & Project Structure Proposal

## Current Architecture

The `tree_app_monorepo` currently consists of:

1.  **nodejs_admin_api**: Node.js/Typescript backend for admin operations (already configured with package.json).
2.  **flutter_admin_app**: Flutter-based admin dashboard (previously standalone).
3.  **flutter_user_app**: Flutter-based user application (previously standalone).

## Turborepo Setup

To integrate these into a unified pipeline, we have introduced the following:

### 1. Root Configuration (`turbo.json`)

Defines the tasks configuration for the monorepo (in `turbo.json`). Note: Used `tasks` key (Turbo 2.0+).

- `build`: Builds all interdependent packages in topological order.
- `test`: Runs tests for all packages.
- `dev`: Parallel execution of development servers (`api:dev` + `flutter run`).
- `clean`: Cleans artifacts.

### 2. Workspace Registration (`package.json`)

Updated the root `package.json` to include Flutter apps as workspaces:

```json
"workspaces": [
  "nodejs_admin_api",
  "flutter_admin_app",
  "flutter_user_app",
  "packages/*"
]
```

### 3. Flutter Wrappers

Since Turborepo relies on `package.json` scripts to discover tasks, we added wrapper `package.json` files to each Flutter project root. These delegate standard NPM commands to Flutter CLI commands.

**flutter_admin_app/package.json**:

```json
{
    "scripts": {
        "build": "flutter build apk --release",
        "dev": "flutter run -d chrome",
        "test": "flutter test",
        "clean": "flutter clean"
    }
}
```

**flutter_user_app/package.json**:

```json
{
    "scripts": {
        "build": "flutter build apk --release",
        "dev": "flutter run",
        "test": "flutter test",
        "clean": "flutter clean"
    }
}
```

## Future Recommendations (Shared Packages)

To fully leverage the monorepo structure, we should extract common code into shared packages under `packages/`.

### Proposed Shared Packages

1.  **packages/shared_ui**: common Flutter widgets, themes (`NeoTheme`), and design system components.
2.  **packages/core_data**: common models (`Tree`, `TreeGroup`), API clients, and constants.

### How to Implement

1.  Create `packages/shared_ui/pubspec.yaml`.
2.  In apps, reference via path dependency:
    ```yaml
    dependencies:
        shared_ui:
            path: ../packages/shared_ui
    ```
3.  Add `packages/shared_ui/package.json` (just metadata) so Turborepo tracks changes to it.

## How to Run

- **Install (Root)**: `npm install` (Installs Turborepo and workspace tools)
- **Start All Dev Servers**: `npx turbo run dev` or `npm run dev` (if configured in root)
- **Build All**: `npx turbo run build`
- **Run Specific App**: `npx turbo run dev --filter=flutter_admin_app`
