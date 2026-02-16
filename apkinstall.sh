#!/usr/bin/env bash
set -euo pipefail

LANG_CODE="en"
USER_NAME=""
HOST_IP=""
HOST_PORT=22
AUTH_METHOD=""
KEY_FILE=""
TEMP_KEY_FILE=""
SSH_BASE_OPTS="-o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=/dev/null"
SSH_PASSWORD=""
TEMP_ASKPASS_FILE=""

RESULT_FILES=()
RESULT_STATUS=()
RESULT_REASON=()
PKG_MANAGER=""

msg() {
  local key="$1"
  case "$key" in
    lang_menu)
      echo "Hello"
      ;;
  esac
}

msg_line() {
  local key="$1"
  case "$LANG_CODE:$key" in
    *:lang_options)
      echo "1) 简体中文  2) 繁體中文  3) English  4) Français";;

    zh_CN:invalid_choice) echo "无效选择，请重新输入。";;
    zh_TW:invalid_choice) echo "無效選擇，請重新輸入。";;
    en:invalid_choice)    echo "Invalid choice, please try again.";;
    fr:invalid_choice)    echo "Choix invalide, veuillez réessayer。";;

    zh_CN:no_files) echo "请把 .apk 文件路径拖到脚本后面再执行。";;
    zh_TW:no_files) echo "請將 .apk 檔案路徑拖到腳本後面再執行。";;
    en:no_files)    echo "Please drag .apk file paths after this script and run again.";;
    fr:no_files)    echo "Veuillez glisser les fichiers .apk après ce script puis l'exécuter。";;

    zh_CN:prompt_user) echo -n "请输入 OpenWrt 用户名（默认 root）：";;
    zh_TW:prompt_user) echo -n "請輸入 OpenWrt 使用者名稱（預設 root）：";;
    en:prompt_user)    echo -n "Enter OpenWrt username (default root): ";;
    fr:prompt_user)    echo -n "Entrez le nom d'utilisateur OpenWrt (par défaut root) : ";;

    zh_CN:prompt_ip) echo -n "请输入 OpenWrt IP 或主机名：";;
    zh_TW:prompt_ip) echo -n "請輸入 OpenWrt IP 或主機名稱：";;
    en:prompt_ip)    echo -n "Enter OpenWrt IP or hostname: ";;
    fr:prompt_ip)    echo -n "Entrez l'adresse IP ou le nom d'hôte OpenWrt : ";;

    zh_CN:prompt_port) echo -n "请输入 SSH 端口（默认 22）：";;
    zh_TW:prompt_port) echo -n "請輸入 SSH 連接埠（預設 22）：";;
    en:prompt_port)    echo -n "Enter SSH port (default 22): ";;
    fr:prompt_port)    echo -n "Entrez le port SSH (par défaut 22) : ";;

    zh_CN:auth_menu)
      echo "请选择认证方式：1) 密码登录  2) 密钥文件  3) 粘贴私钥";;
    zh_TW:auth_menu)
      echo "請選擇認證方式：1) 密碼登入  2) 金鑰檔案  3) 貼上私鑰";;
    en:auth_menu)
      echo "Select auth method: 1) Password  2) Key file  3) Paste private key";;
    fr:auth_menu)
      echo "Choisissez la méthode d'authentification : 1) Mot de passe  2) Fichier de clé  3) Coller la clé privée";;

    zh_CN:prompt_auth_choice) echo -n "请输入选项 (1/2/3)：";;
    zh_TW:prompt_auth_choice) echo -n "請輸入選項 (1/2/3)：";;
    en:prompt_auth_choice)    echo -n "Enter choice (1/2/3): ";;
    fr:prompt_auth_choice)    echo -n "Entrez le choix (1/2/3) : ";;

    zh_CN:info_password_ssh) echo "将使用密码登录，请在 ssh 提示时输入密码。";;
    zh_TW:info_password_ssh) echo "將使用密碼登入，請在 ssh 提示時輸入密碼。";;
    en:info_password_ssh)    echo "Password login selected. Please enter your password when ssh prompts.";;
    fr:info_password_ssh)    echo "Authentification par mot de passe. Entrez votre mot de passe lorsque ssh le demande。";;

    zh_CN:prompt_key_path) echo -n "请拖拽私钥文件路径到这里，然后回车：";;
    zh_TW:prompt_key_path) echo -n "請拖曳私鑰檔案路徑到這裡，然後按 Enter：";;
    en:prompt_key_path)    echo -n "Drag & drop your private key file path here, then press Enter: ";;
    fr:prompt_key_path)    echo -n "Glissez le chemin du fichier de clé privée ici, puis Entrée : ";;

    zh_CN:prompt_paste_key)
      echo "请粘贴你的私钥内容（以 -----END 开头的一行结束），然后回车：";;
    zh_TW:prompt_paste_key)
      echo "請貼上你的私鑰內容（以 -----END 開頭的一行結束），然後按 Enter：";;
    en:prompt_paste_key)
      echo "Paste your private key. End input with a line starting with -----END, then press Enter:";;
    fr:prompt_paste_key)
      echo "Collez votre clé privée. Terminez par une ligne commençant par -----END, puis Entrée :";;

    zh_CN:testing_conn) echo "正在测试 SSH 连接，请按提示输入密码（如需要）……";;
    zh_TW:testing_conn) echo "正在測試 SSH 連線，若需要請依提示輸入密碼……";;
    en:testing_conn)    echo "Testing SSH connection, please enter password if prompted...";;
    fr:testing_conn)    echo "Test de la connexion SSH, entrez le mot de passe si demandé...";;

    zh_CN:conn_failed) echo "SSH 连接失败，请检查 IP/端口/用户名/认证方式。";;
    zh_TW:conn_failed) echo "SSH 連線失敗，請檢查 IP/連接埠/使用者/認證方式。";;
    en:conn_failed)    echo "SSH connection failed. Please check IP/port/username/auth method.";;
    fr:conn_failed)    echo "La connexion SSH a échoué. Vérifiez IP/port/utilisateur/méthode d'authentification。";;

    zh_CN:retry_menu) echo "1) 重新尝试  2) 退出";;
    zh_TW:retry_menu) echo "1) 重新嘗試  2) 退出";;
    en:retry_menu)    echo "1) Retry  2) Exit";;
    fr:retry_menu)    echo "1) Réessayer  2) Quitter";;

    zh_CN:processing_files) echo "开始处理 .apk 文件（逐个上传并安装）……";;
    zh_TW:processing_files) echo "開始處理 .apk 檔案（逐一上傳並安裝）……";;
    en:processing_files)    echo "Starting to process .apk files (upload & install one by one)...";;
    fr:processing_files)    echo "Traitement des fichiers .apk (téléversement et installation un par un)...";;

    zh_CN:upload_failed) echo "上传失败。";;
    zh_TW:upload_failed) echo "上傳失敗。";;
    en:upload_failed)    echo "Upload failed.";;
    fr:upload_failed)    echo "Échec du téléversement。";;

    zh_CN:upload_fail_menu) echo "请选择：1) 重试  2) 忽略并处理下一个  3) 退出";;
    zh_TW:upload_fail_menu) echo "請選擇：1) 重試  2) 忽略並處理下一個  3) 退出";;
    en:upload_fail_menu)    echo "Choose: 1) Retry  2) Ignore & next  3) Exit";;
    fr:upload_fail_menu)    echo "Choisissez : 1) Réessayer  2) Ignorer & suivant  3) Quitter";;

    zh_CN:install_failed) echo "安装失败，错误信息如下（来自 apk）：";;
    zh_TW:install_failed) echo "安裝失敗，錯誤訊息如下（來自 apk）：";;
    en:install_failed)    echo "Install failed, error output from apk:";;
    fr:install_failed)    echo "Échec de l'installation, sortie d'erreur d'apk :";;

    zh_CN:install_fail_menu_dep) echo "请选择：1) 重试  2) 忽略  3) 退出  4) 强制安装（忽略依赖）";;
    zh_TW:install_fail_menu_dep) echo "請選擇：1) 重試  2) 忽略  3) 退出  4) 強制安裝（忽略依賴）";;
    en:install_fail_menu_dep)    echo "Choose: 1) Retry  2) Ignore  3) Exit  4) Force install (ignore deps)";;
    fr:install_fail_menu_dep)    echo "Choisissez : 1) Réessayer  2) Ignorer  3) Quitter  4) Forcer l'installation (ignorer les dépendances)";;

    zh_CN:install_fail_menu) echo "请选择：1) 重试  2) 忽略  3) 退出";;
    zh_TW:install_fail_menu) echo "請選擇：1) 重試  2) 忽略  3) 退出";;
    en:install_fail_menu)    echo "Choose: 1) Retry  2) Ignore  3) Exit";;
    fr:install_fail_menu)    echo "Choisissez : 1) Réessayer  2) Ignorer  3) Quitter";;

    zh_CN:force_installing) echo "正在尝试强制安装（--force-broken-world / --allow-untrusted）……";;
    zh_TW:force_installing) echo "正在嘗試強制安裝（--force-broken-world / --allow-untrusted）……";;
    en:force_installing)    echo "Trying force install (--force-broken-world / --allow-untrusted)...";;
    fr:force_installing)    echo "Tentative d'installation forcée (--force-broken-world / --allow-untrusted)...";;

    zh_CN:install_success) echo "安装成功。";;
    zh_TW:install_success) echo "安裝成功。";;
    en:install_success)    echo "Install succeeded.";;
    fr:install_success)    echo "Installation réussie.";;

    zh_CN:summary_title) echo "=== 安装结果汇总 ===";;
    zh_TW:summary_title) echo "=== 安裝結果總結 ===";;
    en:summary_title)    echo "=== Installation summary ===";;
    fr:summary_title)    echo "=== Récapitulatif d'installation ===";;

    zh_CN:summary_ok) echo "[成功]";;
    zh_TW:summary_ok) echo "[成功]";;
    en:summary_ok)    echo "[OK]";;
    fr:summary_ok)    echo "[OK]";;

    zh_CN:summary_fail) echo "[失败]";;
    zh_TW:summary_fail) echo "[失敗]";;
    en:summary_fail)    echo "[FAILED]";;
    fr:summary_fail)    echo "[ÉCHEC]";;

    zh_CN:goodbye) echo "任务结束，脚本退出。";;
    zh_TW:goodbye) echo "任務結束，腳本退出。";;
    en:goodbye)    echo "All done. Exiting.";;
    fr:goodbye)    echo "Terminé. Sortie du script。";;

    zh_CN:select_file_mode)   echo "请选择 .apk 文件获取方式：1) 拖拽到终端  2) 使用系统文件选择器";;
    zh_TW:select_file_mode)   echo "請選擇 .apk 檔案取得方式：1) 拖曳到終端機  2) 使用系統檔案選擇器";;
    en:select_file_mode)      echo "Choose how to select .apk files: 1) Drag into terminal  2) Use system file chooser";;
    fr:select_file_mode)      echo "Choisissez comment sélectionner les fichiers .apk : 1) Glisser dans le terminal  2) Utiliser le sélecteur de fichiers du système";;

    zh_CN:select_file_drag)   echo "方式 1：在终端中按提示拖拽 .apk 文件路径。";;
    zh_TW:select_file_drag)   echo "方式 1：依照終端提示拖曳 .apk 檔案路徑。";;
    en:select_file_drag)      echo "Mode 1: drag .apk file paths into the terminal when prompted.";;
    fr:select_file_drag)      echo "Mode 1 : faites glisser les chemins de fichiers .apk dans le terminal lorsque demandé。";;

    zh_CN:select_file_dialog) echo "方式 2：弹出系统文件窗口（Finder / KDE / GNOME）选择 .apk 文件。";;
    zh_TW:select_file_dialog) echo "方式 2：彈出系統檔案視窗（Finder / KDE / GNOME）選擇 .apk 檔案。";;
    en:select_file_dialog)    echo "Mode 2: open system file dialog (Finder / KDE / GNOME) to choose .apk files.";;
    fr:select_file_dialog)    echo "Mode 2 : ouvrir la boîte de dialogue du système (Finder / KDE / GNOME) pour choisir les fichiers .apk。";;

    zh_CN:invalid_filename_header) echo "以下文件名不合法（仅允许英文、数字以及 . _ - 三种符号）：" ;;
    zh_TW:invalid_filename_header) echo "以下檔名不合法（僅允許英文、數字以及 . _ - 三種符號）：" ;;
    en:invalid_filename_header)    echo "These file names are invalid (only letters, digits and . _ - are allowed):" ;;
    fr:invalid_filename_header)    echo "Les noms de fichiers suivants sont invalides (seuls les lettres, chiffres et . _ - sont autorisés) :" ;;

    zh_CN:invalid_filename_footer) echo "请重命名以上文件后重新运行脚本。";;
    zh_TW:invalid_filename_footer) echo "請重新命名以上檔案後重新執行腳本。";;
    en:invalid_filename_footer)    echo "Please rename the above files and run the script again.";;
    fr:invalid_filename_footer)    echo "Veuillez renommer les fichiers ci-dessus et relancer le script.";;
  esac
}

