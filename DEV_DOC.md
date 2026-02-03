# Developer documentation — Inception

This document describes how a developer can set up the environment from scratch, build and run the project with the Makefile and Docker Compose, use useful commands to manage containers and volumes, and understand where project data is stored and how it persists.

---

## Prerequisites

- **Docker** and **Docker Compose** (Compose V2 plugin: `docker compose`).
- **Make** (for the Makefile).
- **Git** (to clone the repo).

The Makefile can trigger Docker installation if Docker is missing (see `make install-docker` or the `check-docker` target). You need `sudo` for that. On Debian/Ubuntu, you can also install Docker using the [official documentation](https://docs.docker.com/engine/install/).

---

## Configuration files and secrets

### Directory layout (relevant parts)

```
inception2/
├── Makefile              # build, up, down, clean, fclean, re, check-docker, install-docker
├── secrets/              # Not in Git; create and fill locally
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── wp_admin_password.txt
│   ├── wp_user_password.txt
│   └── credentials.txt
├── srcs/
│   ├── .env              # Not in Git; copy/adapt from example; no real passwords
│   ├── docker-compose.yml
│   └── requirements/
│       ├── mariadb/       # Dockerfile, init_mariadb.sh
│       ├── nginx/         # Dockerfile, conf/
│       └── wordpress/     # Dockerfile, init_wordpress.sh
├── README.md
├── USER_DOC.md
└── DEV_DOC.md
```

### Secrets (required)

Create the `secrets/` directory at the **root** of the repo and add these files with your chosen values:

| File | Purpose |
|------|--------|
| `db_password.txt` | Password for the MariaDB user used by WordPress (e.g. `wp_user`). |
| `db_root_password.txt` | Password for the MariaDB admin user (e.g. `dbadmin`). |
| `wp_admin_password.txt` | Password for the WordPress administrator account. |
| `wp_user_password.txt` | Optional; for an extra WordPress user if needed. |

One line per file (the password only, no newline if possible). Ensure the same passwords are reflected where the stack expects them (e.g. in `srcs/.env` for DB passwords used by the MariaDB container).

### Environment file (`srcs/.env`)

Create or edit `srcs/.env` with at least:

- `DOMAIN_NAME=<login>.42.fr`
- `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DB_ADMIN_USER`, `DB_ADMIN_PASSWORD`
- `WP_DATABASE`, `WP_DATABASE_USER`
- `WP_URL`, `WP_TITLE`, `WP_ADMIN_USER`, `WP_ADMIN_EMAIL`

Use placeholders or the same values as in `secrets/` for passwords. **Do not commit real passwords.** `WP_ADMIN_USER` must not contain the strings "admin" or "administrator".

---

## Build and launch with Makefile and Docker Compose

All commands below are run from the **project root** (`inception2/`).

| Command | Description |
|--------|-------------|
| `make` or `make help` | Show help (if your Makefile defines it). |
| `make build` | Check Docker, then run `docker compose build` in `srcs/` to build the three images (mariadb, wordpress, nginx). |
| `make up` | Create `~/data/wordpress` and `~/data/mariadb`, then run `docker compose up -d --build` in `srcs/`. Starts all services. |
| `make down` | Run `docker compose down` in `srcs/`. Stops and removes the containers (keeps volumes). |
| `make clean` | Run `docker compose down --volumes --remove-orphans`. Removes containers and the named volumes. |
| `make fclean` | Same as clean, then `docker system prune -af --volumes`. Removes all unused Docker data. |
| `make re` | `make clean` then `make up`. Fresh start with existing images. |
| `make install-docker` | Install Docker using the official script (requires sudo). |
| `make check-docker` | Verify that `docker` and `docker compose` are available; used automatically by `build` and `up`. |

Typical workflow:

```bash
# First time: fill secrets/ and srcs/.env, then:
make build
make up

# Later:
make down   # stop
make up     # start again
```

---

## Useful commands for containers and volumes

Run these from the project root; for `docker compose` you must be in `srcs/` or pass `-f srcs/docker-compose.yml`.

- **List running containers:**  
  `docker ps`

- **Logs (all services):**  
  `cd srcs && docker compose logs -f`  
  Or: `docker compose -f srcs/docker-compose.yml logs -f`

- **Logs (one service):**  
  `docker compose -f srcs/docker-compose.yml logs -f wordpress`  
  (same with `mariadb` or `nginx`)

- **Shell inside a container:**  
  `docker exec -it wordpress bash`  
  (replace `wordpress` with `mariadb` or `nginx` and use `sh` if `bash` is not available)

- **List volumes:**  
  `docker volume ls`  
  You should see `inception2_mariadb_data` and `inception2_wordpress_data` (prefix may depend on the project directory name).

- **Inspect a volume:**  
  `docker volume inspect inception2_wordpress_data`  
  The mountpoint or driver options show where data is stored on the host.

---

## Where data is stored and how it persists

- **WordPress files** (themes, uploads, `wp-config.php`, etc.):  
  Stored in the **named volume** `wordpress_data`, which is configured (via `driver_opts` in `docker-compose.yml`) to store data on the host under **`/home/<login>/data/wordpress`** (e.g. `/home/gpichon/data/wordpress`). So the path on the host is `$HOME/data/wordpress`.

- **MariaDB data** (databases, tables):  
  Stored in the **named volume** `mariadb_data`, configured to store on the host under **`/home/<login>/data/mariadb`** (e.g. `/home/gpichon/data/mariadb`). So the path on the host is `$HOME/data/mariadb`.

- **Persistence:** As long as you do not run `make clean` or `make fclean`, these directories (and thus the named volumes) are kept. After `make down`, data remains. After `make clean`, the volumes and their data are removed. The Makefile creates `~/data/wordpress` and `~/data/mariadb` before `make up` so the host paths exist for the volume driver.

- **Rebuilds:** `make build` or `make up --build` rebuild images; they do not remove volumes. So rebuilding does not delete WordPress or MariaDB data unless you also run `make clean`.
