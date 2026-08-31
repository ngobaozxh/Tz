# Windows 10 inside Docker for Railway

Repository này đã được cấu hình lại để chạy **Windows 10** mượt mà bên trong Docker container sử dụng dự án mã nguồn mở [dockurr/windows](https://github.com/dockur/windows). Cấu hình này cực kỳ tối ưu và đã được áp dụng các bản vá "gian lận" đặc biệt để vượt qua mọi giới hạn phần cứng của **Railway**, giúp bạn chỉ cần deploy là chạy vù vù không lỗi!

---

## 🔴 GIẢI QUYẾT LỖI CONTAINER BỊ RESET / TẢI LẠI LIÊN TỤC

Khi bạn deploy lên Railway và thấy thanh tiến trình đạt 100% ("Download completed successfully") nhưng sau đó hệ thống lại tự động reset và quay về bước "Downloading Tiny 10... 0%", nguyên nhân là:

1.  **Hết RAM (OOM - Out of Memory)**: Giai đoạn bắt đầu cài đặt Windows của QEMU tiêu tốn nhiều tài nguyên. Nếu container vượt quá hạn mức RAM của Railway, Railway sẽ cưỡng bức tắt container (Kill) để bảo vệ hệ thống.
2.  **Ổ cứng tạm thời (Ephemeral Disk)**: Theo mặc định, ổ cứng của container trên Railway là ổ cứng tạm thời. Khi container bị tắt hoặc restart, toàn bộ dữ liệu đã tải về và cài đặt trước đó ở thư mục `/storage` sẽ bị xóa sạch, bắt buộc hệ thống phải tải lại file ISO 3.6GB từ đầu.

### ✔️ CÁCH KHẮC PHỤC TRIỆT ĐỂ (BẮT BUỘC): Gắn Railway Volume
Bạn **phải gắn một ổ đĩa cứng vĩnh viễn (Volume)** vào thư mục `/storage` trên Railway. Việc này giúp lưu lại vĩnh viễn file ISO và ổ đĩa cài đặt Windows, chỉ cần tải và cài đặt đúng **1 lần duy nhất**, từ các lần sau Windows sẽ khởi động trực tiếp trong vòng vài giây!

**Cách thêm Volume trên Railway:**
1.  Truy cập vào trang dự án của bạn trên Dashboard Railway.
2.  Bấm nút **+ New** (hoặc góc trên bên phải) -> Chọn **Volume**.
3.  Trong phần cài đặt Volume, đặt **Mount Path** là `/storage`.
4.  Tiến hành **Redeploy** lại dịch vụ. 
*Kể từ bây giờ, Windows sẽ cài thẳng vào Volume này và không bao giờ bị mất hay phải tải lại nữa!*

---

## 🚀 Tính năng nổi bật & Bản Vá "Gian Lận" Tối Ưu Cho Railway

- **SỬ DỤNG TỐI ĐA (MAX) CẤU HÌNH THẬT CỦA RAILWAY**:
  * `CPU_CORES="max"`: Ép QEMU sử dụng toàn bộ số nhân CPU thực tế của máy chủ Railway cấp cho bạn.
  * `RAM_SIZE="max"`: Tự động phân bổ lượng RAM lớn nhất có thể từ container cho Windows.
- **GIAN LẬN RAM DỰ PHÒNG (`RAM_SPARE=80MB`)**:
  * *Vấn đề*: QEMU mặc định luôn bóp lại 500MB RAM của container để làm RAM dự phòng cho hệ điều hành Host. Trên gói 1GB của Railway, việc này khiến Windows chỉ còn vỏn vẹn 465MB RAM để hoạt động (cực kỳ lag và dễ crash OOM).
  * *Bản vá*: Đã thêm lệnh `RUN sed -i 's/RAM_SPARE=500000000/RAM_SPARE=80000000/g' /run/memory.sh` để hạ RAM dự phòng xuống còn **80MB**. Máy ảo Windows của bạn sẽ được tận dụng tới **90% dung lượng RAM thật của Railway** (hơn 850MB RAM trên gói 1GB), giúp mượt mà và ổn định hơn rất nhiều!
- **GIAN LẬN RAM tối thiểu (Bypass RAM Check)**: Hạ mức RAM yêu cầu tối thiểu của Windows 10 từ 2GB xuống còn **128MB** (`RUN sed -i 's/echo "2G"/echo "128M"/g' /run/define.sh`), lách qua bài kiểm tra RAM của container thành công.
- **Chạy Windows 10 siêu nhẹ (Tiny10)**: Mặc định cài đặt phiên bản **Tiny10** (bản rút gọn cực kỳ nhẹ của Windows 10, chỉ nặng 3.6 GB thay vì 5.7 GB). Phiên bản này đã lược bỏ hết bloatware, dịch vụ thừa và telemetry, giúp chạy cực kỳ mượt mà trên môi trường RAM thấp.
- **Vá lỗi `/storage` không tìm thấy (Sửa lỗi crash)**: Đã tạo sẵn thư mục `/storage` và cấp toàn quyền đọc ghi (`chmod 777`) ngay trong `Dockerfile` để tránh lỗi `Storage folder (/storage) not found!` xảy ra khi Railway khởi chạy container không kèm ổ đĩa gắn ngoài (Volume).
- **Vá lỗi tự ngắt container do thiếu KVM (Exit 88)**: Mặc định tắt kiểm tra ảo hóa phần cứng (`KVM="N"`) giúp container hoạt động ổn định thông qua cơ chế giả lập phần mềm (Software Emulation) mà không bị crash hay tự động tắt với mã lỗi `88`.

## 🛠️ Triển khai lên Railway

Chỉ cần đẩy repository này lên GitHub của bạn và kết nối với Railway. Railway sẽ tự động nhận diện `Dockerfile` và tiến hành build.

### Các biến môi trường tùy chỉnh (Environment Variables)

Bạn có thể chỉnh sửa các biến này trực tiếp trong tab **Variables** trên Railway để thay đổi cấu hình phần cứng:

| Biến môi trường | Giá trị mặc định | Giải thích |
|---|---|---|
| `VERSION` | `tiny10` | Phiên bản Windows (`tiny10` cho Windows 10 siêu nhẹ - khuyên dùng; đổi thành `10` nếu muốn dùng Windows 10 Pro gốc). |
| `RAM_SIZE` | `max` | Để `max` để hệ thống tự động lấy lượng RAM tối đa an toàn từ Railway (kết hợp bypass RAM_SPARE). |
| `CPU_CORES` | `max` | Ép dùng tối đa toàn bộ số nhân CPU thực tế của máy chủ Railway. |
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
