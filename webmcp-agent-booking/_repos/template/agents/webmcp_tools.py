"""ブラウザに実装したWebMCPツール(命令型/宣言型)へ、ADKのMcpToolset経由で接続する。
本物のWebMCP実装(@mcp-b/global + @mcp-b/webmcp-local-relay)にのみ接続する。shimは使わない。"""

from __future__ import annotations

import os

from google.adk.tools.mcp_tool import McpToolset
from google.adk.tools.mcp_tool.mcp_session_manager import StdioConnectionParams
from mcp import StdioServerParameters


def build_webmcp_connection_params() -> StdioConnectionParams:
    return StdioConnectionParams(
        server_params=StdioServerParameters(
            command="npx",
            args=["-y", "@mcp-b/webmcp-local-relay@latest"],
            env=os.environ.copy(),
        ),
        timeout=30,
    )


def build_seat_finder_toolset() -> McpToolset:
    """命令型WebMCPツールのみ: 座席の空き状況を取得する。"""
    return McpToolset(
        connection_params=build_webmcp_connection_params(),
        tool_filter=["list_available_seats", "get_seat_detail"],
    )


def build_reservation_toolset() -> McpToolset:
    """宣言型フォームtool(reserve_seat)と、確認用の命令型tool(list_reservations)。"""
    return McpToolset(
        connection_params=build_webmcp_connection_params(),
        tool_filter=["reserve_seat", "list_reservations"],
    )
