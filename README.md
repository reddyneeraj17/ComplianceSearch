# PostgreSQL and pgAdmin Setup Using Docker

This guide will help you set up PostgreSQL and pgAdmin using Docker and Docker Compose, and connect to PostgreSQL using pgAdmin.

## Prerequisites

- Docker installed on your machine
- Docker Compose installed on your machine

## Step-by-Step Guide

### 1. Create a `docker-compose.yml` File

Create a `docker-compose.yml` file with the following content:

```yaml
version: '3.1'

services:
  db:
    image: postgres
    restart: always
    environment:
      POSTGRES_PASSWORD: mysecretpassword
    ports:
      - "5432:5432"
    volumes:
      - my_pgdata:/var/lib/postgresql/data
    container_name: my_postgres_container

  pgadmin:
    image: dpage/pgadmin4
    restart: always
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@admin.com
      PGADMIN_DEFAULT_PASSWORD: admin
    ports:
      - "5050:80"
    container_name: my_pgadmin_container

volumes:
  my_pgdata:
```

### 2. Run Docker Compose

Open a terminal and navigate to the directory containing your  Run the following command to start the services:

```sh
docker-compose up -d
```

### 3. Access pgAdmin

Open your web browser and go to `http://localhost:5050`. Log in using the default credentials:

- **Email:** `admin@admin.com`
- **Password:** `admin`

### 4. Add a New Server in pgAdmin

1. In pgAdmin, right-click on "Servers" in the left-hand pane and select "Create" > "Server...".
2. In the "Create - Server" dialog, fill in the following details:

   **General Tab:**
   - **Name:** `MyPostgresServer` (or any name you prefer)

   **Connection Tab:**
   - **Host name/address:** `db` (this is the service name defined in `docker-compose.yml`)
   - **Port:** `5432`
   - **Maintenance database:** `postgres`
   - **Username:** `postgres`
   - **Password:** `mysecretpassword`

3. Click "Save" to create the server connection. pgAdmin should now connect to your PostgreSQL instance.

### 5. Exiting `psql` Command-Line Interface

To exit from the `psql` command-line interface, you can use one of the following commands:

- Using the `\q` Command:
  ```sql
  \q
  ```

- Using the `exit` Command:
  ```sql
  exit
  ```

- Using the `Ctrl + D` Shortcut:
  - Press `Ctrl + D` on your keyboard.

### 6. Shutting Down the Server

To shut down the PostgreSQL and pgAdmin services, run the following command:

```sh
docker-compose down
```

## Troubleshooting Tips

- **Check Network Settings:**
  - Ensure that the PostgreSQL container's port `5432` is correctly mapped to the host's port `5432` 

    ```yaml
    ports:
      - "5432:5432"
    ```

- **Firewall and Security Groups:**
  - Ensure that your firewall or security groups allow connections to port `5432`.

- **Docker Network:**
  - If pgAdmin is running in a separate Docker container, ensure both containers are on the same Docker network. You can create a custom network in Docker Compose:
    ```yaml
    networks:
      my_network:
    ```

By following these steps, you should be able to run PostgreSQL using Docker and connect to it using pgAdmin.
```

