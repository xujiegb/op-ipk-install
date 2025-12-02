# op-ipk-install

<p align="center">
  <img src="https://github.com/user-attachments/assets/d74ee14c-e75b-47e1-9f67-f5bc126d77f6"
       width="150" height="150" alt="logo"/>
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
### 感谢
Fedora Project
```URL
https://www.fedoraproject.org/
```
