#!/usr/bin/env python3
"""
Slurm REST API MCP Server
==========================

An MCP (Model Context Protocol) server that bridges to the Slurm REST API
(slurmrestd), exposing Slurm cluster operations as MCP tools.

Configuration via environment variables:
    SLURM_REST_URL          Base URL for slurmrestd (default: http://localhost:6820)
    SLURM_REST_API_VERSION  API version string (default: v0.0.40)
    SLURM_JWT               JWT token for authentication
    SLURM_USER_NAME         Optional username for X-SLURM-USER-NAME header

Usage:
    $ pip install mcp httpx
    $ slurm-rest-mcp-server.py

Author: Paul Gierz
"""

import json
import os
import sys
from typing import Any

import httpx
from mcp.server.fastmcp import FastMCP

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

SLURM_REST_URL = os.environ.get("SLURM_REST_URL", "http://localhost:6820")
SLURM_API_VERSION = os.environ.get("SLURM_REST_API_VERSION", "v0.0.40")
SLURM_JWT_TOKEN = os.environ.get("SLURM_JWT", "")
SLURM_USER_NAME = os.environ.get("SLURM_USER_NAME", "")

mcp = FastMCP(
    "slurm-rest-api",
    instructions=(
        "MCP server for interacting with a Slurm HPC cluster via the Slurm REST API. "
        "Use the provided tools to query jobs, nodes, partitions, submit jobs, and more."
    ),
)

# ---------------------------------------------------------------------------
# HTTP helpers
# ---------------------------------------------------------------------------


def _headers() -> dict[str, str]:
    """Build authentication headers for slurmrestd requests."""
    h: dict[str, str] = {"Content-Type": "application/json"}
    if SLURM_JWT_TOKEN:
        h["X-SLURM-USER-TOKEN"] = SLURM_JWT_TOKEN
    if SLURM_USER_NAME:
        h["X-SLURM-USER-NAME"] = SLURM_USER_NAME
    return h


def _url(path: str) -> str:
    """Construct a full slurmrestd URL for the given path fragment."""
    return f"{SLURM_REST_URL}/slurm/{SLURM_API_VERSION}/{path.lstrip('/')}"


def _slurmdb_url(path: str) -> str:
    """Construct a full slurmdb URL for the given path fragment."""
    return f"{SLURM_REST_URL}/slurmdb/{SLURM_API_VERSION}/{path.lstrip('/')}"


async def _get(url: str) -> dict[str, Any]:
    async with httpx.AsyncClient(timeout=30) as client:
        resp = await client.get(url, headers=_headers())
        resp.raise_for_status()
        return resp.json()


async def _post(url: str, payload: dict[str, Any]) -> dict[str, Any]:
    async with httpx.AsyncClient(timeout=60) as client:
        resp = await client.post(url, headers=_headers(), json=payload)
        resp.raise_for_status()
        return resp.json()


async def _delete(url: str) -> dict[str, Any]:
    async with httpx.AsyncClient(timeout=30) as client:
        resp = await client.delete(url, headers=_headers())
        resp.raise_for_status()
        return resp.json()


def _fmt(data: Any) -> str:
    """Pretty-format a JSON-serialisable object for display."""
    return json.dumps(data, indent=2, default=str)


# ---------------------------------------------------------------------------
# MCP Resources — live cluster info exposed as readable resources
# ---------------------------------------------------------------------------


@mcp.resource("slurm://cluster/info")
async def cluster_info() -> str:
    """Current cluster connectivity and diagnostics summary."""
    try:
        ping = await _get(_url("ping"))
        diag = await _get(_url("diag"))
        return _fmt({"ping": ping, "diagnostics": diag})
    except Exception as exc:
        return f"Error reaching slurmrestd: {exc}"


@mcp.resource("slurm://partitions")
async def partitions_resource() -> str:
    """List of all partitions in the cluster."""
    data = await _get(_url("partitions"))
    return _fmt(data)


# ---------------------------------------------------------------------------
# MCP Tools — Cluster status
# ---------------------------------------------------------------------------


@mcp.tool()
async def slurm_ping() -> str:
    """Check connectivity to the Slurm REST API (slurmrestd).

    Returns the ping response from slurmrestd, confirming the service is
    reachable and the authentication credentials are valid.
    """
    data = await _get(_url("ping"))
    return _fmt(data)


@mcp.tool()
async def slurm_diagnostics() -> str:
    """Retrieve Slurm cluster diagnostics.

    Returns scheduler statistics, RPC counts, backfill information,
    and other operational metrics useful for monitoring cluster health.
    """
    data = await _get(_url("diag"))
    return _fmt(data)


# ---------------------------------------------------------------------------
# MCP Tools — Jobs
# ---------------------------------------------------------------------------


