param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Files
)

$ErrorActionPreference = 'Continue'

$Global:Lang = "en"
$script:PlinkPath = $null
$script:PscpPath  = $null
$script:TempPuttyDir = $null
$Global:SshPasswordPlain = $null
$script:AuthMethod = ''
$script:KeyFile = $null
$script:TempKeyFile = $null
$script:HostName = ''
$script:UserName = 'root'
$script:SshPort  = 22

function Msg {
    param([string]$Key)
    switch ("$Global:Lang`:$Key") {

        'zh_CN:invalid_choice' { '无效选择，请重新输入。'; break }
        'zh_TW:invalid_choice' { '無效選擇，請重新輸入。'; break }
        'en:invalid_choice'    { 'Invalid choice, please try again.'; break }
        'fr:invalid_choice'    { 'Choix invalide, veuillez réessayer.'; break }

        'zh_CN:prompt_user' { '请输入 OpenWrt 用户名（默认 root）：'; break }
        'zh_TW:prompt_user' { '請輸入 OpenWrt 使用者名稱（預設 root）：'; break }
        'en:prompt_user'    { 'Enter OpenWrt username (default root): '; break }
        'fr:prompt_user'    { "Entrez le nom d'utilisateur OpenWrt (par défaut root) : "; break }

        'zh_CN:prompt_ip' { '请输入 OpenWrt IP 或主机名：'; break }
        'zh_TW:prompt_ip' { '請輸入 OpenWrt IP 或主機名稱：'; break }
        'en:prompt_ip'    { 'Enter OpenWrt IP or hostname: '; break }
        'fr:prompt_ip'    { "Entrez l'adresse IP ou le nom d'hôte OpenWrt : "; break }

        'zh_CN:prompt_port' { '请输入 SSH 端口（默认 22）：'; break }
        'zh_TW:prompt_port' { '請輸入 SSH 連接埠（預設 22）：'; break }
        'en:prompt_port'    { 'Enter SSH port (default 22): '; break }
        'fr:prompt_port'    { 'Entrez le port SSH (par défaut 22) : '; break }

        'zh_CN:auth_menu' { '请选择认证方式：1) 密码登录  2) 密钥文件  3) 粘贴私钥'; break }
        'zh_TW:auth_menu' { '請選擇認證方式：1) 密碼登入  2) 金鑰檔案  3) 貼上私鑰'; break }
        'en:auth_menu'    { 'Select auth method: 1) Password  2) Key file  3) Paste private key'; break }
        'fr:auth_menu'    { "Choisissez la méthode d'authentification : 1) Mot de passe  2) Fichier de clé  3) Coller la clé privée"; break }

        'zh_CN:prompt_auth_choice' { '请输入选项 (1/2/3)：'; break }
        'zh_TW:prompt_auth_choice' { '請輸入選項 (1/2/3)：'; break }
        'en:prompt_auth_choice'    { 'Enter choice (1/2/3): '; break }
        'fr:prompt_auth_choice'    { 'Entrez le choix (1/2/3) : '; break }

        'zh_CN:info_password_ssh' { '将使用密码登录，脚本会在本次运行期间临时保存密码。'; break }
        'zh_TW:info_password_ssh' { '將使用密碼登入，腳本會在本次執行期間暫存密碼。'; break }
        'en:info_password_ssh'    { 'Password login selected. Script will temporarily keep the password for this run.'; break }
        'fr:info_password_ssh'    { "Authentification par mot de passe. Le script conservera temporairement le mot de passe pour cette exécution."; break }

        'zh_CN:prompt_password' { '请输入 SSH 密码：'; break }
        'zh_TW:prompt_password' { '請輸入 SSH 密碼：'; break }
        'en:prompt_password'    { 'Enter SSH password: '; break }
        'fr:prompt_password'    { 'Entrez le mot de passe SSH : '; break }

        'zh_CN:prompt_key_path' { '请选择一个私钥文件，然后点击“打开”：'; break }
        'zh_TW:prompt_key_path' { '請從檔案對話框選擇一個私鑰檔案，然後按「開啟」：'; break }
        'en:prompt_key_path'    { 'Please choose a private key file from the dialog, then click "Open".'; break }
        'fr:prompt_key_path'    { 'Veuillez choisir un fichier de clé privée dans la boîte de dialogue, puis cliquez sur "Ouvrir".'; break }

        'zh_CN:prompt_paste_key' { '请粘贴你的私钥内容（以 -----END 开头的一行结束），每粘贴一行按一次回车，最后那行输入后再按回车结束：'; break }
        'zh_TW:prompt_paste_key' { '請貼上你的私鑰內容（以 -----END 開頭的一行結束），每貼上一行按一次 Enter，最後一行輸入後再按 Enter 結束：'; break }
        'en:prompt_paste_key'    { 'Paste your private key content (end with a line starting with -----END). Press Enter after each line; after the final line press Enter again to finish:'; break }
        'fr:prompt_paste_key'    { 'Collez le contenu de votre clé privée (terminez par une ligne commençant par -----END). Appuyez sur Entrée après chaque ligne, puis encore une fois après la dernière ligne pour terminer :'; break }

        'zh_CN:testing_conn' { '正在测试 SSH 连接，请稍候……'; break }
        'zh_TW:testing_conn' { '正在測試 SSH 連線，請稍候……'; break }
        'en:testing_conn'    { 'Testing SSH connection, please wait...'; break }
        'fr:testing_conn'    { 'Test de la connexion SSH, veuillez patienter...'; break }

        'zh_CN:hostkey_hint' { '如果看到 ''Access granted. Press Return to begin session.'', 请按回车键继续。'; break }
        'zh_TW:hostkey_hint' { '如果看到 ''Access granted. Press Return to begin session.'', 請按 Enter 鍵繼續。'; break }
        'en:hostkey_hint'    { 'If you see ''Access granted. Press Return to begin session.'', please press Enter to continue.'; break }
        'fr:hostkey_hint'    { "Si vous voyez ''Access granted. Press Return to begin session.'', appuyez sur Entrée pour continuer."; break }

        'zh_CN:conn_failed' { 'SSH 连接失败，请检查 IP/端口/用户名/认证方式/密码。'; break }
        'zh_TW:conn_failed' { 'SSH 連線失敗，請檢查 IP/連接埠/使用者/認證方式/密碼。'; break }
        'en:conn_failed'    { 'SSH connection failed. Please check IP/port/username/auth method/password.'; break }
        'fr:conn_failed'    { "La connexion SSH a échoué. Vérifiez l'IP/le port/le nom d'utilisateur/la méthode d'authentification/le mot de passe."; break }

        'zh_CN:retry_menu' { '1) 重新尝试  2) 退出'; break }
        'zh_TW:retry_menu' { '1) 重新嘗試  2) 退出'; break }
        'en:retry_menu'    { '1) Retry  2) Exit'; break }
        'fr:retry_menu'    { '1) Réessayer  2) Quitter'; break }

        'zh_CN:processing_files' { '开始处理 .ipk 文件（逐个上传并安装）……'; break }
        'zh_TW:processing_files' { '開始處理 .ipk 檔案（逐一上傳並安裝）……'; break }
        'en:processing_files'    { 'Starting to process .ipk files (upload & install one by one)...'; break }
        'fr:processing_files'    { 'Traitement des fichiers .ipk (téléversement et installation un par un)...'; break }

        'zh_CN:upload_failed' { '上传失败。'; break }
        'zh_TW:upload_failed' { '上傳失敗。'; break }
        'en:upload_failed'    { 'Upload failed.'; break }
        'fr:upload_failed'    { 'Échec du téléversement.'; break }

        'zh_CN:upload_fail_menu' { '请选择：1) 重试  2) 忽略并处理下一个  3) 退出'; break }
        'zh_TW:upload_fail_menu' { '請選擇：1) 重試  2) 忽略並處理下一個  3) 退出'; break }
        'en:upload_fail_menu'    { 'Choose: 1) Retry  2) Ignore & next  3) Exit'; break }
        'fr:upload_fail_menu'    { 'Choisissez : 1) Réessayer  2) Ignorer & suivant  3) Quitter'; break }

        'zh_CN:install_failed' { '安装失败，错误信息如下（来自 opkg）：'; break }
        'zh_TW:install_failed' { '安裝失敗，錯誤訊息如下（來自 opkg）：'; break }
        'en:install_failed'    { 'Install failed, error output from opkg:'; break }
        'fr:install_failed'    { "Échec de l'installation, sortie d'erreur d'opkg :"; break }

        'zh_CN:install_fail_menu_dep' { '请选择：1) 重试  2) 忽略  3) 退出  4) 强制安装（忽略依赖）'; break }
        'zh_TW:install_fail_menu_dep' { '請選擇：1) 重試  2) 忽略  3) 退出  4) 強制安裝（忽略依賴）'; break }
        'en:install_fail_menu_dep'    { 'Choose: 1) Retry  2) Ignore  3) Exit  4) Force install (ignore deps)'; break }
        'fr:install_fail_menu_dep'    { "Choisissez : 1) Réessayer  2) Ignorer  3) Quitter  4) Forcer l'installation (ignorer les dépendances)"; break }

        'zh_CN:install_fail_menu' { '请选择：1) 重试  2) 忽略  3) 退出'; break }
        'zh_TW:install_fail_menu' { '請選擇：1) 重試  2) 忽略  3) 退出'; break }
        'en:install_fail_menu'    { 'Choose: 1) Retry  2) Ignore  3) Exit'; break }
        'fr:install_fail_menu'    { 'Choisissez : 1) Réessayer  2) Ignorer  3) Quitter'; break }

        'zh_CN:force_installing' { '正在尝试强制安装（--force-depends）……'; break }
        'zh_TW:force_installing' { '正在嘗試強制安裝（--force-depends）……'; break }
        'en:force_installing'    { 'Trying force install (--force-depends)...'; break }
        'fr:force_installing'    { "Tentative d'installation forcée (--force-depends)..."; break }

        'zh_CN:install_success' { '安装成功。'; break }
        'zh_TW:install_success' { '安裝成功。'; break }
        'en:install_success'    { 'Install succeeded.'; break }
        'fr:install_success'    { 'Installation réussie.'; break }

        'zh_CN:summary_title' { '=== 安装结果汇总 ==='; break }
        'zh_TW:summary_title' { '=== 安裝結果總結 ==='; break }
        'en:summary_title'    { '=== Installation summary ==='; break }
        'fr:summary_title'    { "=== Récapitulatif d'installation ==="; break }

        'zh_CN:summary_ok' { '[成功]'; break }
        'zh_TW:summary_ok' { '[成功]'; break }
        'en:summary_ok'    { '[OK]'; break }
        'fr:summary_ok'    { '[OK]'; break }

        'zh_CN:summary_fail' { '[失败]'; break }
        'zh_TW:summary_fail' { '[失敗]'; break }
        'en:summary_fail'    { '[FAILED]'; break }
        'fr:summary_fail'    { '[ÉCHEC]'; break }

        'zh_CN:goodbye' { '任务结束，脚本退出。'; break }
        'zh_TW:goodbye' { '任務結束，腳本退出。'; break }
        'en:goodbye'    { 'All done. Exiting.'; break }
        'fr:goodbye'    { 'Terminé. Sortie du script.'; break }

        'zh_CN:filename_invalid_header' { '以下文件名不符合要求：仅允许英文字母、数字、点(.)、下划线(_) 和连字符(-)：'; break }
        'zh_TW:filename_invalid_header' { '以下檔案名稱不符合要求：僅允許英文字母、數字、點(.)、底線(_) 和連字號(-)：'; break }
        'en:filename_invalid_header'    { 'The following file names are invalid. Only letters, digits, dot (.), underscore (_) and hyphen (-) are allowed:'; break }
        'fr:filename_invalid_header'    { 'Les noms de fichiers suivants sont invalides. Seuls les lettres, chiffres, point (.), underscore (_) et tiret (-) sont autorisés :'; break }

        'zh_CN:filename_invalid_hint' { '请重命名上述文件后再重新运行脚本。'; break }
        'zh_TW:filename_invalid_hint' { '請重新命名上述檔案後，再重新執行腳本。'; break }
        'en:filename_invalid_hint'    { 'Please rename the above files and run this script again.'; break }
        'fr:filename_invalid_hint'    { 'Veuillez renommer les fichiers ci-dessus, puis relancer ce script.'; break }

        default { '' }
    }
}

