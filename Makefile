# Build claat codelabs from markdown sources.
#
# claat exports to a directory named after the codelab `id` field, so we
# rename to a stable directory name afterwards. We also swap the remote
# claat-public asset URLs for a local libs/ copy and run the postfix
# script that escapes inline <code> spans containing raw HTML tags.

CLAAT  ?= claat
PYTHON ?= python3
MARP   ?= npx --yes -p @marp-team/marp-cli@latest marp

POSTFIX := scripts/fix-claat-codespans.py
LIBS_SRC := portfolio-2025/libs

# Codelab id (must match the `id:` field in the markdown front matter)
PORTFOLIO_2026_ID := first-portfolio-workshop-2hr

# Marp theme. Slides can live in any directory; pass the path via INPUT=.
MARP_THEME := .marp/gdg.css
OUTPUT     ?= $(INPUT:.md=.html)

ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
%:
	@:

.PHONY: all portfolio-2026 slide clean

all: portfolio-2026

portfolio-2026: portfolio-2026.md $(POSTFIX) | $(LIBS_SRC)
	$(CLAAT) export $<
	rm -rf $@
	mv $(PORTFOLIO_2026_ID) $@
	cp -R $(LIBS_SRC) $@/libs
	sed -i '' 's|https://storage.googleapis.com/claat-public/|libs/|g' $@/index.html
	$(PYTHON) $(POSTFIX) $@/index.html

# Render a Marp deck. Usage:
#   make slide path/to/deck.md [path/to/deck.html]
slide:
	@if [ -z "$(ARGS)" ]; then \
	  echo "Usage: make slide path/to/deck.md [path/to/deck.html]"; \
	  exit 2; \
	fi
	$(MARP) --theme-set $(MARP_THEME) --html "$(word 1,$(ARGS))" -o "$(if $(word 2,$(ARGS)),$(word 2,$(ARGS)),$(patsubst %.md,%.html,$(word 1,$(ARGS))))"

clean:
	rm -rf portfolio-2026
