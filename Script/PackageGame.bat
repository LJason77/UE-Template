@echo off
setlocal

REM - 该批处理文件将打包（构建、烘焙和暂存）虚幻引擎项目。

REM - 设置引擎位置
set ENGINE="C:\Program Files\Epic Games\UE_5.3\Engine"
REM - 设置所有项目位置
set UNREALPROJECTS=E:\Unreal Projects
REM - 设置项目名称
set PROJECT_NAME=Templates

REM - 将 MAPS 设置为要烹饪的地图列表，例如“MainMenuMap+FirstLevel+SecondLevel+TestMap”（请勿在此处放置空格！！！）
set MAPS=

if exist "%UNREALPROJECTS%\%PROJECT_NAME%\%PROJECT_NAME%.uproject" goto Continue

echo.
echo 警告 - “%UNREALPROJECTS%\%PROJECT_NAME%\%PROJECT_NAME%.uproject” 不存在
echo （在文本编辑器中编辑此批处理文件并设置 UNREALPROJECTS 和 PROJECT_NAME 变量）
echo.

pause

goto Exit

:Continue

if exist BUILD_EDITOR_FAILED.txt del BUILD_EDITOR_FAILED.txt
if exist BUILD_GAME_FAILED.txt del BUILD_GAME_FAILED.txt
if exist PACKAGING_FAILED.txt del PACKAGING_FAILED.txt

if NOT "%MAPS%"=="" (goto CheckInstalledBuild)

echo.
echo 警告 - 没有设置地图，这将导致所有内容都被烘焙！
echo （可能会使打包构建比需要的更大）
echo.

:CheckInstalledBuild

REM - 检查是否是 “安装版”（即从 Epic Launcher 安装）或源代码版本（来自 GitHub）。
if exist "%ENGINE%\Build\InstalledBuild.txt" (
    set INSTALLED=-installed
) else (
    set INSTALLED=
)

REM - 检查项目是否存在 .sln 文件。如果存在，则它是一个 C++ 项目，可以构建游戏编辑器和游戏。
REM - 否则它是一个蓝图项目。
if exist "%UNREALPROJECTS%\%PROJECT_NAME%\%PROJECT_NAME%.sln" (
    echo.
    echo %date% %time% 构建游戏编辑器...
    echo.

    call %ENGINE%\Build\BatchFiles\RunUAT.bat BuildEditor -Project="%UNREALPROJECTS%\%PROJECT_NAME%\%PROJECT_NAME%.uproject" -notools
    if errorlevel 1 goto Error_BuildEditorFailed

    echo.
    echo %date% %time% 构建游戏...
    echo.

    call %ENGINE%\Build\BatchFiles\RunUAT.bat BuildGame -project="%UNREALPROJECTS%\%PROJECT_NAME%\%PROJECT_NAME%.uproject" -platform=Win64 -notools -configuration=Development+Shipping+DebugGame
    if errorlevel 1 goto Error_BuildGameFailed
)

echo.
echo %date% %time% 打包游戏...
echo.

REM - 注意: "-clean" 将清理并重建游戏代码（对于 C++ 项目），并将在每次运行时清理项目的 Saved\Cooked 和 Saved\StaggedBuilds
REM - 注意: 如果不希望每次打包都完全重建游戏代码，可以添加 "-nocompile" 以跳过编译游戏代码。
REM - 注意: "-pak" 会将所有已处理的内容存储到 .pak 文件中（使用 UnrealPak 工具）。打包游戏可以（可选）使用加密的 .pak 文件以获得更好的安全性。
REM - 注意: 当准备好发布游戏时，将 -configuration 更改为 "-configuration=Shipping" （以防止在发布的版本中包含 Development 和 DebugGame 可执行文件）。
REM - 注意: 当准备好发布游戏时，添加 "-nodebuginfo" 以防止 .pdb 文件被添加到游戏的 Binaries/Win64 文件夹中。
REM - 注意: 使用 "-createreleaseversion" 可以稍后为游戏创建补丁和 DLC。
REM - 注意: 如果想压缩包，可以使用 "-compressed" （这将使文件更小，但在游戏中加载可能需要更长的时间）。

call %ENGINE%\Build\BatchFiles\RunUAT.bat BuildCookRun -project="%UNREALPROJECTS%\%PROJECT_NAME%\%PROJECT_NAME%.uproject" %INSTALLED% -platform=Win64 -configuration=Development+Shipping+DebugGame -map=%MAPS% -nocompileeditor -unattended -utf8output -clean -build -cook -stage -pak -prereqs -package -archive -archivedirectory="%UNREALPROJECTS%\%PROJECT_NAME%\/PackageGame" -createreleaseversion=1.0 -iostore -makebinaryconfig -compressed
@REM call %ENGINE%\Build\BatchFiles\RunUAT.bat BuildCookRun -project="%UNREALPROJECTS%\%PROJECT_NAME%\%PROJECT_NAME%.uproject" %INSTALLED% -platform=Win64 -configuration=Shipping -map=%MAPS% -nocompileeditor -unattended -utf8output -clean -build -cook -stage -pak -prereqs -package -archive -archivedirectory="%UNREALPROJECTS%\%PROJECT_NAME%\/PackageGame" -createreleaseversion=1.0 -iostore -makebinaryconfig -compressed -nodebuginfo
if errorlevel 1 goto Error_PackagingFailed

echo.
echo %date% %time% 构建完成！

goto Exit


:Error_BuildEditorFailed
echo.
echo %date% %time% 错误 - 构建编辑器失败！
type NUL > BUILD_EDITOR_FAILED.txt
goto Exit

:Error_BuildGameFailed
echo.
echo %date% %time% 错误 - 构建游戏失败！
type NUL > BUILD_GAME_FAILED.txt
goto Exit

:Error_PackagingFailed
echo.
echo %date% %time% 错误 - 打包失败
type NUL > PACKAGING_FAILED.txt
goto Exit


:Exit
