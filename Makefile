EXEC_PHP        = php -d memory_limit=-1
CONSOLE         = $(EXEC_PHP) bin/console
COMPOSER        = composer
SYMFONY         = symfony

##
##Godot
##-------------

build-web: ## Build Web Zip
	(cd Exports && rm -f Web.zip && zip -r Web.zip Web)

build-linux: ## Build Linux Zip
	(cd Exports && rm -f Linux.zip && zip -r Linux.zip Linux)

build-windows: ## Build Windows Zip
	(cd Exports && rm -f Windows.zip && zip -r Windows.zip Windows)

build-mac: ## Build Mac Zip
	(cd Exports && rm -f Mac.zip && zip -r Mac.zip Mac)

# DEFAULT
.DEFAULT_GOAL := help
help:
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'
.PHONY: help

##
