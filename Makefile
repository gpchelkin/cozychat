SHELL:=/usr/bin/env bash
VENV_PATH = venv
POETRY_HOME = venv_poetry
POETRY_UPDATE ?= 0
DEBUG ?= 0


### The following commands are meant to be run within activated venv:

.PHONY: run
run:
	@cd examples && jupyter-lab --ServerApp.iopub_data_rate_limit=1.0e10

.PHONY: update
update:
	$(POETRY_HOME)/bin/poetry update; $(POETRY_HOME)/bin/poetry export --without-hashes -f requirements.txt -o requirements.txt


### The following commands are meant to be run without activated venv:

# Poetry info:
# https://python-poetry.org/docs/#installing-manually
# https://python-poetry.org/docs/#ci-recommendations
# https://python-poetry.org/docs/managing-environments/
# https://python-poetry.org/docs/basic-usage/
# Poetry latest version is taken from: https://github.com/python-poetry/poetry/releases
.PHONY: venv
venv:
	python3 --version
	python3 -m venv $(POETRY_HOME)
	$(POETRY_HOME)/bin/pip install --upgrade pip
	$(POETRY_HOME)/bin/pip install --upgrade setuptools wheel
	$(POETRY_HOME)/bin/pip install --upgrade --upgrade-strategy=eager poetry==1.8.5
	$(POETRY_HOME)/bin/poetry self add poetry-plugin-export
	$(POETRY_HOME)/bin/poetry --version
	python3 -m venv $(VENV_PATH)
	. $(VENV_PATH)/bin/activate; \
	pip install --upgrade pip; \
	pip install --upgrade setuptools wheel; \
	$(POETRY_HOME)/bin/poetry debug info; \
	$(POETRY_HOME)/bin/poetry install --no-root; \
	if [ "$(POETRY_UPDATE)" = "1" ]; then $(POETRY_HOME)/bin/poetry update; $(POETRY_HOME)/bin/poetry export --without-hashes -f requirements.txt -o requirements.txt; fi; \
	$(POETRY_HOME)/bin/poetry run dostoevsky download fasttext-social-network-model; \
	$(POETRY_HOME)/bin/poetry run playwright install chromium; \
	if [ "$(DEBUG)" = "1" ]; then echo "DEBUG INFO:"; $(POETRY_HOME)/bin/poetry show; pip freeze; fi

.PHONY: venv-activate
venv-activate:
	@echo \# Use \'eval \"$$\(make venv-activate\)\"\' to activate
	@echo . $(VENV_PATH)/bin/activate

.PHONY: clean
clean:
	rm -rf $(VENV_PATH)
	rm -rf $(POETRY_HOME)

#some unneeded things:
#poetry self lock
#poetry self install --sync
#poetry self update
#python -m dostoevsky download fasttext-social-network-model
#If you want to export as web-rendered pdf (webpdf):
#pip install nbconvert[webpdf]
#playwright install chromium