@mcp.tool()
async def slurm_list_jobs(
    user: str | None = None,
    state: str | None = None,
    account: str | None = None,
) -> str:
    """List jobs on the Slurm cluster with optional filters.

    Args:
        user: Filter by username (e.g. "pgierz").
        state: Filter by job state (e.g. "RUNNING", "PENDING", "COMPLETED").
        account: Filter by Slurm account name.
    """
    data = await _get(_url("jobs"))
    jobs = data.get("jobs", [])

    if user:
        jobs = [j for j in jobs if j.get("user_name") == user]
    if state:
        state_upper = state.upper()
        jobs = [
            j
            for j in jobs
            if _extract_job_state(j).upper() == state_upper
        ]
    if account:
        jobs = [j for j in jobs if j.get("account") == account]

    summary = [
        {
            "job_id": j.get("job_id"),
            "name": j.get("name"),
            "user": j.get("user_name"),
            "state": _extract_job_state(j),
            "partition": j.get("partition"),
            "nodes": j.get("nodes"),
            "time_limit": j.get("time_limit"),
        }
        for j in jobs
    ]
    return _fmt({"total": len(summary), "jobs": summary})


def _extract_job_state(job: dict[str, Any]) -> str:
    """Extract the job state string from varying API response formats."""
    state = job.get("job_state", "UNKNOWN")
    if isinstance(state, list):
        return state[0] if state else "UNKNOWN"
    return str(state)


@mcp.tool()
async def slurm_get_job(job_id: int) -> str:
    """Get detailed information about a specific Slurm job.

    Args:
        job_id: The numeric Slurm job ID.
    """
    data = await _get(_url(f"job/{job_id}"))
    return _fmt(data)


@mcp.tool()
async def slurm_submit_job(
    script: str,
    job_name: str = "mcp-submitted-job",
    account: str | None = None,
    partition: str | None = None,
    nodes: int | None = None,
    ntasks: int | None = None,
    time_limit_minutes: int | None = None,
    working_directory: str | None = None,
    environment: list[str] | None = None,
) -> str:
    """Submit a batch job to the Slurm cluster.

    Args:
        script: The batch script content (shell commands to execute).
        job_name: Name for the job (default: "mcp-submitted-job").
        account: Slurm account to charge.
        partition: Target partition/queue name.
        nodes: Number of nodes requested.
        ntasks: Number of tasks (CPU cores).
        time_limit_minutes: Wall-clock time limit in minutes.
        working_directory: Working directory for the job.
        environment: List of "KEY=VALUE" environment variable strings.
    """
    job: dict[str, Any] = {"name": job_name}

    if account:
        job["account"] = account
    if partition:
        job["partition"] = partition
    if nodes:
        job["minimum_nodes"] = nodes
    if ntasks:
        job["ntasks"] = ntasks
    if time_limit_minutes:
        job["time_limit"] = {"number": time_limit_minutes, "set": True}
    if working_directory:
        job["current_working_directory"] = working_directory
    if environment:
        job["environment"] = environment
    else:
        job["environment"] = ["PATH=/usr/bin:/bin"]

    payload = {"script": script, "job": job}
    data = await _post(_url("job/submit"), payload)
    return _fmt(data)


@mcp.tool()
async def slurm_cancel_job(job_id: int) -> str:
    """Cancel a running or pending Slurm job.

    Args:
        job_id: The numeric Slurm job ID to cancel.
    """
    data = await _delete(_url(f"job/{job_id}"))
    return _fmt(data)


# ---------------------------------------------------------------------------
# MCP Tools — Nodes
# ---------------------------------------------------------------------------


@mcp.tool()
async def slurm_list_nodes(state: str | None = None) -> str:
    """List compute nodes on the Slurm cluster.

    Args:
        state: Filter by node state (e.g. "idle", "allocated", "down", "mixed").
    """
    data = await _get(_url("nodes"))
    nodes = data.get("nodes", [])

    if state:
        state_upper = state.upper()
        nodes = [
            n
            for n in nodes
            if _extract_node_state(n).upper() == state_upper
        ]

    summary = [
        {
            "name": n.get("name") or n.get("hostname"),
            "state": _extract_node_state(n),
            "cpus": n.get("cpus"),
            "real_memory_mb": n.get("real_memory"),
            "alloc_cpus": n.get("alloc_cpus"),
            "partitions": n.get("partitions"),
        }
        for n in nodes
    ]
    return _fmt({"total": len(summary), "nodes": summary})


def _extract_node_state(node: dict[str, Any]) -> str:
    """Extract the node state string from varying API response formats."""
    state = node.get("state", "UNKNOWN")
    if isinstance(state, list):
        return "+".join(state) if state else "UNKNOWN"
    return str(state)


