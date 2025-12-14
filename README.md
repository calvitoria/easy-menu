# Menu Management API

This is a Ruby on Rails API for managing menus and menu items.

## Project Structure

The project follows a standard Ruby on Rails structure:

-   `app/`: Contains the core application code, including models, controllers, and views.
-   `config/`: Contains the application configuration, including routes, database configuration, and environment-specific settings.
-   `db/`: Contains the database schema, migrations, and seeds.
-   `docs/`: Contains API documentation.
-   `test/`: Contains the test suite.

## Getting Started

### Prerequisites

-   Ruby `3.4.7` (as specified in `.ruby-version`)
-   Bundler
-   SQLite3
or 
-   Docker and Docker Compose

### Installation (without Docker)

1.  Clone the repository:

    ```bash
    git clone https://github.com/Vitoria-Porto/menu-management-api.git
    cd menu-management-api
    ```

2.  Install the dependencies:

    ```bash
    bundle install
    ```

### Database Setup (without Docker)

1.  Create the database:

    ```bash
    rails db:create
    ```

2.  Run the migrations:

    ```bash
    rails db:migrate
    ```

3.  Seed the database (optional):

    ```bash
    rails db:seed
    ```
  
  > or you can run `rails db:create db:migrate db:seed`

### Running the Application (without Docker)

Start the Rails server:

```bash
rails server
```

The API will be available at `http://localhost:3000`.

## Docker Usage

To run the application using Docker Compose:

1.  **Build the Docker image:**

    ```bash
    docker-compose build
    ```

2.  **Start the application:**
    This will also run database migrations (`db:prepare`) and seed the database (`db:seed`) automatically.

    ```bash
    docker-compose up
    ```

    Your application should now be accessible at `http://localhost:3000`.

### Accessing the Bash Shell in the Container

To get a bash shell inside the running `web` service container:

```bash
docker-compose exec web bash
```

## Testing

Run the test suite:

```bash
rails test
```

## Linting

This project uses RuboCop for linting. To check the code for style violations, run:

```bash
rubocop
```
