# Nest ERP

This is the monorepo for the Nest ERP project, containing both the backend and frontend applications as git submodules.

## Structure

- **backend/**: NestJS API ([Repository](https://github.com/muhammad4dev/nest-erp-backend))
- **frontend/**: React Frontend ([Repository](https://github.com/muhammad4dev/nest-erp-frontend))
- **docs/**: Cross-cutting guides (accounting phases, RBAC, documentation index)

## Documentation

**Start at [docs/README.md](./docs/README.md)** for the full documentation map.

| Topic | Document |
| ----- | -------- |
| **End user manual (all features)** | [docs/END-USER-MANUAL.md](./docs/END-USER-MANUAL.md) |
| Accounting & inventory (Phases 5–10) | [docs/ACCOUNTING-INVENTORY-PHASES.md](./docs/ACCOUNTING-INVENTORY-PHASES.md) |
| RBAC & UI permissions | [docs/RBAC-AND-PERMISSIONS.md](./docs/RBAC-AND-PERMISSIONS.md) |
| Business workflows | [backend/docs/WORKFLOWS-INDEX.md](./backend/docs/WORKFLOWS-INDEX.md) |
| Developer reference | [backend/docs/DEVELOPER-INDEX.md](./backend/docs/DEVELOPER-INDEX.md) |
| Notifications | [NOTIFICATIONS.md](./NOTIFICATIONS.md) |

## Getting Started

### Cloning the Repository

To clone this repository and fetch all submodules:

```bash
git clone --recursive <repository-url>
```

If you have already cloned it without `--recursive`, run:

```bash
git submodule update --init --recursive
```

### Working with Submodules

#### Updating Submodules

To pull the latest changes for all submodules:

```bash
git submodule update --remote
```

#### Committing Changes

When working inside `backend` or `frontend`, treat them as independent repositories:

1.  Current directory: `cd backend` (or `cd frontend`)
2.  Make changes, add, and commit: `git commit -m "..."`
3.  **Push to submodule remote**: `git push origin main`
4.  **Update parent repo**: Go back to root, add the submodule folder, and commit to point the parent repo to the new submodule commit.

```bash
cd ..
git add backend
git commit -m "chore: update backend submodule reference"
```
