SHELL := /bin/bash

BACKEND_DIR := backend
SAMPLE_DIR := sample
TEMPLATE_DIR := template
MONITOR_DIR := monitor

BACKEND_PORT := 8787
SAMPLE_PORT := 8000
TEMPLATE_PORT := 8001
MONITOR_PORT := 8002
ADMIN_TOKEN := dev-admin-token

.PHONY: help setup d1 backend sample template monitor dev reset health

help:
	@echo "WebMCP hands-on teacher helpers"
	@echo ""
	@echo "Targets:"
	@echo "  make setup     Install backend deps and apply local D1 migrations"
	@echo "  make d1        Apply local D1 migrations only"
	@echo "  make dev       Start backend, sample, template, and monitor together"
	@echo "  make backend   Start backend only on http://localhost:$(BACKEND_PORT)"
	@echo "  make sample    Start completed sample on http://localhost:$(SAMPLE_PORT)"
	@echo "  make template  Start participant template on http://localhost:$(TEMPLATE_PORT)"
	@echo "  make monitor   Start operator monitor on http://localhost:$(MONITOR_PORT)"
	@echo "  make health    Check backend health and seat summary"
	@echo "  make reset     Reset local seats with the dev admin token"

setup:
	cd $(BACKEND_DIR) && bun install
	$(MAKE) d1

d1:
	cd $(BACKEND_DIR) && bun run d1:apply:local

backend:
	cd $(BACKEND_DIR) && bun run dev

sample:
	python3 -m http.server $(SAMPLE_PORT) --directory $(SAMPLE_DIR)

template:
	python3 -m http.server $(TEMPLATE_PORT) --directory $(TEMPLATE_DIR)

monitor:
	python3 -m http.server $(MONITOR_PORT) --directory $(MONITOR_DIR)

dev:
	@echo "Starting local teacher test environment"
	@echo "  Backend : http://localhost:$(BACKEND_PORT)"
	@echo "  Sample  : http://localhost:$(SAMPLE_PORT)"
	@echo "  Template: http://localhost:$(TEMPLATE_PORT)"
	@echo "  Monitor : http://localhost:$(MONITOR_PORT)"
	@echo ""
	@echo "Press Ctrl+C to stop all servers."
	@pids=(); \
	cleanup() { \
		if [ $${#pids[@]} -gt 0 ]; then \
			kill "$${pids[@]}" 2>/dev/null || true; \
		fi; \
	}; \
	trap cleanup INT TERM EXIT; \
	(cd $(BACKEND_DIR) && bun run dev) & pids+=($$!); \
	python3 -m http.server $(SAMPLE_PORT) --directory $(SAMPLE_DIR) & pids+=($$!); \
	python3 -m http.server $(TEMPLATE_PORT) --directory $(TEMPLATE_DIR) & pids+=($$!); \
	python3 -m http.server $(MONITOR_PORT) --directory $(MONITOR_DIR) & pids+=($$!); \
	wait

health:
	@curl -sS http://localhost:$(BACKEND_PORT)/api/health
	@echo ""
	@curl -sS http://localhost:$(BACKEND_PORT)/api/seats \
		| python3 -c 'import json,sys; print(json.load(sys.stdin)["data"]["summary"])'

reset:
	curl -sS -X POST http://localhost:$(BACKEND_PORT)/api/admin/reset \
		-H 'Authorization: Bearer $(ADMIN_TOKEN)' \
		-H 'Content-Type: application/json' \
		-d '{"confirm":"RESET_ALL_SEATS"}'
