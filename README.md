*This project has been created as part of the 42 curriculum by gpichon.*

# Inception

## Description

Inception is a Docker-based infrastructure project that sets up a small multi-container stack: NGINX (TLS 1.2/1.3), WordPress with php-fpm, and MariaDB. Each service runs in its own container, built from custom Dockerfiles (Debian Bullseye). NGINX is the only entry point (port 443). Data is persisted via Docker named volumes stored under `/home/<login>/data` on the host.

Goal Build and operate a containerized web stack following 42 rules (no pre-built app images, no infinite loops in entrypoints, use of secrets and environment variables).

Instructions

Prerequisites Docker and Docker Compose installed. On first run, `make up` can trigger Docker installation if missing (see Makefile).
Secrets Fill the files in `secrets/` (e.g. `db_password.txt`, `db_root_password.txt`, `wp_admin_password.txt`) and ensure `srcs/.env` matches (see [DEV_DOC.md](DEV_DOC.md)).
Build `make build`
Start: `make up` (creates `~/data/wordpress` and `~/data/mariadb`, then starts containers)
- Stop:`make down`
Clean: `make clean` (remove containers and volumes) or `make fclean` (full Docker cleanup)

See [USER_DOC.md](USER_DOC.md) for end-user/admin usage and [DEV_DOC.md](DEV_DOC.md) for developer setup and commands.

Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [NGINX](https://nginx.org/en/docs/), [WordPress](https://wordpress.org/support/), [MariaDB](https://mariadb.org/documentation/)
- [PID 1 in containers](https://docs.docker.com/engine/reference/run/#pid-settings)

- IA (CHATGPT), is a good help when you want a info on your thing and can help your for a command, or a error who your don't know what is it.

---

Project description — Docker and design choices

Use of Docker and sources

- Dockerfiles (one per service in `srcs/requirements/{nginx,wordpress,mariadb}/`) build images from Debian Bullseye. No pre-built app images are used; only the base OS image is pulled.
- docker-compose.yml defines the three services, named volumes (mariadb_data, wordpress_data), a single bridge network, and Docker secrets. The Makefile runs `docker compose` from `srcs/`.
- Secrets (passwords) live in `secrets/*.txt` at the repo root and are mounted into containers; the `.env` file in `srcs/` holds non-secret variables (domain, DB names, etc.).

### Main design choices

- Single network: One bridge network (`inception_network`) for all containers; no `network: host` or `--link`.
- NGINX as sole entrypoint: Only port 443 is exposed; TLS 1.2/1.3 only. WordPress and MariaDB are not exposed to the host.
- Named volumes with host path: Volumes are declared as named volumes; `driver_opts` point their data to `/home/<login>/data/wordpress` and `/home/<login>/data/mariadb` so data lives in the required host path while still using Docker’s volume model.
- Secrets for credentials: Passwords are in `secrets/` and referenced as Docker secrets; the `.env` file is for non-sensitive configuration only.

### Comparisons

| Topic | Summary |
|------|--------|
| Virtual Machines vs Docker | VMs virtualize hardware and run a full OS per VM; Docker shares the host kernel and runs processes in isolated namespaces. Containers start faster, use less resources, and are better suited for packaging one process per container. |
| Secrets vs Environment Variables | Env vars are visible in `docker inspect` and process listings; secrets are mounted as files and not shown in env. For passwords and API keys, secrets are preferred. Non-sensitive config (domain, DB name) can stay in `.env`. |
| Docker Network vs Host Network | With a bridge network, containers get their own IPs and DNS; with `network: host`, they share the host’s network stack. Host mode is forbidden here; the bridge network gives isolation and predictable service names (e.g. `mariadb`, `wordpress`). |
| Docker Volumes vs Bind Mounts | Volumes are managed by Docker and can be named; bind mounts map a host path directly. The subject requires *named* volumes; we use named volumes with `driver_opts` so data is stored under `/home/<login>/data/` on the host while still satisfying the “no bind mount in the service” rule. |
