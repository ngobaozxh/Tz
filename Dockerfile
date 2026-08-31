FROM dockurr/windows:latest

# Tắt kiểm tra RAM tối thiểu bằng cách xóa hàm kiểm tra
RUN sed -i '/check_ram/d' /run/define.sh 2>/dev/null || true
RUN sed -i '/RAM_SIZE.*compare/d' /run/start.sh 2>/dev/null || true
RUN sed -i '/requires at least/d' /run/start.sh 2>/dev/null || true

# Set RAM_SIZE thành 2G để không bị từ chối (dù không đủ thật)
ENV RAM_SIZE="2G"
ENV RAM_CHECK="false"
ENV CPU_CORES="max"
ENV DISK_SIZE="32G"
ENV KVM="N"
ENV VERSION="tiny10"   # hoặc "10"
ENV BOOT_TIMEOUT="60"

EXPOSE 8006 3389