function Select-Language {
    while ($true) {
        Write-Host 'Hello'
        Write-Host '1) 简体中文  2) 繁體中文  3) English  4) Français'
        $choice = Read-Host
        switch ($choice) {
            '1' { $Global:Lang = 'zh_CN'; return }
            '2' { $Global:Lang = 'zh_TW'; return }
            '3' { $Global:Lang = 'en';    return }
            '4' { $Global:Lang = 'fr';    return }
            default {
                Write-Host 'Error'
            }
        }
    }
}

function Test-WindowsVersion {
    try {
        $cv = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    } catch {
        switch ($Global:Lang) {
            'zh_CN' { Write-Host "无法读取系统版本信息，脚本仅支持 Windows 10 / 11。" }
            'zh_TW' { Write-Host "無法讀取系統版本資訊，腳本僅支援 Windows 10 / 11。" }
            'fr'    { Write-Host "Impossible de lire les informations de version du système. Le script ne prend en charge que Windows 10 / 11." }
            default { Write-Host "Cannot read Windows version info. This script only supports Windows 10 / 11." }
        }
        Read-Host "按回车键退出 / Press Enter to exit"
        exit 1
    }

    $build   = [int]$cv.CurrentBuildNumber
    $product = $cv.ProductName
    $disp    = $cv.DisplayVersion
    $ubr     = $cv.UBR

    switch ($Global:Lang) {
        'zh_CN' {
            Write-Host "检测到系统：$product $disp (内部版本 $build.$ubr)"
        }
        'zh_TW' {
            Write-Host "偵測到系統：$product $disp (內部版本 $build.$ubr)"
        }
        'fr' {
            Write-Host "Système détecté : $product $disp (build interne $build.$ubr)"
        }
        default {
            Write-Host "Detected system: $product $disp (build $build.$ubr)"
        }
    }

    $ok = $false

    if ($build -ge 19044 -and $build -lt 22000) {
        $ok = $true
    }

    elseif ($build -ge 22631) {
        $ok = $true
    }

    if (-not $ok) {
        switch ($Global:Lang) {
            'zh_CN' {
                Write-Host ""
                Write-Host "当前系统版本过低。最低要求："
                Write-Host "  - Windows 10 21H2 及以上（内部版本 >= 19044）"
                Write-Host "  - 或 Windows 11 23H2 及以上（内部版本 >= 22631）"
            }
            'zh_TW' {
                Write-Host ""
                Write-Host "目前系統版本過低。最低需求："
                Write-Host "  - Windows 10 21H2 以上（內部版本 >= 19044）"
                Write-Host "  - 或 Windows 11 23H2 以上（內部版本 >= 22631）"
            }
            'fr' {
                Write-Host ""
                Write-Host "Votre version de Windows est trop ancienne. Versions minimales requises :"
                Write-Host "  - Windows 10 21H2 ou supérieur (build interne >= 19044)"
                Write-Host "  - ou Windows 11 23H2 ou supérieur (build interne >= 22631)"
            }
            default {
                Write-Host ""
                Write-Host "Your Windows version is too old. Minimum requirements:"
                Write-Host "  - Windows 10 21H2 or later (build >= 19044)"
                Write-Host "  - or Windows 11 23H2 or later (build >= 22631)"
            }
        }
        Read-Host "按回车键退出 / Press Enter to exit"
        exit 1
    }
}