detect_distro() {
  PKG_MANAGER=""
  if [ -r /etc/os-release ]; then
    . /etc/os-release
    case "${ID:-}" in
      rhel|rocky|almalinux|fedora|centos)
        PKG_MANAGER="dnf"
        ;;
      debian|ubuntu)
        PKG_MANAGER="apt"
        ;;
      *)
        PKG_MANAGER=""
        ;;
    esac
  fi
}

install_gui_deps_linux() {
  detect_distro
  echo "Trying to install GUI file chooser dependencies (zenity + xdg-utils)..."
  if [ "$PKG_MANAGER" = "dnf" ]; then
    echo "Detected dnf-based distro, running: sudo dnf install -y zenity xdg-utils"
    sudo dnf install -y zenity xdg-utils || true
  elif [ "$PKG_MANAGER" = "apt" ]; then
    echo "Detected apt-based distro, running: sudo apt install -y zenity xdg-utils"
    sudo apt update || true
    sudo apt install -y zenity xdg-utils || true
  else
    echo "Unsupported or unknown Linux distribution for auto-install."
    echo "Please manually install 'zenity' and 'xdg-utils'."
  fi
}

os_check() {
  local kernel os_name os_version
  kernel="$(uname -s 2>/dev/null || echo unknown)"

  case "$kernel" in
    Darwin)
      os_name="macOS"
      os_version="$(sw_vers -productVersion 2>/dev/null || echo unknown)"
      case "$LANG_CODE" in
        zh_CN)
          echo "检测到系统：${os_name} ${os_version}（内核 $(uname -r)）"
          echo "支持的系统：macOS、Red Hat Enterprise Linux、Fedora、CentOS、Rocky Linux、AlmaLinux、Ubuntu、Debian、elementaryOS"
          ;;
        zh_TW)
          echo "偵測到系統：${os_name} ${os_version}（核心 $(uname -r)）"
          echo "支援的系統：macOS、Red Hat Enterprise Linux、Fedora、CentOS、Rocky Linux、AlmaLinux、Ubuntu、Debian、elementaryOS"
          ;;
        fr)
          echo "Système détecté : ${os_name} ${os_version} (noyau $(uname -r))"
          echo "Systèmes pris en charge : macOS, Red Hat Enterprise Linux, Fedora, CentOS, Rocky Linux, AlmaLinux, Ubuntu, Debian, elementaryOS"
          ;;
        *)
          echo "Detected system: ${os_name} ${os_version} (kernel $(uname -r))"
          echo "Supported systems: macOS, Red Hat Enterprise Linux, Fedora, CentOS, Rocky Linux, AlmaLinux, Ubuntu, Debian, elementaryOS"
          ;;
      esac
      ;;

    Linux)
      if [ ! -r /etc/os-release ]; then
        case "$LANG_CODE" in
          zh_CN)
            echo "无法检测当前 Linux 发行版（缺少 /etc/os-release），脚本仅支持：macOS、RHEL、Fedora、CentOS、Rocky、AlmaLinux、Ubuntu、Debian、elementaryOS。"
            ;;
          zh_TW)
            echo "無法偵測目前的 Linux 發行版（缺少 /etc/os-release），腳本僅支援：macOS、RHEL、Fedora、CentOS、Rocky、AlmaLinux、Ubuntu、Debian、elementaryOS。"
            ;;
          fr)
            echo "Impossible de détecter la distribution Linux actuelle (/etc/os-release manquant). Le script ne prend en charge que : macOS, RHEL, Fedora, CentOS, Rocky, AlmaLinux, Ubuntu, Debian, elementaryOS."
            ;;
          *)
            echo "Cannot detect current Linux distribution (missing /etc/os-release)."
            echo "Supported systems: macOS, RHEL, Fedora, CentOS, Rocky, AlmaLinux, Ubuntu, Debian, elementaryOS."
            ;;
        esac
        exit 1
      fi

      . /etc/os-release

      local supported=0
      case "${ID:-}" in
        rhel|rocky|almalinux|fedora|centos|centos-stream|ubuntu|debian|elementary)
          supported=1
          ;;
      esac

      if [ "$supported" -ne 1 ] && [ -n "${ID_LIKE:-}" ]; then
        case "$ID_LIKE" in
          *rhel*|*fedora*|*centos*|*rocky*|*almalinux*|*ubuntu*|*debian*)
            supported=1
            ;;
        esac
      fi

      os_name="${NAME:-Linux}"
      os_version="${VERSION:-}"

      if [ "$supported" -ne 1 ]; then
        case "$LANG_CODE" in
          zh_CN)
            echo "不支持的系统：${os_name} ${os_version}（ID='${ID:-}', ID_LIKE='${ID_LIKE:-}'）"
            echo "仅支持：macOS、Red Hat Enterprise Linux、Fedora、CentOS、Rocky Linux、AlmaLinux、Ubuntu、Debian、elementaryOS。"
            ;;
          zh_TW)
            echo "不支援的系統：${os_name} ${os_version}（ID='${ID:-}', ID_LIKE='${ID_LIKE:-}'）"
            echo "僅支援：macOS、Red Hat Enterprise Linux、Fedora、CentOS、Rocky Linux、AlmaLinux、Ubuntu、Debian、elementaryOS。"
            ;;
          fr)
            echo "Système non pris en charge : ${os_name} ${os_version} (ID='${ID:-}', ID_LIKE='${ID_LIKE:-}')"
            echo "Systèmes pris en charge : macOS, Red Hat Enterprise Linux, Fedora, CentOS, Rocky Linux, AlmaLinux, Ubuntu, Debian, elementaryOS."
            ;;
          *)
            echo "Unsupported system: ${os_name} ${os_version} (ID='${ID:-}', ID_LIKE='${ID_LIKE:-}')"
            echo "Supported systems: macOS, Red Hat Enterprise Linux, Fedora, CentOS, Rocky Linux, AlmaLinux, Ubuntu, Debian, elementaryOS."
            ;;
        esac
        exit 1
      fi

      case "$LANG_CODE" in
        zh_CN)
          echo "检测到系统：${os_name} ${os_version}（内核 $(uname -r)）"
          echo "系统检查通过。"
          ;;
        zh_TW)
          echo "偵測到系統：${os_name} ${os_version}（核心 $(uname -r)）"
          echo "系統檢查通過。"
          ;;
        fr)
          echo "Système détecté : ${os_name} ${os_version} (noyau $(uname -r))"
          echo "Vérification du système réussie."
          ;;
        *)
          echo "Detected system: ${os_name} ${os_version} (kernel $(uname -r))"
          echo "System check passed."
          ;;
      esac
      ;;

    *)
      case "$LANG_CODE" in
        zh_CN)
          echo "不支持的内核：${kernel}。仅支持：macOS、Linux（RHEL/Fedora/CentOS/Rocky/AlmaLinux/Ubuntu/Debian/elementaryOS）。"
          ;;
        zh_TW)
          echo "不支援的核心：${kernel}。僅支援：macOS、Linux（RHEL/Fedora/CentOS/Rocky/AlmaLinux/Ubuntu/Debian/elementaryOS）。"
          ;;
        fr)
          echo "Noyau non pris en charge : ${kernel}. Systèmes pris en charge : macOS, Linux (RHEL/Fedora/CentOS/Rocky/AlmaLinux/Ubuntu/Debian/elementaryOS)."
          ;;
        *)
          echo "Unsupported kernel: ${kernel}. Supported: macOS and Linux (RHEL/Fedora/CentOS/Rocky/AlmaLinux/Ubuntu/Debian/elementaryOS)."
          ;;
      esac
      exit 1
      ;;
  esac
}

