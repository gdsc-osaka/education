# Build claat codelabs from markdown sources.
#
# claat exports to a directory named after the codelab `id` field, so we
# rename to a stable directory name afterwards. We also swap the remote
# claat-public asset URLs for a local libs/ copy and run the postfix
# script that escapes inline <code> spans containing raw HTML tags.

CLAAT  ?= claat
PYTHON ?= python3
MARP   ?= npx --yes -p @marp-team/marp-cli@latest marp

POSTFIX  := .claat/fix-claat-codespans.py
LIBS_SRC ?= portfolio-2025/libs

# Marp theme. Slides can live in any directory; pass the path via INPUT=.
MARP_THEME := .marp/gdg.css
OUTPUT     ?= $(INPUT:.md=.html)

ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
%:
	@:

.PHONY: claat slide

# Export a claat codelab. Usage:
#   make claat path/to/codelab.md path/to/output
claat:
	@MD=$(word 1,$(ARGS)); OUT=$(word 2,$(ARGS)); \
	if [ -z "$$MD" ] || [ -z "$$OUT" ]; then \
	  echo "Usage: make claat path/to/codelab.md path/to/output"; \
	  exit 2; \
	fi; \
	TMPDIR=$$(mktemp -d); \
	$(CLAAT) export -o "$$TMPDIR" "$$MD"; \
	EXPORTED=$$(ls "$$TMPDIR"); \
	mkdir -p "$$OUT"; \
	cp -R "$$TMPDIR/$$EXPORTED"/. "$$OUT/"; \
	rm -rf "$$TMPDIR"; \
	rm -rf "$$OUT/libs"; \
	cp -R "$(LIBS_SRC)" "$$OUT/libs"; \
	sed -i '' 's|https://storage.googleapis.com/claat-public/|libs/|g' "$$OUT/index.html"; \
	$(PYTHON) $(POSTFIX) "$$OUT/index.html"

# Render a Marp deck. Usage:
#   make slide path/to/deck.md [path/to/deck.html]
slide:
	@if [ -z "$(ARGS)" ]; then \
	  echo "Usage: make slide path/to/deck.md [path/to/deck.html]"; \
	  exit 2; \
	fi
	$(MARP) --theme-set $(MARP_THEME) --html "$(word 1,$(ARGS))" -o "$(if $(word 2,$(ARGS)),$(word 2,$(ARGS)),$(patsubst %.md,%.html,$(word 1,$(ARGS))))"
