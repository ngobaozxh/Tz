#!/usr/bin/env bash
set -Eeuo pipefail

# === LỌC BỚT CÁC CẢNH BÁO "VÔ HẠI" LẶP LẠI MỖI LẦN KHỞI ĐỘNG ===
# Các dòng dưới đây KHÔNG phải lỗi thực sự làm hỏng container (Windows vẫn boot
# thành công ở cuối log). Chúng xuất hiện do chính nền tảng Railway không cấp
# các quyền sau cho container (đây là giới hạn hạ tầng, không phải bug của repo):
#   - /dev/net/tun, cap NET_ADMIN  -> ứng dụng đã tự động fallback sang
#     user-mode networking (passt), máy ảo vẫn có mạng bình thường.
#   - "failed to inspect disk ... assuming it contains data" -> cảnh báo lành
#     tính khi disk.sh dò kiểu phân vùng qcow2 lúc ổ đĩa còn trống/mới tạo.
# Vì start.sh này được entry.sh "source" làm bước đầu tiên, redirect exec ở
# đây sẽ áp dụng cho toàn bộ log về sau (kể cả log do network.sh/disk.sh phát
# sinh). Đây chỉ là lọc hiển thị (cosmetic), KHÔNG sửa được nguyên nhân gốc.
exec 2> >(grep --line-buffered -Ev \
  'TUN device is missing|failed to setup NAT networking|RTNETLINK answers|NET_ADMIN capability|failed to inspect disk' >&2)

echo "========================================================="
echo "=== THÔNG TIN ĐĨA VÀ ĐƯỜNG DẪN GẮN (DIAGNOSTICS) ==="
df -h || true
echo "========================================================="

storage_dir="${STORAGE:-/storage}"
echo "Thư mục lưu trữ hiện tại đang cấu hình là: $storage_dir"

echo "=== TIẾN HÀNH DỌN DẸP $storage_dir GIẢI PHÓNG DUNG LƯỢNG ==="
if [ -d "$storage_dir" ]; then
  # 1. Xóa thư mục sao lưu cũ (thủ phạm chính gây đầy đĩa do tính năng backup tự động của dockur/windows)
  if [ -d "$storage_dir/backups" ]; then
    echo "Đang xóa các bản sao lưu cũ để giải phóng dung lượng đĩa: $storage_dir/backups..."
    rm -rf "$storage_dir/backups" || true
  fi

  # 2. Xóa các tệp tin tạm thời không hoàn chỉnh
  if [ -d "$storage_dir/tmp" ]; then
    echo "Đang dọn dẹp thư mục tạm thời: $storage_dir/tmp..."
    rm -rf "$storage_dir/tmp" || true
  fi

  # 3. Tìm và xóa các tệp tin ISO cũ của phiên bản Windows khác để tránh lãng phí dung lượng
  current_iso="${VERSION//\//}.iso"
  current_iso_base="${VERSION//\//}"
  echo "Tệp ISO phiên bản hiện tại cần dùng: $current_iso"
  
  for f in "$storage_dir"/*.iso; do
    [ -e "$f" ] || continue
    base_f=$(basename "$f")
    if [[ "$base_f" != "$current_iso" && "$base_f" != "${current_iso_base}"* ]]; then
      echo "Phát hiện và xóa tệp ISO cũ không dùng tới: $base_f..."
      rm -f "$f" || true
    fi
  done

  echo "Dọn dẹp $storage_dir hoàn tất!"
fi

echo "=== TIẾN HÀNH GIẢI PHÓNG BỘ NHỚ RAM (EVICT PAGE CACHE) ==="
python3 -c "
import os, glob
storage_dir = '${storage_dir}'
for f_path in glob.glob(os.path.join(storage_dir, '*.iso')):
    try:
        print(f'Giải phóng {f_path} khỏi Page Cache...')
        fd = os.open(f_path, os.O_RDONLY)
        os.posix_fadvise(fd, 0, 0, os.POSIX_FADV_DONTNEED)
        os.close(fd)
        print('Giải phóng thành công!')
    except Exception as e:
        print(f'Không thể giải phóng {f_path}: {e}')
" || true

echo "========================================================="
echo "=== DUNG LƯỢNG ĐĨA SAU KHI DỌN DẸP DEPLOY ==="
df -h || true
echo "========================================================="

return 0
