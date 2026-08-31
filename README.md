# Windows 10 inside Docker for Railway

Repository này đã được cấu hình lại để chạy **Windows 10** mượt mà bên trong Docker container sử dụng dự án mã nguồn mở [dockurr/windows](https://github.com/dockur/windows). Cấu hình này cực kỳ tối ưu và đã được áp dụng các bản vá "gian lận" đặc biệt để vượt qua mọi giới hạn phần cứng của **Railway**, giúp bạn chỉ cần deploy là chạy vù vù không lỗi!

## 🚀 Tính năng nổi bật & Các Bản Vá "Gian Lận" Đặc Biệt cho Railway

- **Chạy Windows 10 siêu nhẹ (Tiny10)**: Mặc định cài đặt phiên bản **Tiny10** (bản rút gọn cực kỳ nhẹ của Windows 10, chỉ nặng 3.6 GB thay vì 5.7 GB). Phiên bản này đã lược bỏ hết bloatware, dịch vụ thừa và telemetry, giúp chạy cực kỳ mượt mà và phản hồi nhanh trên môi trường RAM thấp.
- **GIAN LẬN RAM - Bypass giới hạn RAM tối thiểu 2GB**:
  * *Vấn đề*: Railway thường giới hạn RAM ở mức ~1GB. Trong khi đó, dự án mặc định yêu cầu ít nhất 2GB RAM để khởi động Windows 10, nếu không container sẽ báo lỗi đỏ lòm và sập ngay lập tức.
  * *Bản vá*: Đã thêm lệnh `RUN sed -i 's/echo "2G"/echo "128M"/g' /run/define.sh` để sửa đổi trực tiếp mã nguồn khởi động của container. Việc này hạ mức RAM yêu cầu tối thiểu xuống còn **128MB**, giúp lách qua bước kiểm tra phần cứng của container một cách hoàn hảo!
- **Vá lỗi `/storage` không tìm thấy (Sửa lỗi crash)**: Đã tạo sẵn thư mục `/storage` và cấp toàn quyền đọc ghi (`chmod 777`) ngay trong `Dockerfile` để tránh lỗi `Storage folder (/storage) not found!` xảy ra khi Railway khởi chạy container không kèm ổ đĩa gắn ngoài (Volume).
- **Vá lỗi tự ngắt container do thiếu KVM (Exit 88)**: Mặc định tắt kiểm tra ảo hóa phần cứng (`KVM="N"`) giúp container hoạt động ổn định thông qua cơ chế giả lập phần mềm (Software Emulation) mà không bị crash hay tự động tắt với mã lỗi `88`.
- **Tối ưu RAM động (`RAM_SIZE="max"`)**: Tự động tính toán và phân bổ lượng RAM tối đa an toàn mà container của Railway cho phép (thường là khoảng 465MB trên gói 1GB RAM) giúp tránh bị tràn RAM máy chủ.
- **Giao diện Web trực quan (noVNC)**: Truy cập trực tiếp Windows thông qua trình duyệt web ở cổng `8006` mà không cần cài đặt thêm phần mềm RDP nào khác.
- **Hỗ trợ Remote Desktop (RDP)**: Có thể kết nối qua cổng `3389` bằng phần mềm Remote Desktop Connection mặc định trên máy tính của bạn.
- **Tối ưu dung lượng (Sparse Disk)**: Sử dụng định dạng `qcow2` giúp ổ đĩa ảo co giãn động, bắt đầu từ kích thước cực kỳ nhỏ và chỉ tăng lên khi có dữ liệu mới, tránh bị vượt quá hạn mức ổ đĩa của Railway.

## 🛠️ Triển khai lên Railway

Chỉ cần đẩy repository này lên GitHub của bạn và kết nối với Railway. Railway sẽ tự động nhận diện `Dockerfile` và tiến hành build.

### Các biến môi trường tùy chỉnh (Environment Variables)

Bạn có thể chỉnh sửa các biến này trực tiếp trong tab **Variables** trên Railway để thay đổi cấu hình phần cứng:

| Biến môi trường | Giá trị mặc định | Giải thích |
|---|---|---|
| `VERSION` | `tiny10` | Phiên bản Windows (`tiny10` cho Windows 10 siêu nhẹ - khuyên dùng; đổi thành `10` nếu muốn dùng Windows 10 Pro gốc). |
| `RAM_SIZE` | `max` | Để `max` để hệ thống tự động lấy lượng RAM tối đa an toàn từ Railway. |
| `CPU_CORES` | `2` | Số lượng nhân CPU cấp cho máy ảo. |
| `DISK_SIZE` | `32G` | Dung lượng tối đa của ổ đĩa ảo. |
| `DISK_FMT` | `qcow2` | Định dạng ổ đĩa ảo. Khuyên dùng `qcow2` để tiết kiệm tài nguyên trên Cloud. |
| `KVM` | `N` | Khuyên dùng `N` trên Railway. Đặt thành `Y` nếu môi trường của bạn hỗ trợ KVM phần cứng lồng nhau. |
| `LANGUAGE` | `English` | Ngôn ngữ hệ điều hành. |
| `USERNAME` | `Docker` | Tên tài khoản Windows mặc định. |
| `PASSWORD` | `admin` | Mật khẩu đăng nhập mặc định. |

## 🖥️ Hướng dẫn truy cập và sử dụng

### 1. Truy cập qua trình duyệt Web (Khuyên dùng khi cài đặt)

- Sau khi deploy thành công trên Railway, bạn hãy bật tính năng **Public Networking / Generate Domain** để lấy URL công khai.
- Truy cập vào đường dẫn URL đó (Railway sẽ tự động định tuyến traffic đến cổng `8006` của container).
- Bạn sẽ thấy giao diện cài đặt Windows tự động chạy. Hãy giữ trình duyệt mở và đợi khoảng 15-20 phút cho đến khi màn hình Desktop của Windows xuất hiện.
- **Tài khoản đăng nhập mặc định:**
  - **Username:** `Docker`
  - **Password:** `admin`

### 2. Kết nối bằng Remote Desktop (RDP)

Để có trải nghiệm mượt mà, phản hồi nhanh và hỗ trợ copy-paste Clipboard tốt hơn, bạn nên kết nối bằng RDP:
- Cấu hình một cổng TCP công khai trên Railway định tuyến tới cổng `3389` của container.
- Mở ứng dụng **Remote Desktop Connection (mstsc)** trên máy tính cá nhân của bạn.
- Điền IP/Domain và cổng TCP do Railway cung cấp.
- Đăng nhập với tài khoản: `Docker` / `admin`.

## 💻 Chạy thử nghiệm dưới Local (Docker)

Nếu bạn muốn chạy thử nghiệm trên máy tính cá nhân trước (hỗ trợ KVM để chạy siêu nhanh):

```bash
docker run -it --rm --name windows -e "VERSION=tiny10" -p 8006:8006 -p 3389:3389/tcp --device=/dev/kvm --cap-add NET_ADMIN -v "./windows:/storage" dockurr/windows
```
