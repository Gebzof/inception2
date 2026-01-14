COMPOSE_FILE = srcs/docker-compose.yml
COMPOSE = docker-compose -f $(COMPOSE_FILE)
DATA_DIT = /home/gpichon/data

GREEN = \033[32m
YELLOW = \033[33m
RED = \033[31m

.PHONY: all build up down restart clean fclean re

all : build up

build : 
	@echo "$(YELLOW)building Docker images$(RESET)"
	$(COMPOSE) build
	echo "$(GREEN)Docker images built$(RESET)"