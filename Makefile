MAKE = make

DEFAULT = \033[0m
DEF_COLOR = \033[0;90m
WHITE = \033[1;37m
GREEN = \033[0;92m
YELLOW = \033[0;93m
CYAN = \033[0;96m
UNDERLINE = \033[4m
BOLD = \033[1m

help:
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

up: check-docker
	@mkdir -p $(HOME)/data/wordpress
	@mkdir -p $(HOME)/data/mariadb
	@cd ./srcs && docker compose up -d --build
	@echo "$(YELLOW)$(BOLD) Containers started successfully.$(DEFAULT)"

build:
	@cd ./srcs && docker compose build
	@echo "$(GREEN)$(BOLD) Docker images built successfully.$(DEFAULT)"

down:
	@cd ./srcs && docker compose down
	@echo "$(YELLOW)$(BOLD) Containers stopped successfully.$(DEFAULT)"

clean:
	@cd ./srcs && docker compose down --volumes --remove-orphans
	@echo "$(YELLOW)$(BOLD) Containers and networks removed successfully.$(DEFAULT)"

fclean:
	@cd ./srcs && docker compose down --volumes --remove-orphans
	@docker system prune -af --volumes || true
	@echo "$(YELLOW)$(BOLD) All Docker resources removed successfully.$(DEFAULT)"

re:
	@$(MAKE) clean && $(MAKE) up
	@echo "$(YELLOW)$(BOLD) Containers restarted successfully.$(DEFAULT)"

.PHONY: help up build down clean fclean re