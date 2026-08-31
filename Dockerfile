FROM dockurr/windows:latest

# Tạo thư mục /storage để Railway mount vào (dù không cần RUN cũng được vì Volume sẽ overlay, nhưng để an toàn)
RUN mkdir -p /storage

# === ĐỪNG DÙNG SED Ở ĐÂY NỮA ===
# Lý do: Các file /run/define.sh và /run/memory.sh thay đổi theo phiên bản. 
# Thay vì sed (dễ hỏng build), bạn nên dùng biến môi trường (ENV) để set trực tiếp.

# Cấu hình RAM và CPU (Dùng ENV thay vì sửa file hệ thống)
ENV RAM_SIZE="max"
ENV CPU_CORES="max"
ENV DISK_SIZE="32G"
ENV DISK_FMT="qcow2"

# BẮT BUỘC phải tắt KVM (Railway không hỗ trợ ảo hóa lồng)
ENV KVM="N"

# Version Windows (tiny10, tiny11, hoặc 10, 11)
ENV VERSION="tiny10"

# === THÊM DÒNG NÀY ĐỂ GIẢM TẢI TIMEOUT ===
# Đặt thời gian chờ DHCP lâu hơn và thử dùng mirror khác nếu có
ENV BOOT_TIMEOUT="60"

EXPOSE 8006 3389
