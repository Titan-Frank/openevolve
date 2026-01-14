#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INITIAL_PROGRAM="${ROOT_DIR}/examples/function_minimization/initial_program.py"
EVALUATOR="${ROOT_DIR}/examples/function_minimization/evaluator.py"
CONFIG="${ROOT_DIR}/examples/wwb/function_minimization.yaml"
OUTPUT_DIR="${ROOT_DIR}/examples/function_minimization/openevolve_output"

VIS_HOST="${VIS_HOST:-127.0.0.1}"
VIS_PORT="${VIS_PORT:-8080}"

if [[ ! -f "${INITIAL_PROGRAM}" ]]; then
  echo "Missing initial program: ${INITIAL_PROGRAM}" >&2
  exit 1
fi
if [[ ! -f "${EVALUATOR}" ]]; then
  echo "Missing evaluator: ${EVALUATOR}" >&2
  exit 1
fi
if [[ ! -f "${CONFIG}" ]]; then
  echo "Missing config: ${CONFIG}" >&2
  exit 1
fi

evolve_pid=""
cleanup() {
  if [[ -n "${evolve_pid}" ]] && kill -0 "${evolve_pid}" >/dev/null 2>&1; then
    kill "${evolve_pid}"
  fi
}
trap cleanup EXIT INT TERM

python "${ROOT_DIR}/openevolve-run.py" \
  "${INITIAL_PROGRAM}" \
  "${EVALUATOR}" \
  --config "${CONFIG}" \
  --output "${OUTPUT_DIR}" &
evolve_pid=$!

echo "Evolution running (PID ${evolve_pid})."
echo "Starting visualizer at http://${VIS_HOST}:${VIS_PORT}"

EVOLVE_OUTPUT="${OUTPUT_DIR}" python "${ROOT_DIR}/scripts/visualizer.py" \
  --path "${OUTPUT_DIR}" \
  --host "${VIS_HOST}" \
  --port "${VIS_PORT}"
