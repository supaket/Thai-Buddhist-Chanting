#!/usr/bin/env bash
# ตรวจว่าทุกหน้าติวใน books/utcc มีปากกา (ink-tool.js) ครบ
# ใช้: bash tests/verify-ink-coverage.sh   (คืน exit 1 ถ้ามีหน้าไหนขาดโดยไม่ตั้งใจ)
#
# ข้อยกเว้น (EXEMPT): หน้าที่เป็น "ชีทสำหรับพิมพ์" โดยเฉพาะ — จัดหน้ามาเองครบแล้ว
# และไม่ต้องการปากกา/ปุ่มลอยมารบกวนเลย์เอาต์ ถ้าจะเพิ่มหน้าแบบนี้ ใส่ชื่อไว้ในลิสต์
set -euo pipefail
cd "$(dirname "$0")/.."

EXEMPT=(
  "books/utcc/GA512/GA512-ชีทสอบ-2หน้า.html"
)

is_exempt() {
  local f="$1"
  for e in "${EXEMPT[@]}"; do [ "$f" = "$e" ] && return 0; done
  return 1
}

miss=0 total=0 have=0 skipped=0
while IFS= read -r f; do
  total=$((total+1))
  if is_exempt "$f"; then
    skipped=$((skipped+1))
    echo "ข้าม (ชีทพิมพ์เฉพาะ): $f"
  elif grep -q 'assets/ink-tool.js' "$f"; then
    have=$((have+1))
  else
    echo "MISSING ink-tool: $f"
    miss=$((miss+1))
  fi
done < <(find books/utcc -name '*.html' ! -name 'index.html')

if [ "$miss" -eq 0 ]; then
  echo "✓ ครบ $have/$((total-skipped)) หน้าที่ต้องมีปากกา (ยกเว้น $skipped หน้า)"
else
  echo "✗ ขาด $miss หน้า"
  exit 1
fi
