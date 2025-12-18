# EasyMenu - Menu Management API

![Ruby](https://img.shields.io/badge/Ruby-3.4.7-red?style=for-the-badge&logo=ruby)
![Rails](https://img.shields.io/badge/Rails-8.1.1-cc0000?style=for-the-badge&logo=rubyonrails)
![Docker](https://img.shields.io/badge/Docker-ready-2496ED?style=for-the-badge&logo=docker)
![Tests](https://img.shields.io/badge/Test%20Coverage-92.4%25-brightgreen?style=for-the-badge&logo=minitest)

**EasyMenu** is a Ruby on Rails application for managing restaurants, menus, and menu items. It combines a clean REST-style API with server-rendered HTML using Hotwire, and is designed to run smoothly both locally and inside Docker.

## 🎬 Project Demo Video

https://github.com/user-attachments/assets/16b57c75-d81d-4c70-8e45-ea7d813744b8

## 📋 Table of Contents

- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Data Model](#data-model)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
- [Installation & build](#installation)
  - [Installation without docker](#without-docker)
  - [Installation with docker](#with-docker)
- [Testing](#testing)
- [Linting](#linting)
- [API Endpoints](#api-endpoints)
  - [1. Restaurants](#1-restaurants)
  - [2. Menus](#2-menus)
  - [3. Menu Items](#3-menu-items)
  - [4. Menu Item Management](#4-menu-item-management)
  - [5. Data Import](#5-data-import)

## Technology Stack

- **Backend**: Ruby on Rails 8.1
- **Database**: SQLite (development)
- **Background Jobs**: SolidQueue
- **Frontend**: Hotwire (Turbo + Stimulus)
- **Styling**: Tailwind CSS
- **Testing**: Minitest
- **Linting**: RuboCop
- **Containerization**: Docker & Docker Compose

## Project Structure


```
app/
├── controllers/           # Request handling & orchestration
│ └── concerns/
├── models/                # Domain models
├── services/              # Business logic & workflows
├── views/                 # Server-rendered UI (Hotwire)
config/                    # Application configuration
db/                        # Schema, migrations, seeds
docs/                      # Documentation
test/                      # Test suite
```

---

## Data Model

The data model consists of four main resources:

-   **Restaurant**: The top-level resource. Each restaurant has its own set of menus.
-   **Menu**: Belongs to a `Restaurant` and can contain multiple `MenuItems`.
-   **MenuItem**: Can be associated with multiple `Menus`, forming a many-to-many relationship through the `MenuItemMenu` join table.
-   **ImportAuditLog**: Records the status and details of data import operations.
-   **MenuItemMenu**: join table for the many-to-many relationship.

---

## Getting Started
You can run EasyMenu with or without Docker. Docker is recommended for a consistent development environment.

### Prerequisites

**Without Docker**

-   Ruby `3.4.7` (as specified in `.ruby-version`)
-   Bundler
-   SQLite3
or
-   Node.js & npm

**With Docker**
- Docker
- Docker Compose

## Installation

1.  Clone the repository:

    ```bash
    git clone https://github.com/calvitoria/easy-menu
    cd easy-menu
    ```

### without Docker

1.  Install the dependencies:

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

---

### With Docker

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

---

## Testing

Run the test suite:

```bash
rails test
```

---

## Linting

This project uses RuboCop for linting. To check the code for style violations, run:

```bash
rubocop
```

---

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

### 5. Data Import

The API provides an endpoint to import restaurant, menu, and menu item data from a JSON file. This is particularly useful for bulk initial data loading.

-   `POST /imports/restaurants`: Imports data from a JSON file.
-   `GET /imports`: List all import audit logs.
-   `GET /imports/:id`: Show a specific import audit log.

