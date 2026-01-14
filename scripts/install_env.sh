#!/usr/bin/env bash
set -euo pipefail

ENV_NAME="openevolve"
INSTALL_DEV="0"
INSTALL_VIS="0"
INSTALL_LOCAL="0"

usage() {
  cat <<'EOF'
Usage: ./scripts/install_env.sh [--name ENV] [--dev] [--with-visualizer] [--local]

Creates a new conda env and installs openevolve dependencies.
  --name ENV          Conda environment name (default: openevolve)
  --dev               Install dev extras (.[dev])
  --with-visualizer   Install visualizer deps (scripts/requirements.txt)
  --local             Install from this repo instead of PyPI
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)
      ENV_NAME="${2:-}"
      shift 2
      ;;
    --dev)
      INSTALL_DEV="1"
      shift
      ;;
    --with-visualizer)
      INSTALL_VIS="1"
      shift
      ;;
    --local)
      INSTALL_LOCAL="1"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if ! command -v conda >/dev/null 2>&1; then
  echo "conda not found. Install Miniconda/Anaconda first." >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Enable conda in non-interactive shells.
CONDA_BASE="$(conda info --base)"
source "${CONDA_BASE}/etc/profile.d/conda.sh"

if conda env list | grep -q -E "^${ENV_NAME}[[:space:]]"; then
  echo "Conda env '${ENV_NAME}' already exists."
else
  conda create -y -n "${ENV_NAME}" python=3.10
fi

conda activate "${ENV_NAME}"
python -m pip install --upgrade pip

if [[ "${INSTALL_LOCAL}" == "1" ]]; then
  cd "${REPO_ROOT}"
  if [[ "${INSTALL_DEV}" == "1" ]]; then
    python -m pip install -e ".[dev]"
  else
    python -m pip install -e .
  fi
else
  if [[ "${INSTALL_DEV}" == "1" ]]; then
    python -m pip install "openevolve[dev]"
  else
    python -m pip install openevolve
  fi
fi

if [[ "${INSTALL_VIS}" == "1" ]]; then
  python -m pip install -r scripts/requirements.txt
fi

echo "Done. Activate with: conda activate ${ENV_NAME}"
