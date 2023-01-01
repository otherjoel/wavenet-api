SHELL = /bin/bash

scribble: scribblings/wavenet.scrbl
scribble: ## Rebuild Scribble docs
	rm -rf scribblings/wavenet/* || true
	cd scribblings && scribble --htmls +m --redirect https://docs.racket-lang.org/local-redirect/ wavenet.scrbl

publish: ## Sync Scribble HTML docs to web server (doesn’t rebuild anything)
	rsync -av --delete scribblings/wavenet/ $(JDCOM_SRV)what-about/wavenet-api-client/

# Self-documenting makefile (http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html)
help: ## Displays this help screen
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

.PHONY: help publish scribble

.DEFAULT_GOAL := help
