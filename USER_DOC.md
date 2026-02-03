# User documentation — Inception

This document explains how an end user or administrator can use the Inception stack: what services are provided, how to start and stop the project, how to access the website and the admin panel, where credentials are stored, and how to check that services are running.

---

## What services are provided

The stack runs three services in Docker containers:

| Service   | Role |
|----------|------|
| **nginx**   | Web server and only entry point. Serves the site over HTTPS (port 443) and proxies requests to WordPress. |
| **wordpress** | WordPress site with php-fpm. Stores site files and runs the application. |
| **mariadb**  | Database server. Stores WordPress data (posts, users, settings). |

Only NGINX is exposed to the outside (port 443). WordPress and MariaDB are reachable only from inside the Docker network.

---

## Start and stop the project

- **Start everything:** From the project root, run:
  ```bash
  make up
  ```
  This creates the data directories (if needed) and starts the three containers.

- **Stop everything:**
  ```bash
  make down
  ```
  Containers are stopped; data in volumes is kept.

- **Remove containers and volumes:**
  ```bash
  make clean
  ```
  Stops containers and removes the named volumes (data under `/home/<login>/data/wordpress` and `/home/<login>/data/mariadb` is removed).

---

## Access the website and the administration panel

1. **Domain:** The project expects the domain **`<login>.42.fr`** (e.g. `gpichon.42.fr`) to point to your machine. Add a line in `/etc/hosts` on your machine (and on the machine you use to browse) if needed:
   ```
   127.0.0.1  gpichon.42.fr
   ```
   Replace `gpichon` with your login and use your VM’s IP instead of `127.0.0.1` if you access from another machine.

2. **Website:** Open in a browser:
   ```
   https://<login>.42.fr
   ```
   (e.g. `https://gpichon.42.fr`). Accept the self-signed certificate warning if you use the default TLS certificate from the image.

3. **WordPress admin panel:** Open:
   ```
   https://<login>.42.fr/wp-admin
   ```
   Log in with the administrator account defined in `srcs/.env`:
   - **Username:** value of `WP_ADMIN_USER` (must not contain "admin" or "administrator", e.g. `superuser`).
   - **Password:** the content of the file `secrets/wp_admin_password.txt`.

---

## Locate and manage credentials

- **Secrets (passwords)** are stored in text files at the **root of the repo**, in the `secrets/` folder:
  - `db_password.txt` — password for the WordPress database user
  - `db_root_password.txt` — password for the MariaDB administrator user
  - `wp_admin_password.txt` — password for the WordPress administrator account
  - `wp_user_password.txt` — optional; used if you add another WordPress user via secrets

- **Non-sensitive configuration** (domain, database name, admin username, email) is in **`srcs/.env`**. Do not put real passwords in `.env`; use the `secrets/` files and ensure the same values are used where needed (e.g. MariaDB expects the password from `.env` to match what you use for the DB; for production, align `.env` with the content of the secret files or use only secrets in the containers).

- **Important:** The `secrets/` folder and `srcs/.env` are ignored by Git. Never commit real passwords. Change default passwords before use.

---

## Check that services are running correctly

1. **List containers:**
   ```bash
   docker ps
   ```
   You should see three running containers: `nginx`, `wordpress`, `mariadb`.

2. **Check logs:**
   ```bash
   docker compose -f srcs/docker-compose.yml logs -f
   ```
   (run from project root, or `cd srcs && docker compose logs -f`). Stop with `Ctrl+C`.

3. **Test the site:** Open `https://<login>.42.fr` in a browser. The WordPress front page should load. Then try `https://<login>.42.fr/wp-admin` and log in with the admin account.

4. **If something fails:** Use `docker compose -f srcs/docker-compose.yml logs <service>` (e.g. `logs wordpress` or `logs mariadb`) to inspect a specific service. Restart with `make down` then `make up`.