select_language() {
  while true; do
    msg lang_menu
    msg_line lang_options
    read -r choice
    case "$choice" in
      1) LANG_CODE="zh_CN"; break;;
      2) LANG_CODE="zh_TW"; break;;
      3) LANG_CODE="en";    break;;
      4) LANG_CODE="fr";    break;;
      *)
        echo "Error"
        ;;
    esac
  done
}

prompt_basic_info() {
  msg_line prompt_user
  read -r USER_NAME
  if [ -z "${USER_NAME}" ]; then
    USER_NAME="root"
  fi

  while true; do
    msg_line prompt_ip
    read -r HOST_IP
    [ -n "$HOST_IP" ] && break
  done

  msg_line prompt_port
  read -r port_in
  if [ -n "${port_in:-}" ]; then
    HOST_PORT="$port_in"
  fi
}

prompt_auth_method() {
  while true; do
    msg_line auth_menu
    msg_line prompt_auth_choice
    read -r choice
    case "$choice" in
      1)
        AUTH_METHOD="password"
        msg_line info_password_ssh
        echo
        echo -n "请输入 SSH 密码："
        read -rs SSH_PASSWORD
        echo
        export SSH_PASSWORD
        break
        ;;
      2)
        AUTH_METHOD="keyfile"
        msg_line prompt_key_path
        read -r KEY_FILE
        KEY_FILE="${KEY_FILE//\'/}"
        KEY_FILE="${KEY_FILE//\"/}"
        ;;
      3)
        AUTH_METHOD="pastekey"
        msg_line prompt_paste_key
        TEMP_KEY_FILE="$(mktemp /tmp/opinstall_key_XXXXXX)"
        chmod 600 "$TEMP_KEY_FILE"
        while IFS= read -r line; do
          echo "$line" >> "$TEMP_KEY_FILE"
          case "$line" in
            -----END*) break;;
          esac
        done
        KEY_FILE="$TEMP_KEY_FILE"
        ;;
      *)
        msg_line invalid_choice
        continue
        ;;
    esac

    if [ "$AUTH_METHOD" != "password" ]; then
      if [ ! -f "$KEY_FILE" ]; then
        echo "Key file not found: $KEY_FILE"
        continue
      fi
      chmod 600 "$KEY_FILE" 2>/dev/null || true
    fi
    break
  done
}