@mcp.tool()
async def slurm_get_node(node_name: str) -> str:
    """Get detailed information about a specific compute node.

    Args:
        node_name: The hostname of the node (e.g. "node001").
    """
    data = await _get(_url(f"node/{node_name}"))
    return _fmt(data)


# ---------------------------------------------------------------------------
# MCP Tools — Partitions
# ---------------------------------------------------------------------------


@mcp.tool()
async def slurm_list_partitions() -> str:
    """List all partitions (queues) on the Slurm cluster.

    Returns partition names, states, node counts, time limits, and defaults.
    """
    data = await _get(_url("partitions"))
    parts = data.get("partitions", [])
    summary = [
        {
            "name": p.get("name"),
            "state": p.get("state", {}).get("current", ["UNKNOWN"]) if isinstance(p.get("state"), dict) else p.get("state"),
            "total_nodes": p.get("node_count") or p.get("total_nodes"),
            "total_cpus": p.get("total_cpus"),
            "max_time": p.get("maximums", {}).get("time", {}) if isinstance(p.get("maximums"), dict) else p.get("max_time_limit"),
            "default": p.get("is_default", False),
        }
        for p in parts
    ]
    return _fmt({"total": len(summary), "partitions": summary})


@mcp.tool()
async def slurm_get_partition(partition_name: str) -> str:
    """Get detailed information about a specific partition.

    Args:
        partition_name: The partition name (e.g. "gpu", "batch", "debug").
    """
    data = await _get(_url(f"partition/{partition_name}"))
    return _fmt(data)


# ---------------------------------------------------------------------------
# MCP Tools — Reservations
# ---------------------------------------------------------------------------


@mcp.tool()
async def slurm_list_reservations() -> str:
    """List all reservations on the Slurm cluster."""
    data = await _get(_url("reservations"))
    return _fmt(data)


# ---------------------------------------------------------------------------
# MCP Tools — Accounting (SlurmDB)
# ---------------------------------------------------------------------------


@mcp.tool()
async def slurm_list_accounts() -> str:
    """List Slurm accounts from the accounting database (SlurmDB)."""
    data = await _get(_slurmdb_url("accounts"))
    return _fmt(data)


@mcp.tool()
async def slurm_job_history(
    user: str | None = None,
    account: str | None = None,
    start_time: str | None = None,
    end_time: str | None = None,
) -> str:
    """Query historical job records from the Slurm accounting database.

    Args:
        user: Filter by username.
        account: Filter by account name.
        start_time: Start time filter (ISO 8601 or Slurm time format).
        end_time: End time filter (ISO 8601 or Slurm time format).
    """
    params = []
    if user:
        params.append(f"users={user}")
    if account:
        params.append(f"account={account}")
    if start_time:
        params.append(f"start_time={start_time}")
    if end_time:
        params.append(f"end_time={end_time}")

    query = "&".join(params)
    path = f"jobs?{query}" if query else "jobs"
    data = await _get(_slurmdb_url(path))
    return _fmt(data)


# ---------------------------------------------------------------------------
# MCP Tools — Licenses
# ---------------------------------------------------------------------------


@mcp.tool()
async def slurm_list_licenses() -> str:
    """List software licenses tracked by Slurm."""
    data = await _get(_url("licenses"))
    return _fmt(data)


# ---------------------------------------------------------------------------
# MCP Prompts — reusable prompt templates
# ---------------------------------------------------------------------------


@mcp.prompt()
def job_submission_helper(description: str) -> str:
    """Help compose a Slurm batch job from a natural language description.

    Args:
        description: What the job should do (e.g. "run a Python training script on 2 GPU nodes for 4 hours").
    """
    return (
        f"The user wants to submit a Slurm job with this description:\n\n"
        f'"{description}"\n\n'
        "Please help compose the job by:\n"
        "1. First check available partitions with slurm_list_partitions\n"
        "2. Determine appropriate resource requirements\n"
        "3. Write the batch script\n"
        "4. Use slurm_submit_job to submit it\n\n"
        "Ask the user for any missing details (account, partition preference, etc.)."
    )


@mcp.prompt()
def cluster_status_report() -> str:
    """Generate a comprehensive cluster status report."""
    return (
        "Please generate a cluster status report by:\n"
        "1. Run slurm_ping to verify connectivity\n"
        "2. Run slurm_list_partitions to show queue status\n"
        "3. Run slurm_list_nodes to show node availability\n"
        "4. Run slurm_list_jobs with state='RUNNING' for active jobs\n"
        "5. Run slurm_list_jobs with state='PENDING' for queued jobs\n"
        "6. Summarize the findings in a clear report"
    )


# ---------------------------------------------------------------------------
# Entrypoint
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    mcp.run()
