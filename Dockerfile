FROM dockurr/windows:latest

# Tạo thư mục /storage và gán toàn quyền để tránh lỗi "Storage folder not found" hoặc lỗi phân quyền ghi
RUN mkdir -p /storage && chmod 777 /storage

# Phiên bản Windows muốn cài đặt (10 cho Windows 10 Pro)
ENV VERSION="10"

# Cấu hình tài nguyên phần cứng phù hợp với Railway
ENV RAM_SIZE="4G"
ENV CPU_CORES="2"
ENV DISK_SIZE="32G"
ENV DISK_FMT="qcow2"

# Bắt buộc đặt KVM="N" để tránh container bị dừng đột ngột (exit 88) trên Railway do không có ảo hóa phần cứng KVM
# (Người dùng vẫn có thể ghi đè biến này thành "Y" trên dashboard Railway nếu gói của họ hỗ trợ KVM lồng nhau)
ENV KVM="N"

# Expose cổng 8006 cho trình duyệt Web (noVNC) và cổng 3389 cho kết nối Remote Desktop (RDP)
EXPOSE 8006 3389
