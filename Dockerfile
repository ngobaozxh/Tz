FROM dockurr/windows:latest

# Tạo thư mục /storage và gán toàn quyền để tránh lỗi "Storage folder not found" hoặc lỗi phân quyền ghi
RUN mkdir -p /storage && chmod 777 /storage

# Tạo thư mục /win và gán toàn quyền để sử dụng ổ cứng có dung lượng cực lớn (2.1 TB) của Railway
RUN mkdir -p /win && chmod 777 /win

# Ép hệ thống lưu trữ toàn bộ dữ liệu cài đặt và đĩa ảo trên thư mục /win mới thay vì /storage bị giới hạn
ENV STORAGE="/win"

# Copy tệp start.sh tùy chỉnh vào thư mục khởi chạy /run/ để tự động dọn dẹp đĩa và chẩn đoán lúc khởi động
COPY --chmod=755 start.sh /run/start.sh

# GIAN LẬN (BYPASS) RAM tối thiểu: Sửa đổi trực tiếp file hệ thống để hạ yêu cầu RAM tối thiểu từ 2GB xuống 128MB
# Giúp lách qua kiểm tra phần cứng của container để chạy thành công trên gói RAM giới hạn (~1GB) của Railway
RUN sed -i 's/echo "2G"/echo "128M"/g' /run/define.sh

# GIAN LẬN (BYPASS) RAM dự phòng cho Host: Hạ mức RAM dự phòng cho Host từ 500MB xuống còn 80MB
# Giúp QEMU tận dụng được tối đa tới ~90% cấu hình RAM thật của container Railway cấp thay vì bị bóp chỉ được dùng một nửa
RUN sed -i 's/RAM_SPARE=500000000/RAM_SPARE=80000000/g' /run/memory.sh

# GIAN LẬN (BYPASS) KIỂM TRA DUNG LƯỢNG Ổ CỨNG: Vô hiệu hóa kiểm tra dung lượng ổ cứng trống khi tải ISO và tạo đĩa ảo
RUN sed -i 's/expected > capacity/1 == 2/g' /run/download.sh && \
    sed -i 's/dataSize > available/1 == 2/g' /run/disk.sh && \
    sed -i 's/required > available/1 == 2/g' /run/disk.sh && \
    sed -i 's/currentSize > available/1 == 2/g' /run/disk.sh

# Phiên bản Windows muốn cài đặt:
# Sử dụng "tiny10" (Windows 10 siêu nhẹ) để chạy siêu nhanh và mượt mà trên môi trường RAM thấp.
# (Bạn có thể đổi lại thành "10" nếu thích bản Windows 10 Pro gốc trong tab Variables trên Railway)
ENV VERSION="tiny10"

# Cấu hình tài nguyên phần cứng tối ưu - SỬ DỤNG TỐI ĐA (MAX) CPU VÀ RAM THÀNH PHẦN KHÔNG BỊ TRÀN PAGE CACHE
ENV RAM_SIZE="768M"
ENV RAM_CHECK="N"
ENV CPU_CORES="max"
ENV DISK_SIZE="32G"
ENV DISK_FMT="qcow2"

# Bắt buộc đặt KVM="N" để tránh container bị dừng đột ngột (exit 88) trên Railway do không có ảo hóa phần cứng KVM
# (Người dùng vẫn có thể ghi đè biến này thành "Y" trên dashboard Railway nếu gói của họ hỗ trợ KVM lồng nhau)
ENV KVM="N"

# Expose cổng 8006 cho trình duyệt Web (noVNC) và cổng 3389 cho kết nối Remote Desktop (RDP)
EXPOSE 8006 3389
