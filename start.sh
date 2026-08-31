#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================================="
echo "=== THÔNG TIN ĐĨA VÀ ĐƯỜNG DẪN GẮN (DIAGNOSTICS) ==="
df -h || true
echo "========================================================="

echo "=== TIẾN HÀNH DỌN DẸP /STORAGE GIẢI PHÓNG DUNG LƯỢNG ==="
if [ -d "/storage" ]; then
  # 1. Xóa thư mục sao lưu cũ (thủ phạm chính gây đầy đĩa do tính năng backup tự động của dockur/windows)
  if [ -d "/storage/backups" ]; then
    echo "Đang xóa các bản sao lưu cũ để giải phóng dung lượng đĩa: /storage/backups..."
    rm -rf /storage/backups || true
  fi

  # 2. Xóa các tệp tin tạm thời không hoàn chỉnh
  if [ -d "/storage/tmp" ]; then
    echo "Đang dọn dẹp thư mục tạm thời: /storage/tmp..."
    rm -rf /storage/tmp || true
  fi

  # 3. Tìm và xóa các tệp tin ISO cũ của phiên bản Windows khác để tránh lãng phí dung lượng
  current_iso="${VERSION//\//}.iso"
  current_iso_base="${VERSION//\//}"
  echo "Tệp ISO phiên bản hiện tại cần dùng: $current_iso"
  
  for f in /storage/*.iso; do
    [ -e "$f" ] || continue
    base_f=$(basename "$f")
    if [[ "$base_f" != "$current_iso" && "$base_f" != "${current_iso_base}"* ]]; then
      echo "Phát hiện và xóa tệp ISO cũ không dùng tới: $base_f..."
      rm -f "$f" || true
    fi
  done

  echo "Dọn dẹp /storage hoàn tất!"
fi

echo "========================================================="
echo "=== DUNG LƯỢNG ĐĨA SAU KHI DỌN DẸP DEPLOY ==="
df -h || true
echo "========================================================="

return 0
