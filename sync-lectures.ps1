# 讲义仓库自动同步：有改动就提交并推到 GitHub（远程是私有仓库 RyanXu123/c-lectures）
#
# 跟 cpp-demo 里那个 sync.ps1 一套路子：自己找 git、直连失败自动走本地代理、每一步写日志。

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$logDir = Join-Path $PSScriptRoot "_later"      # 日志丢这儿：_later 不在仓库白名单里，不会跟着上传
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
$logFile = Join-Path $logDir "sync-lectures.log"
function Write-Log([string]$text) {
    $line = (Get-Date -Format "yyyy-MM-dd HH:mm:ss") + "  " + $text
    Write-Host $line
    Add-Content -Path $logFile -Value $line -Encoding UTF8
}

$git = (Get-Command git -ErrorAction SilentlyContinue).Source
if (-not $git) {
    $cands = @(
        (Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\native\git\cmd\git.exe"),
        "C:\Program Files\Git\cmd\git.exe",
        "C:\Program Files (x86)\Git\cmd\git.exe"
    )
    foreach ($c in $cands) { if (Test-Path $c) { $git = $c; break } }
}
if (-not $git) { Write-Log "找不到 git，先装 Git for Windows 或者把 git.exe 加进 PATH。"; exit 1 }

try {
    if (-not (& $git status --porcelain)) {
        Write-Log "没有改动，跳过。"
        exit 0
    }

    & $git add -A
    if ($LASTEXITCODE -ne 0) { Write-Log ("git add 失败，退出码 " + $LASTEXITCODE); exit 1 }

    $message = "日常同步 " + (Get-Date -Format "yyyy-MM-dd HH:mm")
    & $git commit -q -m $message
    if ($LASTEXITCODE -ne 0) { Write-Log ("git commit 失败，退出码 " + $LASTEXITCODE); exit 1 }

    & $git push
    if ($LASTEXITCODE -ne 0) {
        Write-Log ("直连推送失败，退出码 " + $LASTEXITCODE + "；改走本地代理 127.0.0.1:7897 再试一次")
        & $git -c http.proxy=http://127.0.0.1:7897 -c http.version=HTTP/1.1 push
        if ($LASTEXITCODE -ne 0) { Write-Log ("走代理也没推上去，退出码 " + $LASTEXITCODE); exit 1 }
    }
    Write-Log ("已推送：" + $message)
}
catch {
    Write-Log ("出错了：" + $_.Exception.Message)
    exit 1
}
