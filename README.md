# op-ipk-install

<p align="center">
  <img src="https://github.com/user-attachments/assets/1d99123a-dc68-4656-8f09-8629e0990f52"
       width="130" height="130" alt="logo"/>
</p>
<p align="center">
  <strong>Made by</strong>
</p>
<p align="center">
  <img src="https://github.com/user-attachments/assets/047b3452-7450-4c8c-8493-140b8b073ec0"
       width="75" height="75" alt="logo"/>
</p>

上传、安装ipk脚本

### macOS/Linux
```bash
bash <(curl -Ls https://raw.githubusercontent.com/xujiegb/op-ipk-install/refs/heads/main/opinstall.sh)
```
### Windows
```powershell
irm https://raw.githubusercontent.com/xujiegb/op-ipk-install/master/opinstall.ps1 | iex
```
### 查询系统架构信息
SSH连接路由器或者到路由器管理界面终端查询
```bash
opkg print-architecture
cat /etc/os-release
```
### 系统要求
桌面系统
```system
【 Windows 】

  Windows 10 +

【 Linux 】 (Gnome | KDE Plasma | Pantheon)

  Red Hat Enterprise Linux 10 +
  RockyLinux 10 +
  AlmaLinux 10 +
  Fedora Linux 43 +

  Debian Linux 13 +
  Ubuntu Linux 24.04 +
  Elementary OS 8 +

【 macOS 】

  macOS 15+
```
### 感谢
Fedora Project
```URL
https://www.fedoraproject.org/
```
