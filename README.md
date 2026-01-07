# Nest ERP

This is the monorepo for the Nest ERP project, containing both the backend and frontend applications as git submodules.

## Structure

- **backend/**: NestJS API ([Repository](https://github.com/muhammad4dev/nest-erp-backend))
- **frontend/**: React Frontend ([Repository](https://github.com/muhammad4dev/nest-erp-frontend))

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
