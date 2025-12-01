# op-ipk-install

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
