FROM dockurr/windows:latest

# Phiên bản Windows muốn cài đặt (10 cho Windows 10 Pro)
ENV VERSION="10"

# Cấu hình tài nguyên phần cứng phù hợp với Railway
ENV RAM_SIZE="4G"
ENV CPU_CORES="2"
ENV DISK_SIZE="32G"
ENV DISK_FMT="qcow2"

# Expose cổng 8006 cho trình duyệt Web (noVNC) và cổng 3389 cho kết nối Remote Desktop (RDP)
EXPOSE 8006 3389
