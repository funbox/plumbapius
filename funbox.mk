# funbox.mk

VERSION = 0.1.0

MAKEFILE ?= Makefile
FUNBOX_MK_PATH = $(abspath funbox.mk)
FUNBOX_REPO = "ssh://git@git.funbox.ru/utils/funbox-makefile.git"
FUNBOX_MK_URL = "https://bb.funbox.ru/projects/UTILS/repos/funbox-makefile/raw/funbox.mk?at=refs%2Fheads%2Fmaster"
THIS_MAKE = make -f $(MAKEFILE)
BUILD_ARTIFACT ?= /app/build

## Compose boilerplate

COMPOSE_FILE ?= docker-compose.yml
COMPOSE_OPTS ?=
COMPOSE_APP ?= app

COMPOSE_TEARDOWN_TARGETS ?= compose-down
COMPOSE_DOWN_OPTS ?= --remove-orphans --volumes --rmi local
COMPOSE_RM_OPTS ?= --force --stop -v
COMPOSE = docker-compose -f $(COMPOSE_FILE) $(COMPOSE_OPTS)
COMPOSE_RUN = $(COMPOSE) run --no-deps --rm $(COMPOSE_APP)

DEV_COMPOSE_FILE ?= docker-compose.dev.yml
DEV_COMPOSE_OPTS ?=
DEV_COMPOSE_APP ?= app-dev
DEV_HOST_UID_GID = "$(shell id -u):$(shell id -g)"
DEV_COMPOSE = env HOST_UID_GID=$(DEV_HOST_UID_GID) docker-compose -f $(DEV_COMPOSE_FILE) $(DEV_COMPOSE_OPTS)
DEV_COMPOSE_RUN = $(DEV_COMPOSE) run --rm $(DEV_COMPOSE_APP)

## Utility targets

### Show help (no-goal entry point)

.PHONY: util-help
util-help:
	@echo "Укажите цель явно."
	@echo "Поддерживаемые встроенные цели:"
	@echo
	@echo "util-help:                Показать это сообщение"
	@echo "util-version              Показать версию funbox.mk"
	@echo "util-self-update:         Обновить funbox.mk"
	@echo "util-init:                Сгенерировать окружение сборки [TODO]"
	@echo "util-init-rails:          Сгенерировать окружение сборки Rails проекта"
	@echo "util-init-mix:            Сгенерировать окружение cборки Mix проекта [TODO]"
	@echo
	@echo "fb-all:                   Запустить все цели основного пайплайна (prep build check clean)"
	@echo "fb-prep:                  Запустить prep цели основного пайплайна"
	@echo "fb-build:                 Запустить build цели основного пайплайна"
	@echo "fb-check:                 Запустить check цели основного пайплайна"
	@echo "fb-clean:                 Запустить clean цели основного пайплайна"
	@echo "fb-extract-artifact:      Выгрузить артефакт сборки из основного контейнера в текущую директорию"
	@echo
	@echo "compose-up                Запустить окружение docker-compose"
	@echo "compose-down              Остановить окружение docker-compose"
	@echo "compose-rm                Удалить остановленные компоненты окружения docker-compose"
	@echo "compose-shell             Запустить bash в окружении docker-compose"
	@echo "compose-run-TARGET        Запустить make TARGET в окружении docker-compose"
	@echo "compose-COMMAND           Запустить команду COMMAND в окружении docker-compose"
	@echo
	@echo "dev-compose-up            Запустить dev окружение docker-compose"
	@echo "dev-compose-build         Собрать dev окружение docker-compose"
	@echo "dev-compose-down          Остановить dev окружение docker-compose"
	@echo "dev-compose-shell         Запустить bash в dev окружении docker-compose"
	@echo "dev-compose-run-TARGET    Запустить make TARGET в dev окружении docker-compose"
	@echo "dev-compose-COMMAND       Запустить команду COMMAND в dev окружении docker-compose"


### Update funbox.mk from master

.PHONY: util-self-update
util-self-update:
	curl -sL -o "$(FUNBOX_MK_PATH)" "$(FUNBOX_MK_URL)"

### Show version

.PHONY: util-version
util-version:
	echo "$(VERSION)"

.PHONY: util-init-%
util-init-%:
	@$(eval REPO_FOLDER = $(shell mktemp -d))
	@$(eval STACK = $(subst util-init-,,$@))
	@git clone -q $(FUNBOX_REPO) "$(REPO_FOLDER)"
	@cp -R "$(REPO_FOLDER)/templates/$(STACK)/." .
	@cat "$(REPO_FOLDER)/templates/$(STACK).txt"
	@rm -rf $(REPO_FOLDER)

## Lifecycle goals

.PHONY: fb-all
fb-all: fb-prep fb-build fb-check fb-clean

.PHONY: fb-prep
fb-prep: compose-up compose-run-prep

.PHONY: fb-build
fb-build: compose-run-build

.PHONY: fb-check
fb-check: compose-run-check

.PHONY: fb-clean
fb-clean: compose-run-clean $(COMPOSE_TEARDOWN_TARGETS)

.PHONY: fb-extract-artifact
fb-extract-artifact: compose-up
	docker cp $$($(COMPOSE) ps -aq $(COMPOSE_APP)):$(BUILD_ARTIFACT) .

## Helper wrappers

.PHONY: compose-shell
compose-shell:
	$(COMPOSE_RUN) bash

.PHONY: compose-up
compose-up:
	$(COMPOSE) build $(COMPOSE_APP)
	$(COMPOSE) up $(COMPOSE_APP)

.PHONY: compose-down
compose-down:
	$(COMPOSE) down $(COMPOSE_DOWN_OPTS)

.PHONY: compose-rm
compose-rm:
	$(COMPOSE) rm $(COMPOSE_RM_OPTS)

.PHONY: compose-run-%
compose-run-%:
	$(COMPOSE_RUN) $(THIS_MAKE) $(subst compose-run-,,$@)

.PHONY: compose-%
compose-%:
	$(COMPOSE) $(subst compose-,,$@)

.PHONY: dev-compose-build
dev-compose-build:
	$(DEV_COMPOSE) build $(DEV_COMPOSE_APP)

.PHONY: dev-compose-up
dev-compose-up:
	$(DEV_COMPOSE) up $(DEV_COMPOSE_APP)

.PHONY: dev-compose-down
dev-compose-down:
	$(DEV_COMPOSE) down --remove-orphans --volumes --rmi local

.PHONY: dev-compose-shell
dev-compose-shell:
	$(DEV_COMPOSE_RUN) bash

.PHONY: compose-run-%
dev-compose-run-%:
	$(DEV_COMPOSE_RUN) $(THIS_MAKE) $(subst dev-compose-run-,,$@)

.PHONY: compose-%
dev-compose-%:
	$(DEV_COMPOSE) $(subst dev-compose-,,$@)