setup_ssh_askpass() {
  if [ "$AUTH_METHOD" = "password" ] && [ -n "${SSH_PASSWORD:-}" ]; then
    TEMP_ASKPASS_FILE="$(mktemp /tmp/opinstall_askpass_XXXXXX)"
    cat > "$TEMP_ASKPASS_FILE" <<'EOF'
#!/usr/bin/env bash
echo "$SSH_PASSWORD"
EOF
    chmod 700 "$TEMP_ASKPASS_FILE"
    export SSH_ASKPASS="$TEMP_ASKPASS_FILE"
    export SSH_ASKPASS_REQUIRE=force
    export DISPLAY=none
  fi
}

build_ssh_opts() {
  local opts="$SSH_BASE_OPTS -p $HOST_PORT"
  if [ "$AUTH_METHOD" != "password" ]; then
    opts="$opts -i $KEY_FILE"
  fi
  echo "$opts"
}

run_ssh() {
  local ssh_opts="$1"
  shift
  if command -v setsid >/dev/null 2>&1; then
    setsid ssh $ssh_opts "$@" </dev/null
  else
    ssh $ssh_opts "$@"
  fi
}

run_scp() {
  local scp_opts="$1"
  shift
  if command -v setsid >/dev/null 2>&1; then
    setsid scp $scp_opts "$@" </dev/null
  else
    scp $scp_opts "$@" </dev/null
  fi
}

