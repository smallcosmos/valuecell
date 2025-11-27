#!/bin/bash
set -Eeuo pipefail

# Simple project launcher with auto-install for bun and uv
# - macOS: use Homebrew to install missing tools
# - other OS: print guidance

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"
PY_DIR="$SCRIPT_DIR/python"

info()  { echo "[INFO]  $*"; }
success(){ echo "[ OK ]  $*"; }
warn()  { echo "[WARN]  $*"; }
error() { echo "[ERR ]  $*" 1>&2; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

ensure_brew_on_macos() {
  if [[ "${OSTYPE:-}" == darwin* ]]; then
    if ! command_exists brew; then
      error "Homebrew is not installed. Please install Homebrew: https://brew.sh/"
      error "Example install: /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
      exit 1
    fi
  fi
}

ensure_tool() {
  local tool_name="$1"; shift
  local brew_formula="$1"; shift || true

  if command_exists "$tool_name"; then
    success "$tool_name is installed ($($tool_name --version 2>/dev/null | head -n1 || echo version unknown))"
    return 0
  fi

  case "$(uname -s)" in
    Darwin)
      ensure_brew_on_macos
      info "Installing $tool_name via Homebrew..."
      brew install "$brew_formula"
      ;;
    Linux)
      info "Detected Linux, auto-installing $tool_name..."
      if [[ "$tool_name" == "bun" ]]; then
        curl -fsSL https://bun.sh/install | bash
        # Add Bun default install dir to PATH (current process only)
        if ! command_exists bun && [[ -x "$HOME/.bun/bin/bun" ]]; then
          export PATH="$HOME/.bun/bin:$PATH"
        fi
      elif [[ "$tool_name" == "uv" ]]; then
        curl -LsSf https://astral.sh/uv/install.sh | sh
        # Add uv default install dir to PATH (current process only)
        if ! command_exists uv && [[ -x "$HOME/.local/bin/uv" ]]; then
          export PATH="$HOME/.local/bin:$PATH"
        fi
      else
        warn "Unknown tool: $tool_name"
      fi
      ;;
    *)
      warn "$tool_name not installed. Auto-install is not provided on this OS. Please install manually and retry."
      exit 1
      ;;
  esac

  if command_exists "$tool_name"; then
    success "$tool_name installed successfully"
  else
    error "$tool_name installation failed. Please install manually and retry."
    exit 1
  fi
}

compile() {
  # Backend deps
  if [[ -d "$PY_DIR" ]]; then
    info "Sync Python dependencies (uv sync)..."
    (cd "$PY_DIR" && bash scripts/prepare_envs.sh && uv run valuecell/server/db/init_db.py)
    success "Python dependencies synced"
  else
    warn "Backend directory not found: $PY_DIR. Skipping"
  fi
}


main() {
  process_id=$(pm2 id valuecell-server)
  
  if [ $process_id == "[]" ]; then
    echo "Process valuecell-server not found"
  else
    echo ">>>>>>>> stop and delete valuecell-server"
    pm2 delete valuecell-server
  fi

  # Ensure tools
  ensure_tool bun oven-sh/bun/bun
  ensure_tool uv uv

  compile

  info "Starting backend (uv run scripts/launch.py)..."
  cd "$PY_DIR"
  # uv run --with questionary scripts/launch.py
  pm2 start uv --name "valuecell-server" -- run python -m valuecell.server.main
}

main "$@"