FROM dockurr/windows:latest

# Tạo thư mục /storage và gán toàn quyền để tránh lỗi "Storage folder not found" hoặc lỗi phân quyền ghi
RUN mkdir -p /storage && chmod 777 /storage

# GIAN LẬN (BYPASS) RAM tối thiểu: Sửa đổi trực tiếp file hệ thống để hạ yêu cầu RAM tối thiểu từ 2GB xuống 128MB
# Giúp lách qua kiểm tra phần cứng của container để chạy thành công trên gói RAM giới hạn (~1GB) của Railway
RUN sed -i 's/echo "2G"/echo "128M"/g' /run/define.sh

# GIAN LẬN (BYPASS) RAM dự phòng cho Host: Hạ mức RAM dự phòng cho Host từ 500MB xuống còn 80MB
# Giúp QEMU tận dụng được tối đa tới ~90% cấu hình RAM thật của container Railway cấp thay vì bị bóp chỉ được dùng một nửa
RUN sed -i 's/RAM_SPARE=500000000/RAM_SPARE=80000000/g' /run/memory.sh

# Phiên bản Windows muốn cài đặt:
# Sử dụng "tiny10" (Windows 10 siêu nhẹ) để chạy siêu nhanh và mượt mà trên môi trường RAM thấp.
# (Bạn có thể đổi lại thành "10" nếu thích bản Windows 10 Pro gốc trong tab Variables trên Railway)
ENV VERSION="tiny10"

# Cấu hình tài nguyên phần cứng tối ưu - SỬ DỤNG TỐI ĐA (MAX) CPU VÀ RAM THẬT CỦA RAILWAY
ENV RAM_SIZE="max"
ENV CPU_CORES="max"
ENV DISK_SIZE="32G"
ENV DISK_FMT="qcow2"

# Bắt buộc đặt KVM="N" để tránh container bị dừng đột ngột (exit 88) trên Railway do không có ảo hóa phần cứng KVM
# (Người dùng vẫn có thể ghi đè biến này thành "Y" trên dashboard Railway nếu gói của họ hỗ trợ KVM lồng nhau)
ENV KVM="N"

# Expose cổng 8006 cho trình duyệt Web (noVNC) và cổng 3389 cho kết nối Remote Desktop (RDP)
EXPOSE 8006 3389