function Ensure-PuTTY {
    $plinkCmd = Get-Command plink -ErrorAction SilentlyContinue
    $pscpCmd  = Get-Command pscp  -ErrorAction SilentlyContinue

    if ($plinkCmd -and $pscpCmd) {
        $script:PlinkPath = $plinkCmd.Source
        $script:PscpPath  = $pscpCmd.Source
        return
    }

    Write-Host "PuTTY (plink/pscp) not found in PATH, downloading temporary copies..."

    $tmpDir = Join-Path ([IO.Path]::GetTempPath()) "op_ipk_install_putty"
    $script:TempPuttyDir = $tmpDir
    if (-not (Test-Path $tmpDir)) {
        New-Item -ItemType Directory -Path $tmpDir | Out-Null
    }

    $arch = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture
    if ($arch -eq [System.Runtime.InteropServices.Architecture]::Arm64) {
        $plinkUrl = "https://the.earth.li/~sgtatham/putty/latest/wa64/plink.exe"
        $pscpUrl  = "https://the.earth.li/~sgtatham/putty/latest/wa64/pscp.exe"
    }
    elseif ($arch -eq [System.Runtime.InteropServices.Architecture]::X86) {
        $plinkUrl = "https://the.earth.li/~sgtatham/putty/latest/w32/plink.exe"
        $pscpUrl  = "https://the.earth.li/~sgtatham/putty/latest/w32/pscp.exe"
    }
    else {
        $plinkUrl = "https://the.earth.li/~sgtatham/putty/latest/w64/plink.exe"
        $pscpUrl  = "https://the.earth.li/~sgtatham/putty/latest/w64/pscp.exe"
    }

    $script:PlinkPath = Join-Path $tmpDir "plink.exe"
    $script:PscpPath  = Join-Path $tmpDir "pscp.exe"

    Invoke-WebRequest -Uri $plinkUrl -OutFile $script:PlinkPath -UseBasicParsing
    Invoke-WebRequest -Uri $pscpUrl  -OutFile $script:PscpPath  -UseBasicParsing
}

