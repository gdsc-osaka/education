"""全エージェントで共有する薄いヘルパー。.envの読み込みとA2A関連のボイラープレートのみを持つ。"""

from __future__ import annotations

import os
from pathlib import Path

from dotenv import load_dotenv

REPO_ROOT = Path(__file__).resolve().parent.parent

_loaded = False


def load_env() -> None:
    global _loaded
    if _loaded:
        return
    load_dotenv(REPO_ROOT / ".env")
    _loaded = True


def remote_agent_card_url(env_name: str, default_base_url: str) -> str:
    """環境変数からリモートA2AエージェントのAgent Card URLを組み立てる。"""
    load_env()
    base_url = os.getenv(env_name, default_base_url).rstrip("/")
    if base_url.endswith("/.well-known/agent-card.json"):
        return base_url
    return f"{base_url}/.well-known/agent-card.json"


def to_a2a_app(agent, default_port: int):
    """ADK agent(またはWorkflow)をA2AのASGIアプリとしてラップする。"""
    from a2a.types import AgentCapabilities, AgentCard, AgentSkill, TransportProtocol
    from google.adk.a2a.utils.agent_to_a2a import to_a2a

    load_env()
    host = os.getenv("A2A_HOST", "localhost")
    protocol = os.getenv("A2A_PROTOCOL", "http")
    port = int(os.getenv("PORT", str(default_port)))

    rpc_url = f"{protocol}://{host}:{port}/"
    agent_card = AgentCard(
        name=agent.name,
        description=agent.description or "An ADK agent for the seat booking demo.",
        url=rpc_url,
        version="1.0.0",
        default_input_modes=["text/plain"],
        default_output_modes=["text/plain"],
        capabilities=AgentCapabilities(streaming=False),
        skills=[
            AgentSkill(
                id=f"{agent.name}_skill",
                name=agent.name,
                description=agent.description or "Runs a step of the seat booking flow.",
                tags=["adk", "a2a", "webmcp"],
            )
        ],
        preferred_transport=TransportProtocol.http_json,
        supports_authenticated_extended_card=False,
    )
    return to_a2a(agent, host=host, port=port, protocol=protocol, agent_card=agent_card)
