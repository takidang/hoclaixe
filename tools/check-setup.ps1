# Kiểm tra máy đã sẵn sàng chạy app hoclaixe chưa (Windows).
# Chạy từ thư mục gốc repo:  powershell -ExecutionPolicy Bypass -File tools\check-setup.ps1
$ErrorActionPreference = 'Continue'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$RequiredFlutter = [version]'3.47.0'
$repo = Split-Path -Parent $PSScriptRoot
$app = Join-Path $repo 'src\app'
$problems = 0

function Ok($msg)   { Write-Host "  [OK]  $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "  [!!]  $msg" -ForegroundColor Yellow }
function Bad($msg, $fix) {
  Write-Host "  [X]   $msg" -ForegroundColor Red
  Write-Host "        -> $fix"
  $script:problems++
}

Write-Host "`n== 1. Công cụ ==" -ForegroundColor Cyan
if (Get-Command git -ErrorAction SilentlyContinue) { Ok "Git: $((git --version) -replace 'git version ','')" }
else { Bad 'Chưa có Git' 'Cài Git for Windows: https://git-scm.com/download/win rồi mở lại terminal' }

$flutter = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutter) {
  Bad 'Không tìm thấy lệnh flutter (chưa cài hoặc chưa thêm vào PATH)' 'Xem CONTRIBUTING.md mục 2a, bước 1. Cài xong phải ĐÓNG HẾT terminal/VS Code rồi mở lại'
} else {
  $sdk = Split-Path -Parent (Split-Path -Parent $flutter.Source)
  try {
    $info = flutter --version --machine 2>$null | ConvertFrom-Json
    $v = [version]($info.frameworkVersion -replace '[^0-9.].*$','')
    if ($v -ge $RequiredFlutter) { Ok "Flutter $($info.frameworkVersion) tại $sdk" }
    else { Bad "Flutter $($info.frameworkVersion) quá cũ (cần >= $RequiredFlutter)" 'Chạy: flutter upgrade' }
  } catch { Warn "Không đọc được phiên bản Flutter: $_" }
  if ($sdk -match ' ') { Warn "Đường dẫn Flutter có dấu cách ($sdk) — một số lệnh có thể lỗi; nên cài lại vào C:\src\flutter" }
}

Write-Host "`n== 2. Repo ==" -ForegroundColor Cyan
$need = @(
  @('src\app\pubspec.yaml', 'Clone chưa xong. Clone lại: git clone -c core.longpaths=true https://github.com/takidang/hoclaixe.git'),
  @('src\app\android\gradlew.bat', 'Thiếu Gradle wrapper — chạy: git pull'),
  @('src\app\android\gradle\wrapper\gradle-wrapper.jar', 'Thiếu Gradle wrapper — chạy: git pull'),
  @('src\app\web\sqlite3.wasm', 'Thiếu file chạy SQLite trên web — chạy: git pull')
)
foreach ($n in $need) {
  if (Test-Path (Join-Path $repo $n[0])) { Ok $n[0] } else { Bad "Thiếu $($n[0])" $n[1] }
}
if ((git -C $repo config core.longpaths) -ne 'true') {
  Warn 'Chưa bật core.longpaths — nếu gặp "Filename too long", chạy: git config core.longpaths true'
}
if ($repo -match ' ') { Warn "Thư mục repo có dấu cách ($repo) — nên để ở đường dẫn không dấu cách, không dấu tiếng Việt" }

if ($flutter -and (Test-Path (Join-Path $app 'pubspec.yaml'))) {
  Write-Host "`n== 3. Thiết bị chạy app ==" -ForegroundColor Cyan
  Push-Location $app
  try {
    $devices = flutter devices --machine 2>$null | ConvertFrom-Json
  } catch { $devices = @() }
  Pop-Location
  $android = @($devices | Where-Object { $_.targetPlatform -like 'android*' })
  $web = @($devices | Where-Object { $_.targetPlatform -eq 'web-javascript' })
  if ($android.Count -gt 0) { foreach ($d in $android) { Ok "Android: $($d.name)  (chạy: flutter run -d $($d.id))" } }
  else { Warn 'Chưa thấy máy Android — mở emulator trong Android Studio (Device Manager > Play) hoặc cắm điện thoại bật Gỡ lỗi USB' }
  if ($web.Count -gt 0) { foreach ($d in $web) { Ok "Web: $($d.name)  (chạy: flutter run -d $($d.id) --web-port 8080)" } }
  else { Warn 'Chưa thấy Chrome/Edge cho bản web' }
  if ($android.Count -eq 0 -and $web.Count -eq 0) { Bad 'Không có thiết bị nào để chạy app' 'Mở emulator Android, hoặc cài Chrome' }
}

Write-Host ''
if ($problems -eq 0) {
  Write-Host 'Máy đã sẵn sàng. Chạy:' -ForegroundColor Green
  Write-Host '  cd src\app'
  Write-Host '  flutter pub get'
  Write-Host '  flutter run                                  (Android)'
  Write-Host '  flutter run -d chrome --web-port 8080        (web; giữ cổng 8080 để không mất tiến độ)'
} else {
  Write-Host "Còn $problems vấn đề cần sửa (dòng [X] ở trên). Sửa xong chạy lại script này." -ForegroundColor Red
}
