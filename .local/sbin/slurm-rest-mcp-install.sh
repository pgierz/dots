#!/bin/bash
# ================================================================================
# Installs the Slurm REST API MCP Server and its Python dependencies.
#
# Usage:
# ------
#
#     $ slurm-rest-mcp-install.sh              # Install with pip
#     $ slurm-rest-mcp-install.sh --uv         # Install with uv (faster)
#     $ slurm-rest-mcp-install.sh --check      # Verify installation
#
# Environment Variables:
# ----------------------
# ``SLURM_REST_URL``          : slurmrestd base URL (default: http://localhost:6820)
# ``SLURM_REST_API_VERSION``  : API version (default: v0.0.40)
# ``SLURM_JWT``               : JWT token for slurmrestd authentication
# ``SLURM_USER_NAME``         : Optional username for X-SLURM-USER-NAME header
#
# MCP Client Configuration:
# -------------------------
# Add to your Claude Code settings (or any MCP client config):
#
#     {
#       "mcpServers": {
#         "slurm": {
#           "command": "python3",
#           "args": ["~/.local/sbin/slurm-rest-mcp-server.py"],
#           "env": {
#             "SLURM_REST_URL": "http://your-cluster:6820",
#             "SLURM_JWT": "your-jwt-token"
#           }
#         }
#       }
#     }
#
# Author:
# -------
# Paul Gierz
#
# ================================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REQUIREMENTS="${SCRIPT_DIR}/slurm-rest-mcp-requirements.txt"

case "${1:-install}" in
  --uv)
    echo "Installing Slurm REST MCP dependencies with uv..."
    uv pip install -r "${REQUIREMENTS}"
    echo "Done."
    ;;
  --check)
    echo "Checking Slurm REST MCP Server dependencies..."
    python3 -c "import mcp; import httpx; print('All dependencies available.')" 2>/dev/null \
      && echo "✓ Ready to use." \
      || { echo "✗ Missing dependencies. Run: $0"; exit 1; }
    ;;
  install|*)
    echo "Installing Slurm REST MCP dependencies with pip..."
    python3 -m pip install --user -r "${REQUIREMENTS}"
    echo "Done."
    ;;
esac

echo ""
echo "Server location: ${SCRIPT_DIR}/slurm-rest-mcp-server.py"
echo ""
echo "To use with Claude Code, add to your MCP config:"
echo ""
echo '  "slurm": {'
echo '    "command": "python3",'
echo "    \"args\": [\"${SCRIPT_DIR}/slurm-rest-mcp-server.py\"],"
echo '    "env": {'
echo '      "SLURM_REST_URL": "http://your-cluster:6820",'
echo '      "SLURM_JWT": "your-token"'
echo '    }'
echo '  }'
