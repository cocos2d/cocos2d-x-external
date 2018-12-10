Set-PSDebug -Trace 1
$python = "C:\\Python27\\python.exe"

& choco install ninja
if ($lastexitcode -ne 0) {throw}
& ninja --version
if ($lastexitcode -ne 0) {throw}

if ($env:build_type -like "android_lib") {
    & $python -u .\tools\appveyor-scripts\setup_android.py --ndk_only
    if ($lastexitcode -ne 0) {throw}
}

if ($env:build_type -like "android_game12") {
    & $python -u .\tools\appveyor-scripts\setup_android.py
    if ($lastexitcode -ne 0) {throw}
}
