# Windows 10 inside Docker for Railway

Repository này đã được cấu hình lại để chạy **Windows 10** mượt mà bên trong Docker container sử dụng dự án mã nguồn mở [dockurr/windows](https://github.com/dockur/windows). Cấu hình này cực kỳ tối ưu để triển khai lên các dịch vụ Cloud như **Railway**.

## 🚀 Tính năng nổi bật

- **Chạy Windows 10 mượt mà**: Sử dụng nhân QEMU giả lập Windows bên trong Linux container.
- **Giao diện Web trực quan (noVNC)**: Truy cập trực tiếp Windows thông qua trình duyệt web ở cổng `8006` mà không cần cài đặt thêm phần mềm RDP nào khác.
- **Hỗ trợ Remote Desktop (RDP)**: Có thể kết nối qua cổng `3389` bằng phần mềm Remote Desktop Connection mặc định trên máy tính của bạn.
- **Tối ưu dung lượng (Sparse Disk)**: Sử dụng định dạng `qcow2` giúp ổ đĩa ảo co giãn động, bắt đầu từ kích thước cực kỳ nhỏ và chỉ tăng lên khi có dữ liệu mới, tránh bị vượt quá hạn mức ổ đĩa của Railway.
- **Tự động cài đặt**: Khi khởi chạy lần đầu, container sẽ tự động tải ISO Windows 10 chính gốc từ Microsoft và tự động thực hiện quá trình cài đặt (OOBE) từ A-Z mà không cần bạn phải click chuột.

## 🛠️ Triển khai lên Railway

Chỉ cần đẩy repository này lên GitHub của bạn và kết nối với Railway. Railway sẽ tự động nhận diện `Dockerfile` và tiến hành build.

### Các biến môi trường tùy chỉnh (Environment Variables)

Bạn có thể chỉnh sửa các biến này trực tiếp trong tab **Variables** trên Railway để thay đổi cấu hình phần cứng:

| Biến môi trường | Giá trị mặc định | Giải thích |
|---|---|---|
| `VERSION` | `10` | Phiên bản Windows (`10` cho Windows 10 Pro, `11` cho Windows 11, `tiny10` cho phiên bản siêu nhẹ). |
| `RAM_SIZE` | `4G` | Dung lượng RAM cấp cho Windows (ví dụ: `2G`, `4G`, `8G`). |
| `CPU_CORES` | `2` | Số lượng nhân CPU (ví dụ: `2`, `4`). |
| `DISK_SIZE` | `32G` | Dung lượng tối đa của ổ đĩa ảo. |
| `DISK_FMT` | `qcow2` | Định dạng ổ đĩa ảo. Khuyên dùng `qcow2` để tiết kiệm tài nguyên trên Cloud. |
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

Nếu bạn muốn chạy thử nghiệm trên máy tính cá nhân trước:

```bash
docker run -it --rm --name windows -e "VERSION=10" -p 8006:8006 -p 3389:3389/tcp --device=/dev/kvm --cap-add NET_ADMIN -v "./windows:/storage" dockurr/windows
```

*Lưu ý: Chạy dưới máy cá nhân có hỗ trợ KVM phần cứng sẽ mượt mà hơn rất nhiều so với chạy trên Cloud không có KVM.*
