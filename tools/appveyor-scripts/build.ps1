Set-PSDebug -Trace 1

$env:ANDROID_NDK_HOME=$env:APPVEYOR_BUILD_FOLDER + "\..\android-ndk-r17b"
$env:NDK_ROOT=$env:APPVEYOR_BUILD_FOLDER + "\..\android-ndk-r17b"
$env:ANDROID_NDK_ROOT=$env:APPVEYOR_BUILD_FOLDER + "\..\android-ndk-r17b"

$env:ANDROID_SDK_ROOT=$env:APPVEYOR_BUILD_FOLDER + "\..\android-sdk"
$env:ANDROID_HOME=$env:APPVEYOR_BUILD_FOLDER + "\..\android-sdk"


Write-Host "PATH"
Write-Host "$env:PATH"

If ($env:build_type -eq "android_lib") {
    & mkdir $env:APPVEYOR_BUILD_FOLDER\build
    # if ($lastexitcode -ne 0) {throw}
    Push-Location $env:APPVEYOR_BUILD_FOLDER\build
    & cmake .. -DCMAKE_TOOLCHAIN_FILE="$env:APPVEYOR_BUILD_FOLDER\tools\android_armeabi_v7a_toolchain.cmake" -G Ninja
    if ($lastexitcode -ne 0) {throw}
    & cmake --build .
    if ($lastexitcode -ne 0) {throw}
    Pop-Location
} elseif ($env:build_type -eq "android_game12") {
    Push-Location $env:APPVEYOR_BUILD_FOLDER\tests\game1\android
    & ./gradlew assembleDebug
    if ($lastexitcode -ne 0) {throw}

    & 7z a release1.7z $env:APPVEYOR_BUILD_FOLDER\tests\game1\android\app\build\outputs\
    if ($lastexitcode -ne 0) {throw}
    Push-AppveyorArtifact release1.7z

    Push-Location $env:APPVEYOR_BUILD_FOLDER\tests\game2\android
    & ./gradlew assembleDebug
    if ($lastexitcode -ne 0) {throw}

    & 7z a release2.7z $env:APPVEYOR_BUILD_FOLDER\tests\game2\android\app\build\outputs\
    if ($lastexitcode -ne 0) {throw}
    Push-AppveyorArtifact release2.7z

} Else {
    & mkdir $env:APPVEYOR_BUILD_FOLDER\build
    # if ($lastexitcode -ne 0) {throw}
    Push-Location $env:APPVEYOR_BUILD_FOLDER\build
    & cmake ..
    if ($lastexitcode -ne 0) {throw}
    & cmake --build .
    if ($lastexitcode -ne 0) {throw}

    & ctest --verbose -C Debug
    if ($lastexitcode -ne 0) {throw}

    Pop-Location
    
}




