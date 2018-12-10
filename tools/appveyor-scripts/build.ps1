Set-PSDebug -Trace 1

$env:ANDROID_NDK_HOME=$env:APPVEYOR_BUILD_FOLDER + "\..\android-ndk-r18"
$env:NDK_ROOT=$env:APPVEYOR_BUILD_FOLDER + "\..\android-ndk-r18"
$env:ANDROID_NDK_ROOT=$env:APPVEYOR_BUILD_FOLDER + "\..\android-ndk-r18"

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

} else {
    # setup visual studio command line
    # needed for ninja
    if ($env:build_type -eq "windows_32") {
        & "${env:COMSPEC}" /s /c "`"C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat`" x86 > NUL && set" | foreach-object {
            $name, $value = $_ -split '=', 2
            set-content env:\"$name" $value
        }
    }
    if ($env:build_type -eq "windows_64") {
        & "${env:COMSPEC}" /s /c "`"C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat`" x86_x64 > NUL && set" | foreach-object {
            $name, $value = $_ -split '=', 2
            set-content env:\"$name" $value
        }
    }
    if ($env:build_type -eq "windows_arm") {
        & "${env:COMSPEC}" /s /c "`"C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat`" x86_arm > NUL && set" | foreach-object {
            $name, $value = $_ -split '=', 2
            set-content env:\"$name" $value
        }
    }
    if ($env:build_type -eq "windows_arm64") {
        & "${env:COMSPEC}" /s /c "`"C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat`" x86_arm64 > NUL && set" | foreach-object {
            $name, $value = $_ -split '=', 2
            set-content env:\"$name" $value
        }
    }
    & mkdir $env:APPVEYOR_BUILD_FOLDER\build
    # if ($lastexitcode -ne 0) {throw}
    Push-Location $env:APPVEYOR_BUILD_FOLDER\build
    & cmake -G Ninja ..
    if ($lastexitcode -ne 0) {throw}
    & cmake --build .
    if ($lastexitcode -ne 0) {throw}

    & ctest --verbose -C Debug
    if ($lastexitcode -ne 0) {throw}

    Pop-Location
    
}




