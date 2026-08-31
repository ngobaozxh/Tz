FROM dockurr/windows:latest

# Tạo thư mục /storage để Railway mount volume
RUN mkdir -p /storage

# === GIAN LẬN ===
# Tắt kiểm tra RAM tối thiểu (2GB) - cho phép chạy trên container RAM thấp
ENV RAM_CHECK="false"

# Cấp phát 1GB RAM cho máy ảo (phù hợp với RAM thực ~945MB)
ENV RAM_SIZE="1G"

# Tận dụng tối đa CPU (dù KVM tắt, vẫn xài được CPU)
ENV CPU_CORES="max"

# Dung lượng ổ cứng ảo (có thể giảm xuống 16G nếu muốn tiết kiệm)
ENV DISK_SIZE="32G"
ENV DISK_FMT="qcow2"

# Bắt buộc tắt KVM (Railway không hỗ trợ ảo hóa lồng)
ENV KVM="N"

# Phiên bản Tiny 10 (hoặc đổi thành "10" nếu thích bản chuẩn)
ENV VERSION="tiny10"

# Tăng thời gian chờ boot để tránh timeout
ENV BOOT_TIMEOUT="60"

EXPOSE 8006 3389