function Get-PlinkArgs {
    param([switch]$ForTest)

    $args = @('-ssh', '-P', "$script:SshPort")
    if (-not $ForTest) {
        $args += '-batch'
    }

    if ($script:AuthMethod -ne 'password' -and $script:KeyFile) {
        $args += @('-i', $script:KeyFile)
    }

    if ($script:AuthMethod -eq 'password' -and $Global:SshPasswordPlain) {
        $args += @('-pw', $Global:SshPasswordPlain)
    }
    return $args
}

function Get-PscpArgs {
    param([string]$Port)
    $args = @('-batch', '-scp', '-P', "$Port")

    if ($script:AuthMethod -ne 'password' -and $script:KeyFile) {
        $args += @('-i', $script:KeyFile)
    }

    if ($script:AuthMethod -eq 'password' -and $Global:SshPasswordPlain) {
        $args += @('-pw', $Global:SshPasswordPlain)
    }
    return $args
}

function Prompt-AuthMethod {
    while ($true) {
        Write-Host (Msg 'auth_menu')
        $choice = Read-Host -Prompt (Msg 'prompt_auth_choice')
        switch ($choice) {
            '1' {
                $script:AuthMethod = 'password'
                Write-Host (Msg 'info_password_ssh')
                $sec = Read-Host -Prompt (Msg 'prompt_password') -AsSecureString
                $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec)
                $Global:SshPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringUni($bstr)
                [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
                return
            }
            '2' {
                $script:AuthMethod = 'keyfile'

                Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue | Out-Null
                Write-Host (Msg 'prompt_key_path')
                $ofdKey = New-Object System.Windows.Forms.OpenFileDialog
                $ofdKey.Multiselect = $false
                $ofdKey.Filter = "Private key files (*.ppk;*.key;*.*)|*.ppk;*.key;*.*"
                if ($ofdKey.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK -or -not $ofdKey.FileName) {
                    Write-Host "已取消选择私钥。"
                    continue
                }
                $kf = $ofdKey.FileName
                if (-not (Test-Path $kf)) {
                    Write-Host "Key file not found: $kf"
                    continue
                }
                $script:KeyFile = $kf
                return
            }
            '3' {
                $script:AuthMethod = 'pastekey'
                Write-Host (Msg 'prompt_paste_key')
                $tmp = [System.IO.Path]::GetTempFileName()
                $script:TempKeyFile = $tmp
                $writer = [System.IO.StreamWriter]::new($tmp, $false)
                while ($true) {
                    $line = Read-Host
                    $writer.WriteLine($line)
                    if ($line -like '-----END*') { break }
                }
                $writer.Dispose()
                $script:KeyFile = $tmp
                return
            }
            default { Write-Host (Msg 'invalid_choice') }
        }
    }
}