test_connection() {
  while true; do
    msg_line testing_conn
    local ssh_opts
    ssh_opts="$(build_ssh_opts)"
    run_ssh "$ssh_opts" "$USER_NAME@$HOST_IP" "echo connected"
    local rc=$?
    if [ $rc -eq 0 ]; then
      break
    fi
    msg_line conn_failed
    msg_line retry_menu
    read -r choice
    case "$choice" in
      1) prompt_auth_method; setup_ssh_askpass ;;
      2) exit 1 ;;
      *) msg_line invalid_choice ;;
    esac
  done
}

record_result() {
  local file="$1"
  local status="$2"
  local reason="$3"
  RESULT_FILES+=("$file")
  RESULT_STATUS+=("$status")
  RESULT_REASON+=("$reason")
}

process_file() {
  local file="$1"
  local base
  base="$(basename "$file")"
  local ssh_opts scp_opts
  ssh_opts="$(build_ssh_opts)"
  scp_opts="$SSH_BASE_OPTS -P $HOST_PORT -O"
  if [ "$AUTH_METHOD" != "password" ]; then
    scp_opts="$scp_opts -i $KEY_FILE"
  fi

  while true; do
    echo "---- $base ----"
    run_scp "$scp_opts" "$file" "$USER_NAME@$HOST_IP:/tmp/$base"
    local rc=$?
    if [ $rc -ne 0 ]; then
      msg_line upload_failed
      msg_line upload_fail_menu
      read -r choice
      case "$choice" in
        1) continue ;;
        2) record_result "$base" "FAIL" "upload_failed"; return 0 ;;
        3) record_result "$base" "FAIL" "upload_failed"; return 1 ;;
        *) msg_line invalid_choice ;;
      esac
      continue
    fi

    local log_file
    log_file="$(mktemp /tmp/opinstall_log_XXXXXX)"
    echo "apk add --allow-untrusted /tmp/$base ..."
    run_ssh "$ssh_opts" "$USER_NAME@$HOST_IP" "apk add --allow-untrusted /tmp/$base" 2>&1 | tee "$log_file"
    local install_rc=${PIPESTATUS[0]}

    if [ $install_rc -eq 0 ]; then
      msg_line install_success
      record_result "$base" "OK" ""
      rm -f "$log_file"
      return 0
    fi

    msg_line install_failed
    cat "$log_file"

    local has_dep_issue=0
    if grep -Eqi "unable to select packages|unsatisfiable constraints|breaks:|cannot satisfy the following dependencies" "$log_file"; then
      has_dep_issue=1
    fi

    if [ $has_dep_issue -eq 1 ]; then
      msg_line install_fail_menu_dep
    else
      msg_line install_fail_menu
    fi

    read -r choice
    case "$choice" in
      1)
        rm -f "$log_file"
        continue
        ;;
      2)
        record_result "$base" "FAIL" "ignored"
        rm -f "$log_file"
        return 0
        ;;
      3)
        record_result "$base" "FAIL" "failed"
        rm -f "$log_file"
        return 1
        ;;
      4)
        if [ $has_dep_issue -eq 1 ]; then
          msg_line force_installing
          run_ssh "$ssh_opts" "$USER_NAME@$HOST_IP" "apk add --allow-untrusted --force-broken-world /tmp/$base" 2>&1 | tee "$log_file"
          local frc=${PIPESTATUS[0]}
          if [ $frc -eq 0 ]; then
            msg_line install_success
            record_result "$base" "OK" "force"
            rm -f "$log_file"
            return 0
          else
            msg_line install_failed
            cat "$log_file"
            record_result "$base" "FAIL" "force_failed"
            rm -f "$log_file"
            return 1
          fi
        else
          msg_line invalid_choice
        fi
        ;;
      *)
        msg_line invalid_choice
        ;;
    esac
  done
}

