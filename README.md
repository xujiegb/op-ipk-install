# op-ipk-install

<p align="center">
  <img src="https://github.com/user-attachments/assets/cacfc7dd-485d-4c9a-ac1f-271daf1fe8b6"
       width="130" height="130" alt="logo"/>
</p>

<p align="center">
  <strong>Made by</strong>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/f06c77a5-a4c8-44af-9f81-e9df13619fe6"
       width="75" height="75" alt="logo"/>
</p>

上传、安装ipk/apk脚本

### macOS/Linux
opkg
```bash
bash <(curl -Ls https://raw.githubusercontent.com/xujiegb/op-ipk-install/refs/heads/main/opinstall.sh)
```
apk
```bash
bash <(curl -Ls https://raw.githubusercontent.com/xujiegb/op-ipk-install/refs/heads/main/apkinstall.sh)
```
### Windows
opkg
```powershell
irm https://raw.githubusercontent.com/xujiegb/op-ipk-install/master/opinstall.ps1 | iex
```
apk
```powershell
irm https://raw.githubusercontent.com/xujiegb/op-ipk-install/master/apkinstall.ps1 | iex
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
