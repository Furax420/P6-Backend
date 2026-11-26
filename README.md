# Workshop Organizer API

A RESTful API for managing workshops and educational notions built with NestJS, TypeScript, and MongoDB.

## Overview

This application provides a backend API for organizing workshops and managing educational concepts (notions). It features a modular NestJS architecture with MongoDB persistence.

**Key Features:**
- Workshop management (CRUD operations)
- Notion management (CRUD operations)
- One-to-many relationship between workshops and notions
- Input validation with class-validator
- OpenAPI documentation with Swagger UI
- RESTful API design
- Health check endpoint

## Tech Stack

- **Runtime:** Node.js 22 LTS
- **Framework:** NestJS 11
- **Language:** TypeScript (strict mode)
- **Database:** MongoDB 7 with Mongoose ODM
- **Validation:** class-validator + class-transformer
- **Documentation:** Swagger / OpenAPI 3.0
- **Testing:** Jest + Supertest

## Prerequisites

Before you begin, ensure you have installed:

- **Node.js** 22.x or higher ([Download](https://nodejs.org/))
- **npm** 10.x or higher (included with Node.js)
- **MongoDB** 7.x or higher ([Download](https://www.mongodb.com/try/download/community))

## Getting Started

### Installation

1. Clone this repository:
```bash
git clone <repository-url>
cd p6-dfsjs-backend
```

2. Install dependencies:
```bash
npm install
```

3. Configure environment variables:
```bash
cp .env.example .env
```

Edit `.env` with your configuration:
```env
PORT=3000
MONGO_URI=mongodb://localhost:27017/workshopsdb
CORS_ORIGIN=http://localhost:5173
NODE_ENV=development
```

### Running the Application

**Important**: Ensure MongoDB is running locally before starting the application.

**Start MongoDB**:
```bash
# macOS (with Homebrew)
brew services start mongodb-community

# Linux
sudo systemctl start mongod

# Windows
net start MongoDB
```

**Run the application**:
```bash
# Development mode with auto-reload
npm run start:dev

# Production mode
npm run build && npm run start:prod
```

The API will be available at `http://localhost:3000`

### Running with Docker

From the project directory, with Docker Desktop running:

```bash
docker compose up -d
```

Compose builds the API image and starts MongoDB. The API is available on both `http://localhost:8080` and `http://localhost:3000`: the project instructions and the self-assessment sheet specify different ports. For example, open `http://localhost:8080/api/docs` for Swagger or `http://localhost:8080/health` for the health endpoint. Both host ports must be available.

The API connects to MongoDB through the Compose service name `mongodb`. MongoDB has no published host port and stores its data in a named Docker volume. This local exercise configuration does not enable MongoDB authentication and is not intended for production.

To rebuild after changing the code, inspect logs, or stop the services:

```bash
docker compose up -d --build
docker compose logs -f
docker compose down
```

`docker compose down` keeps the named volume and its data. The `--volumes` option deletes that volume and its database contents.

### Test the image published to GHCR

On GitHub, open **Actions** and select a successful push run. Copy the image reference under **Docker image published on GHCR**. For a private package, sign in to Docker with a GitHub classic token that has `read:packages` access. [Registry authentication](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-to-the-container-registry).

In PowerShell, replace `TAG` with the published tag and run these commands from this repository.

```powershell
$env:P6_IMAGE = 'ghcr.io/furax420/p6-backend:TAG'
docker pull $env:P6_IMAGE
docker compose -f docker-compose.yml -f docker-compose.ghcr.yml up -d --no-build
docker compose -f docker-compose.yml -f docker-compose.ghcr.yml ps
```

Open [Swagger](http://localhost:8082/api/docs) or request [the notions list](http://localhost:8082/api/notions) to check that the API can use MongoDB. The override selects the downloaded image and port `8082`. It starts a separate Compose project with its own MongoDB volume. To stop it, use the same Compose files with `down` in place of `up -d --no-build`.

### Verify Installation

Check the health endpoint:
```bash
curl http://localhost:3000/health
```

Expected response:
```json
{
  "status": "ok",
  "timestamp": "2026-01-21T10:30:00.000Z"
}
```

## Project Structure

```
p6-dfsjs-backend/
├── src/
│   ├── main.ts                                    # Application entry point (Swagger, ValidationPipe, CORS)
│   ├── app.module.ts                              # Root module
│   ├── core/                                      # Shared infrastructure (pipes, filters, health)
│   │   ├── health.controller.ts                   # Health check endpoint
│   │   ├── pipes/
│   │   │   └── parse-object-id.pipe.ts            # MongoDB ObjectId validation pipe
│   │   └── filters/
│   │       └── mongoose-exception.filter.ts       # Mongoose error handling
│   └── modules/                                   # Feature modules
│       ├── workshops/
│       │   ├── workshops.module.ts                # Workshop feature module
│       │   ├── workshops.controller.ts            # Workshop route handlers
│       │   ├── workshops.service.ts               # Workshop business logic
│       │   ├── workshops.controller.spec.ts       # Controller unit tests
│       │   ├── workshops.service.spec.ts          # Service unit tests
│       │   ├── schemas/
│       │   │   └── workshop.schema.ts             # Workshop Mongoose schema
│       │   └── dto/
│       │       ├── create-workshop.dto.ts         # Create validation DTO
│       │       └── update-workshop.dto.ts         # Update validation DTO
│       └── notions/
│           ├── notions.module.ts                  # Notion feature module
│           ├── notions.controller.ts              # Notion route handlers
│           ├── notions.service.ts                 # Notion business logic
│           ├── notions.controller.spec.ts         # Controller unit tests
│           ├── notions.service.spec.ts            # Service unit tests
│           ├── schemas/
│           │   └── notion.schema.ts               # Notion Mongoose schema
│           └── dto/
│               ├── create-notion.dto.ts           # Create validation DTO
│               └── update-notion.dto.ts           # Update validation DTO
├── test/
│   └── jest-e2e.json                              # E2E test configuration
├── package.json
├── tsconfig.json                                  # TypeScript configuration (strict, path aliases)
├── tsconfig.build.json                            # Build TypeScript configuration
├── nest-cli.json                                  # NestJS CLI configuration (Swagger plugin)
├── .env.example                                   # Environment variables template
├── .gitignore
└── README.md
```

**Path aliases** configured in `tsconfig.json`:
- `@core/*` resolves to `src/core/*`
- `@modules/*` resolves to `src/modules/*`

## API Documentation

Swagger UI is available at `http://localhost:3000/api/docs` when the application is running.

The OpenAPI JSON spec is served at `http://localhost:3000/api/docs-json`.

## API Endpoints

### Health Check

- `GET /health` - Check API status

### Workshops

- `GET /api/workshops` - Get all workshops (with populated notions)
- `GET /api/workshops/:id` - Get workshop by ID
- `POST /api/workshops` - Create new workshop
- `PUT /api/workshops/:id` - Update workshop
- `DELETE /api/workshops/:id` - Delete workshop

**Workshop request body (POST / PUT):**
```json
{
  "name": "Introduction to Docker",
  "notions": ["<notion_id_1>", "<notion_id_2>"]
}
```

### Notions

- `GET /api/notions` - Get all notions
- `GET /api/notions/:id` - Get notion by ID
- `POST /api/notions` - Create new notion
- `PUT /api/notions/:id` - Update notion
- `DELETE /api/notions/:id` - Delete notion

**Notion request body (POST / PUT):**
```json
{
  "name": "Containerization"
}
```

## Testing

Run the test suite:

```bash
# Run all unit tests
npm test

# Run tests with coverage report
npm run test:cov

# Run tests in watch mode
npm run test:watch

# Run e2e tests
npm run test:e2e
```

### Unified test runner with JUnit report

With Python 3.8 or later and npm dependencies installed (`npm ci`), run:

```bash
python run-tests.py
```

On Linux, use `python3 run-tests.py` if `python` is unavailable. The script detects the project, runs its Jest unit tests, and creates `test-results/junit.xml`. It removes its previous report before each run and returns a non-zero exit code if the tests fail or the report cannot be produced. The results directory is ignored by Git.

### Automated tests on GitHub

The `.github/workflows/ci.yml` workflow runs these tests on every push and pull request. In the **Actions** tab, select a run to see its summary and download the JUnit report from the `junit-test-results` artifact, including after a failure when a report was generated.

## Architecture

This application follows the **NestJS modular architecture** with a `core/` + `modules/` separation:

```
Client Request
    |
  main.ts (ValidationPipe, CORS, Swagger, MongooseExceptionFilter)
    |
  AppModule
    |--- core/        (shared infrastructure: pipes, filters, health)
    |--- modules/
           |--- WorkshopsModule
           |       |--- WorkshopsController (HTTP routing)
           |       |--- WorkshopsService (business logic + data access)
           |       |--- Workshop Schema (Mongoose model)
           |       |--- DTOs (input validation with class-validator)
           |
           |--- NotionsModule
                   |--- NotionsController
                   |--- NotionsService
                   |--- Notion Schema
                   |--- DTOs
```

**Key patterns:**
- **core/ + modules/**: Shared infrastructure separated from feature modules, with `@core/*` and `@modules/*` path aliases
- **NestJS Modules**: Feature-based encapsulation (WorkshopsModule, NotionsModule)
- **Dependency Injection**: Services injected via NestJS DI container
- **DTOs with class-validator**: Automatic input validation via global ValidationPipe
- **ParseObjectIdPipe**: Custom pipe for MongoDB ID validation on route params
- **MongooseExceptionFilter**: Global filter for Mongoose-specific errors
- **PartialType**: Update DTOs inherit from Create DTOs with all fields optional
- **Swagger plugin**: OpenAPI spec auto-generated from DTOs and controllers

## Available Scripts

- `npm run build` - Compile TypeScript to JavaScript
- `npm start` - Start NestJS application
- `npm run start:dev` - Start in development mode with auto-reload
- `npm run start:debug` - Start in debug mode
- `npm run start:prod` - Start compiled production build
- `npm test` - Run unit tests
- `npm run test:cov` - Run tests with coverage report
- `npm run test:watch` - Run tests in watch mode
- `npm run test:e2e` - Run end-to-end tests
- `npm run lint` - Lint and fix TypeScript files

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Server port | `3000` |
| `MONGO_URI` | MongoDB connection string | `mongodb://localhost:27017/workshopsdb` |
| `CORS_ORIGIN` | Allowed CORS origin | `http://localhost:5173` |
| `NODE_ENV` | Environment mode | `development` |

## Troubleshooting

### MongoDB Connection Issues

**Problem:** `MongoServerError: connection refused`

**Solution:** Ensure MongoDB is running:
```bash
# macOS (with Homebrew)
brew services start mongodb-community

# Linux
sudo systemctl start mongod

# Windows
net start MongoDB
```

### Port Already in Use

**Problem:** `Error: listen EADDRINUSE: address already in use :::3000`

**Solution:** Change the port in `.env` or kill the process using port 3000:
```bash
# Find process
lsof -i :3000

# Kill process
kill -9 <PID>
```

## License

MIT
