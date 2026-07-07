.PHONY: setup run-booking-api run-admin run-web run-specialists run-coordinator web run

setup:
	uv sync
	cd booking-api && npm install
	cd admin && npm install

run-booking-api:
	cd booking-api && npm start

run-admin:
	cd admin && npm run dev

run-web:
	cd web && node server.mjs

run-specialists:
	uv run uvicorn agents.seat_finder.agent:app --port 8101 & \
	uv run uvicorn agents.location.agent:app --port 8102 & \
	uv run uvicorn agents.price.agent:app --port 8103 & \
	uv run uvicorn agents.effect.agent:app --port 8104 & \
	uv run uvicorn agents.reservation.agent:app --port 8105 & \
	wait

run-coordinator:
	uv run uvicorn agents.coordinator.agent:app --port 8100

web:
	uv run adk web --port 8000 agents

# 運営用API + 予約サイト + 管理フロント + 5 specialist + coordinator + ADK Web UI をまとめて起動する。
# Ctrl+C で全プロセスを終了する。
run:
	@trap 'kill 0' EXIT INT TERM; \
	(cd booking-api && npm start) & \
	(cd web && node server.mjs) & \
	(cd admin && npm run dev) & \
	uv run uvicorn agents.seat_finder.agent:app --port 8101 & \
	uv run uvicorn agents.location.agent:app --port 8102 & \
	uv run uvicorn agents.price.agent:app --port 8103 & \
	uv run uvicorn agents.effect.agent:app --port 8104 & \
	uv run uvicorn agents.reservation.agent:app --port 8105 & \
	uv run uvicorn agents.coordinator.agent:app --port 8100 & \
	uv run adk web --port 8000 agents & \
	wait
