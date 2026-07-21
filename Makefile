# Build claat codelabs from markdown sources.
#
# The gdg-jp claat fork exports directly into the content directory, bundles
# local codelab assets, applies the GDG HTML enhancements, and refreshes the
# root resource index in one cross-platform command.

CLAAT  ?= claat
PYTHON ?= python3
MARP   ?= npx --yes -p @marp-team/marp-cli@latest marp

SLIDE_POSTFIX := .marp/fix-slide-html.py

# Marp theme. Slides can live in any directory; pass the path via INPUT=.
MARP_THEME := .marp/gdg.css
OUTPUT     ?= $(INPUT:.md=.html)

ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
%:
	@:

.PHONY: claat slide slide-pdf index

# Export a claat codelab. Usage:
#   make claat <content-name>
#   (source: <content-name>/claat.md, output: <content-name>/)
claat:
	@DIR=$(word 1,$(ARGS)); \
	if [ -z "$$DIR" ]; then \
	  echo "Usage: make claat <content-name>"; \
	  exit 2; \
	fi; \
	$(CLAAT) build "$$DIR"

# Render a Marp deck. Usage:
#   make slide <content-name>
#   (source: <content-name>/slide.md, output: <content-name>/slide/index.html)
#
# Also renders the first slide as an OGP image (<content-name>/slide/ogp.png).
slide:
	@if [ -z "$(ARGS)" ]; then \
	  echo "Usage: make slide <content-name>"; \
	  exit 2; \
	fi
	@DIR="$(word 1,$(ARGS))"; \
	SRC="$$DIR/slide.md"; \
	OUT="$$DIR/slide/index.html"; \
	OGP="$$DIR/slide/ogp.png"; \
	$(MARP) --theme-set $(MARP_THEME) --html "$$SRC" -o "$$OUT"; \
	$(MARP) --theme-set $(MARP_THEME) --html --allow-local-files --image png "$$SRC" -o "$$OGP"; \
	$(PYTHON) $(SLIDE_POSTFIX) "$$OUT"; \
	$(CLAAT) index

# Export a Marp deck to PDF. Usage:
#   make slide-pdf path/to/deck.md [path/to/deck.pdf]
slide-pdf:
	@if [ -z "$(ARGS)" ]; then \
	  echo "Usage: make slide-pdf path/to/deck.md [path/to/deck.pdf]"; \
	  exit 2; \
	fi
	$(MARP) --theme-set $(MARP_THEME) --html --pdf --allow-local-files "$(word 1,$(ARGS))" -o "$(if $(word 2,$(ARGS)),$(word 2,$(ARGS)),$(patsubst %.md,%.pdf,$(word 1,$(ARGS))))"

# Regenerate the root index.html resource listing.
#   make index
index:
	$(CLAAT) index