$Results = @()
function Record-Result {
    param(
        [string]$FileName,
        [string]$Status,
        [string]$Reason
    )
    $Results += [pscustomobject]@{
        File   = $FileName
        Status = $Status
        Reason = $Reason
    }
}

function Test-FileNamesSafe {
    param(
        [string[]]$Paths
    )

    $invalid = @()
    foreach ($p in $Paths) {
        $name = [IO.Path]::GetFileName($p)
        if (-not $name) { continue }
        if ($name -notmatch '^[A-Za-z0-9._-]+$') {
            $invalid += $name
        }
    }

    if ($invalid.Count -gt 0) {
        Write-Host (Msg 'filename_invalid_header')
        foreach ($n in $invalid) {
            Write-Host "  - $n"
        }
        Write-Host (Msg 'filename_invalid_hint')
        Read-Host "按回车键退出 / Press Enter to exit"
        exit 1
    }
}

function Process-File {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        Record-Result ([IO.Path]::GetFileName($Path)) 'FAIL' 'not_found'
        return $false
    }

    $base = [IO.Path]::GetFileName($Path)
    Write-Host "---- $base ----"

    while ($true) {
        $pscpArgs = Get-PscpArgs -Port $script:SshPort
        $remote   = "$($script:UserName)@$($script:HostName):/tmp/$base"

        $safeArgs = @()
        for ($i = 0; $i -lt $pscpArgs.Count; $i++) {
            if ($pscpArgs[$i] -eq '-pw' -and $i -lt $pscpArgs.Count - 1) {
                $safeArgs += '-pw'
                $safeArgs += '********'
                $i++
            } else {
                $safeArgs += $pscpArgs[$i]
            }
        }
        $displayCmd = "`"$script:PscpPath`" " + (
            $safeArgs + @($Path, $remote) |
            ForEach-Object { '"{0}"' -f $_ }
        ) -join ' '
        Write-Host "上传命令：$displayCmd"

        & $script:PscpPath @pscpArgs "$Path" "$remote"
        $rc = $LASTEXITCODE
        if ($rc -ne 0) {
            Write-Host (Msg 'upload_failed')
            Write-Host "pscp 返回码：$rc"
            Write-Host (Msg 'upload_fail_menu')
            $ans = Read-Host
            switch ($ans) {
                '1' { continue }
                '2' { Record-Result $base 'FAIL' "upload_failed($rc)"; return $true }
                '3' { Record-Result $base 'FAIL' "upload_failed($rc)"; return $false }
                default { Write-Host (Msg 'invalid_choice') }
            }
        } else {
            break
        }
    }

    while ($true) {
        Write-Host "opkg install /tmp/$base ..."
        $plinkArgs = Get-PlinkArgs
        $fullCmd = $plinkArgs + @("$($script:UserName)@$($script:HostName)", "opkg install /tmp/$base")

        $outputLines = @()
        & $script:PlinkPath @fullCmd 2>&1 | ForEach-Object {
            $outputLines += $_
            Write-Host $_
        }

        $rc = $LASTEXITCODE
        Write-Host "plink 返回码：$rc"

        if ($rc -eq 0) {
            Write-Host (Msg 'install_success')
            Record-Result $base 'OK' ''
            return $true
        }

        Write-Host (Msg 'install_failed')

        $hasDepIssue = ($outputLines -match 'cannot satisfy the following dependencies')

        if ($hasDepIssue) {
            Write-Host (Msg 'install_fail_menu_dep')
        } else {
            Write-Host (Msg 'install_fail_menu')
        }

        $choice = Read-Host
        switch ($choice) {
            '1' { continue }
            '2' { Record-Result $base 'FAIL' "ignored($rc)"; return $true }
            '3' { Record-Result $base 'FAIL' "failed($rc)"; return $false }
            '4' {
                if ($hasDepIssue) {
                    Write-Host (Msg 'force_installing')
                    $forceCmd = $plinkArgs + @("$($script:UserName)@$($script:HostName)", "opkg install --force-depends /tmp/$base")
                    $output2 = @()
                    & $script:PlinkPath @forceCmd 2>&1 | ForEach-Object {
                        $output2 += $_
                        Write-Host $_
                    }
                    $rc2 = $LASTEXITCODE
                    Write-Host "plink(force) 返回码：$rc2"
                    if ($rc2 -eq 0) {
                        Write-Host (Msg 'install_success')
                        Record-Result $base 'OK' 'force'
                        return $true
                    } else {
                        Write-Host (Msg 'install_failed')
                        Record-Result $base 'FAIL' "force_failed($rc2)"
                        return $false
                    }
                } else {
                    Write-Host (Msg 'invalid_choice')
                }
            }
            default { Write-Host (Msg 'invalid_choice') }
        }
    }
}

Select-Language
Test-WindowsVersion
Ensure-PuTTY

$u = Read-Host -Prompt (Msg 'prompt_user')
if ([string]::IsNullOrWhiteSpace($u)) { $u = 'root' }
$script:UserName = $u

while ([string]::IsNullOrWhiteSpace($script:HostName)) {
    $script:HostName = Read-Host -Prompt (Msg 'prompt_ip')
}

$portInput = Read-Host -Prompt (Msg 'prompt_port')
if ([string]::IsNullOrWhiteSpace($portInput)) {
    $script:SshPort = 22
} else {
    $script:SshPort = [int]$portInput
}

Prompt-AuthMethod

while ($true) {
    Write-Host (Msg 'testing_conn')
    Write-Host (Msg 'hostkey_hint')
    $plinkArgs = Get-PlinkArgs -ForTest
    & $script:PlinkPath @plinkArgs "$($script:UserName)@$($script:HostName)" "echo connected"
    $rc = $LASTEXITCODE
    if ($rc -eq 0) { break }
    Write-Host (Msg 'conn_failed')
    Write-Host (Msg 'retry_menu')
    $choice = Read-Host
    switch ($choice) {
        '1' { Prompt-AuthMethod }
        '2' { Read-Host "按回车键退出 / Press Enter to exit"; exit 1 }
        default { Write-Host (Msg 'invalid_choice') }
    }
}

Add-Type -AssemblyName System.Windows.Forms | Out-Null
Write-Host "请在打开的文件对话框中选择一个或多个 .ipk 文件。"
$ofd = New-Object System.Windows.Forms.OpenFileDialog
$ofd.Multiselect = $true
$ofd.Filter = "ipk files (*.ipk)|*.ipk|All files (*.*)|*.*"

if ($ofd.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK -or -not $ofd.FileNames) {
    Write-Host "未选择文件，退出。"
    Read-Host "按回车键退出 / Press Enter to exit"
    exit 1
}

$Files = $ofd.FileNames

Test-FileNamesSafe -Paths $Files

Write-Host (Msg 'processing_files')

$allOk = $true
foreach ($f in $Files) {
    $ok = Process-File -Path $f
    if (-not $ok) {
        $allOk = $false
        break
    }
}

Write-Host (Msg 'summary_title')
foreach ($r in $Results) {
    if ($r.Status -eq 'OK') {
        Write-Host "$(Msg 'summary_ok') $($r.File) ($($r.Reason))"
    } else {
        Write-Host "$(Msg 'summary_fail') $($r.File) ($($r.Reason))"
    }
}

Write-Host (Msg 'goodbye')

if ($script:TempKeyFile -and (Test-Path $script:TempKeyFile)) {
    Remove-Item $script:TempKeyFile -ErrorAction SilentlyContinue
}

if ($script:TempPuttyDir -and (Test-Path $script:TempPuttyDir)) {
    Remove-Item $script:TempPuttyDir -Recurse -Force -ErrorAction SilentlyContinue
}

$Global:SshPasswordPlain = $null

Read-Host "按回车键退出 / Press Enter to exit"

if (-not $allOk) { exit 1 } else { exit 0 }
