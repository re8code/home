#!/usr/bin/env bash
# 로컬 정적 서버 구동 스크립트 — 저장소 루트에서 실행하지 않아도 항상 저장소 루트를 기준으로 서버를 띄우고,
# 서버가 준비되면 Chrome으로 자동으로 index.html을 연다.
set -euo pipefail

PORT="${1:-8765}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
URL="http://localhost:${PORT}/index.html"

if lsof -i "tcp:${PORT}" >/dev/null 2>&1; then
  echo "포트 ${PORT}이(가) 이미 사용 중입니다. 다른 포트를 인자로 지정해 주세요: ./start.sh <port>"
  exit 1
fi

echo "Recode Coding 로컬 서버 시작: ${URL}"
echo "(src/ 하위 페이지는 http://localhost:${PORT}/src/graffiti.html 처럼 접속)"
echo "종료하려면 Ctrl+C"

cd "${REPO_ROOT}"
python3 -m http.server "${PORT}" &
SERVER_PID=$!
trap 'kill "${SERVER_PID}" 2>/dev/null' EXIT

# 서버가 실제로 요청에 응답할 때까지 대기한 뒤 Chrome으로 자동 오픈
for _ in $(seq 1 50); do
  if curl -s -o /dev/null "${URL}"; then
    break
  fi
  sleep 0.1
done

if [[ "$(uname)" == "Darwin" ]]; then
  open -a "Google Chrome" "${URL}"
elif command -v google-chrome >/dev/null 2>&1; then
  google-chrome "${URL}" >/dev/null 2>&1 &
elif command -v xdg-open >/dev/null 2>&1; then
  xdg-open "${URL}" >/dev/null 2>&1 &
else
  echo "Chrome을 자동으로 열 수 없습니다. 직접 ${URL} 을 열어주세요."
fi

wait "${SERVER_PID}"
