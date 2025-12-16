# Menu Management API

This is a Ruby on Rails API for managing menus and menu items for restaurants.

## Project Structure

The project follows a standard Ruby on Rails structure:

-   `app/`: Contains the core application code, including models, controllers, and views.
-   `app/models`: Defines the data models: `Restaurant`, `Menu`, and `MenuItem`.
-   `app/controllers`: Handles API requests and responses, with business logic delegated to services.
-   `app/services`: Contains service objects that encapsulate business logic.
-   `app/controllers/concerns`: Provides shared modules for common controller tasks.
-   `config/`: Contains the application configuration, including routes, database configuration, and environment-specific settings.
-   `db/`: Contains the database schema, migrations, and seeds.
-   `docs/`: Contains API documentation.
-   `test/`: Contains the test suite.

## Data Model

The data model consists of three main resources:

-   **Restaurant**: The top-level resource. Each restaurant has its own set of menus.
-   **Menu**: Belongs to a `Restaurant` and can contain multiple `MenuItems`.
-   **MenuItem**: Can be associated with multiple `Menus`, forming a many-to-many relationship through the `MenuItemMenu` join table.

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

## API Endpoints

The routes are structured hierarchically to reflect the data model:

### 1. Restaurants

-   `GET /restaurants`: List all restaurants.
-   `POST /restaurants`: Create a new restaurant.
-   `GET /restaurants/:id`: Show a specific restaurant.
-   `PATCH/PUT /restaurants/:id`: Update a specific restaurant.
-   `DELETE /restaurants/:id`: Delete a specific restaurant.

### 2. Menus

-   `GET /restaurants/:restaurant_id/menus`: List all menus for a specific restaurant.
-   `POST /restaurants/:restaurant_id/menus`: Create a new menu for a specific restaurant.
-   `GET /menus/:id`: Show a specific menu.
-   `PATCH/PUT /menus/:id`: Update a specific menu.
-   `DELETE /menus/:id`: Delete a specific menu.

### 3. Menu Items

-   `GET /menu_items`: List all menu items.
-   `POST /menu_items`: Create a new menu item and optionally assign it to one or more menus.
-   `GET /menus/:menu_id/menu_items`: List all menu items for a specific menu.
-   `POST /menus/:menu_id/menu_items`: Create a new menu item and assign it to the specified menu.
-   `GET /menu_items/:id`: Show a specific menu item.
-   `PATCH/PUT /menu_items/:id`: Update a specific menu item.
-   `DELETE /menu_items/:id`: Delete a specific menu item.

### 4. Menu Item Management

-   `POST /menus/:id/add_menu_item`: Add an existing menu item to a menu.
-   `DELETE /menus/:id/remove_menu_item`: Remove a menu item from a menu.