print_summary() {
  msg_line summary_title
  local i
  for ((i=0; i<${#RESULT_FILES[@]}; i++)); do
    local f="${RESULT_FILES[$i]}"
    local s="${RESULT_STATUS[$i]}"
    if [ "$s" = "OK" ]; then
      local ok_text
      ok_text="$(msg_line summary_ok)"
      echo "$ok_text $f"
    else
      local fail_text
      fail_text="$(msg_line summary_fail)"
      echo "$fail_text $f"
    fi
  done
  msg_line goodbye
}

main() {
  select_language
  os_check
  prompt_basic_info
  prompt_auth_method
  setup_ssh_askpass
  test_connection

  echo
  msg_line select_file_mode
  msg_line select_file_drag
  msg_line select_file_dialog

  local method
  local -a paths=()

  while true; do
    read -r method
    case "${method:-}" in
      1)
        echo
        msg_line no_files
        echo
        echo "请拖拽一个或多个 .apk 文件到这里，然后按 Enter："
        echo "Drag one or more .apk files here, then press Enter:"
        read -r line
        if [ -z "${line}" ]; then
          echo "未输入任何文件，退出。"
          exit 1
        fi

        set -- $line
        for arg in "$@"; do
          local path="$arg"
          if [[ "$path" == \"*\" && "$path" == *\" ]]; then
            path="${path:1:${#path}-2}"
          elif [[ "$path" == \'*\' && "$path" == *\' ]]; then
            path="${path:1:${#path}-2}"
          fi
          path="${path//\\ / }"
          paths+=("$path")
        done
        break
        ;;
      2)
        if [[ "${OSTYPE:-}" == darwin* ]]; then
          local out
          out="$(osascript <<'APPLESCRIPT'
set theFiles to choose file with prompt "Select .apk files" of type {"apk"} with multiple selections allowed
set outText to ""
repeat with f in theFiles
  set outText to outText & POSIX path of f & "\n"
end repeat
return outText
APPLESCRIPT
)"
          if [ -z "${out}" ]; then
            echo "未选择文件，退出。"
            exit 1
          fi
          while IFS= read -r p; do
            [ -n "$p" ] && paths+=("$p")
          done <<< "$out"
        else
          local out=""
          local used_gui=0

          if command -v zenity >/dev/null 2>&1; then
            used_gui=1
            out="$(zenity --file-selection --multiple --file-filter="*.apk" --separator="|" 2>/dev/null || true)"
          fi

          if [ $used_gui -eq 0 ]; then
            echo "未找到可用的图形文件选择器 (zenity)，尝试自动安装依赖 (zenity/xdg-utils)..."
            install_gui_deps_linux

            if command -v zenity >/dev/null 2>&1; then
              used_gui=1
              out="$(zenity --file-selection --multiple --file-filter="*.apk" --separator="|" 2>/dev/null || true)"
            fi
          fi

          if [ $used_gui -eq 0 ]; then
            echo "仍未找到可用的图形文件选择器 (zenity)。"
            echo "Please install 'zenity' manually, then run this script again."
            echo "按回车键退出 / Press Enter to exit"
            read -r _
            exit 1
          fi

          if [ -z "${out}" ]; then
            echo "未选择文件，退出。"
            exit 1
          fi

          IFS='|' read -r -a tmp_paths <<< "$out"
          for p in "${tmp_paths[@]}"; do
            [ -n "$p" ] && paths+=("$p")
          done
        fi
        break
        ;;
      *)
        msg_line invalid_choice
        ;;
    esac
  done

  if [ "${#paths[@]}" -eq 0 ]; then
    echo "未获得任何文件路径，退出。"
    exit 1
  fi

  local -a invalid_names=()
  local p base
  for p in "${paths[@]}"; do
    base="$(basename "$p")"
    if [[ ! "$base" =~ ^[A-Za-z0-9._-]+$ ]]; then
      invalid_names+=("$base")
    fi
  done

  if [ "${#invalid_names[@]}" -gt 0 ]; then
    msg_line invalid_filename_header
    for n in "${invalid_names[@]}"; do
      echo " - $n"
    done
    msg_line invalid_filename_footer
    exit 1
  fi

  msg_line processing_files

  local all_ok=1
  for p in "${paths[@]}"; do
    if [ ! -f "$p" ]; then
      record_result "$(basename "$p")" "FAIL" "not_found"
      continue
    fi
    process_file "$p" || { all_ok=0; print_summary; exit 1; }
  done

  print_summary
  if [ $all_ok -ne 1 ]; then
    exit 1
  fi
}

trap '
[ -n "${TEMP_KEY_FILE:-}" ] && rm -f "$TEMP_KEY_FILE"
[ -n "${TEMP_ASKPASS_FILE:-}" ] && rm -f "$TEMP_ASKPASS_FILE"
' EXIT

main "$@"
