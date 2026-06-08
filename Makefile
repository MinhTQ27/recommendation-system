SOURCE_FOLDER = recommendation_system
TEST_FOLDER = tests
PYTHON_VERSION = 3.13
PYTHON_INTERPRETER = python

## Set up venv and install dependencies
.PHONY: venv
venv:
	uv venv --python $(PYTHON_VERSION)
	uv sync
	uv run pre-commit install
	@echo ">>> New uv virtual environment created. Activate with:"
	@echo ">>> Windows: .\\\\.venv\\\\Scripts\\\\activate"
	@echo ">>> Unix/macOS: source ./.venv/bin/activate"

## Delete all compiled Python files
.PHONY: clean
clean:
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -exec rm -rf {} +

## Format source code
.PHONY: format
format:
	uv run ruff format $(SOURCE_FOLDER) $(TEST_FOLDER)
	uv run ruff check --fix $(SOURCE_FOLDER) $(TEST_FOLDER)

## Run static checks
.PHONY: check
check:
	uv run ruff format --check $(SOURCE_FOLDER) $(TEST_FOLDER)
	uv run ruff check $(SOURCE_FOLDER) $(TEST_FOLDER)
	uv run pyright $(SOURCE_FOLDER)
	uv run bandit -r $(SOURCE_FOLDER)

## Run tests
.PHONY: test
test:
	uv run pytest -s --durations=0 $(TEST_FOLDER)


# Self Documenting Commands
.DEFAULT_GOAL := help

define PRINT_HELP_PYSCRIPT
import re, sys; \
lines = '\n'.join([line for line in sys.stdin]); \
matches = re.findall(r'\n## (.*)\n[\s\S]+?\n([a-zA-Z_-]+):', lines); \
print('Available rules:\n'); \
print('\n'.join(['{:25}{}'.format(*reversed(match)) for match in matches]))
endef
export PRINT_HELP_PYSCRIPT

## Show available make targets
help:
	@$(PYTHON_INTERPRETER) -c "${PRINT_HELP_PYSCRIPT}" < $(MAKEFILE_LIST)
