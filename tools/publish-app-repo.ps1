# Xuất app Flutter (src/app) thành repo nộp bài: project Flutter nằm ngay thư mục gốc, giữ lịch sử commit của app.
# Chạy từ thư mục gốc repo:
#   powershell -ExecutionPolicy Bypass -File tools\publish-app-repo.ps1 -DryRun   # chỉ xuất ra dist\hoclaixe-app để xem
#   powershell -ExecutionPolicy Bypass -File tools\publish-app-repo.ps1           # đẩy lên repo nộp bài
param(
  [string]$Remote = 'https://github.com/takidang/hoclaixe-app.git',
  [string]$Branch = 'main',
  [switch]$DryRun
)
# native git writes progress to stderr: check $LASTEXITCODE instead of stopping on stderr
$ErrorActionPreference = 'Continue'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$repo = Split-Path -Parent $PSScriptRoot
Set-Location $repo
$tmp = 'app-export-tmp'

$dirty = git status --porcelain -- src/app
if ($dirty) {
  Write-Host 'Cảnh báo: src/app có thay đổi CHƯA COMMIT — repo nộp bài chỉ lấy phần đã commit:' -ForegroundColor Yellow
  $dirty | ForEach-Object { Write-Host "  $_" }
}

Write-Host 'Tách lịch sử của src/app (git subtree split)...' -ForegroundColor Cyan
if (git branch --list $tmp) { git branch -D $tmp 2>&1 | Out-Null }
git subtree split --prefix=src/app -b $tmp 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'git subtree split thất bại' }
$head = git log -1 --format='%h %s' $tmp
$count = git rev-list --count $tmp
Write-Host "  $count commit, mới nhất: $head"

try {
  if ($DryRun) {
    $out = Join-Path $repo 'dist\hoclaixe-app'
    if (Test-Path $out) { Remove-Item -Recurse -Force $out }
    git clone -q --branch $tmp $repo $out 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'git clone thất bại' }
    git -C $out branch -m $tmp $Branch
    git -C $out remote remove origin
    Write-Host "Bản xem trước: $out" -ForegroundColor Green
    Write-Host '  (mở bằng Android Studio/VS Code, hoặc: cd dist\hoclaixe-app; flutter pub get; flutter test)'
  } else {
    Write-Host "Đẩy lên $Remote (nhánh $Branch)..." -ForegroundColor Cyan
    git push $Remote "${tmp}:refs/heads/$Branch" 2>&1 | ForEach-Object { Write-Host "  $_" }
    if ($LASTEXITCODE -ne 0) {
      throw 'Push thất bại (mạng, quyền, hoặc repo nộp bài có commit không lấy từ đây). Không dùng --force; hỏi trưởng nhóm.'
    }
    Write-Host "Xong: $($Remote -replace '\.git$','')" -ForegroundColor Green
  }
} finally {
  if (git branch --list $tmp) { git branch -D $tmp 2>&1 | Out-Null }
}
