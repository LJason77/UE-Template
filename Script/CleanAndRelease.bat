@echo off

REM - 该批处理文件将为虚幻引擎项目清理并构建编辑器和游戏代码。

REM - 设置引擎位置
set ENGINE="C:\Program Files\Epic Games\UE_5.3\Engine"
REM - 设置所有项目位置
set UNREALPROJECTS=E:\Unreal Projects
REM - 设置项目名称
set PROJECT_NAME=Templates

REM - 运行前确保已经设置 UNREALPROJECTS 环境变量，为所有虚幻引擎项目所在的路径
if exist "%UNREALPROJECTS%\%PROJECT_NAME%\%PROJECT_NAME%.uproject" goto Continue

echo.
echo 警告 - “%UNREALPROJECTS%\%PROJECT_NAME%\%PROJECT_NAME%.uproject” 不存在
echo （在文本编辑器中编辑此批处理文件并设置 UNREALPROJECTS 和 PROJECT_NAME 变量）
echo.

pause

goto Exit

:Continue

if exist CLEAN_FAILED.txt del CLEAN_FAILED.txt
if exist BUILD_TOOLS_FAILED.txt del BUILD_TOOLS_FAILED.txt
if exist BUILD_EDITOR_FAILED.txt del BUILD_EDITOR_FAILED.txt
if exist BUILD_GAME_FAILED.txt del BUILD_GAME_FAILED.txt

REM - 检查是否是 “安装版”（即从 Epic Launcher 安装）或源代码版本（来自 GitHub）。
if exist "%ENGINE%\Build\InstalledBuild.txt" (
    goto InstalledBuild
) else (
    goto SourceCodeBuild
)

:InstalledBuild

REM - 检查项目是否存在 .sln 文件。如果存在，则它是一个 C++ 项目，可以清理并构建游戏编辑器和游戏。
REM - 否则它是一个蓝图项目。

if exist "%UNREALPROJECTS%\%PROJECT_NAME%\%PROJECT_NAME%.sln" (
    echo.
    echo %date% %time% 清理游戏编辑器...
    echo.

    call %ENGINE%\Build\BatchFiles\Clean.bat -Target="%PROJECT_NAME%Editor Win64 Development" -Project="%UNREALPROJECTS%\%PROJECT_NAME%\%PROJECT_NAME%.uproject" -WaitMutex -FromMSBuild
    if errorlevel 1 goto Error_CleanFailed

    echo.
    echo %date% %time% 构建游戏编辑器...
    echo.

    call %ENGINE%\Build\BatchFiles\RunUAT.bat BuildEditor -Project="%UNREALPROJECTS%\%PROJECT_NAME%\%PROJECT_NAME%.uproject" -notools
    if errorlevel 1 goto Error_BuildEditorFailed

    echo.
    echo %date% %time% 清理游戏...
    echo.

    call %ENGINE%\Build\BatchFiles\Clean.bat -Target="%PROJECT_NAME% Win64 Development" -Target="%PROJECT_NAME% Win64 Shipping" -Target="%PROJECT_NAME% Win64 DebugGame" -Project="%UNREALPROJECTS%\%PROJECT_NAME%\%PROJECT_NAME%.uproject" -WaitMutex -FromMSBuild
    if errorlevel 1 goto Error_CleanFailed

    echo.
    echo %date% %time% 构建游戏...
    echo.

    call %ENGINE%\Build\BatchFiles\RunUAT.bat BuildGame -project="%UNREALPROJECTS%\%PROJECT_NAME%\%PROJECT_NAME%.uproject" -platform=Win64 -notools -configuration=Development+Shipping+DebugGame
    if errorlevel 1 goto Error_BuildGameFailed
) else (
    echo.
    echo 不需要运行该批处理文件。因为无需为蓝图项目构建任何内容。

    goto Exit
)

echo.
echo %date% %time% 构建完成！

goto Exit

:SourceCodeBuild

echo.
echo %date% %time% 清理工具...
echo.

call %ENGINE%\Build\BatchFiles\Clean.bat UnrealHeaderTool Win64 Development -WaitMutex -FromMSBuild
if errorlevel 1 goto Error_CleanFailed
call %ENGINE%\Build\BatchFiles\Clean.bat UnrealPak Win64 Development -WaitMutex -FromMSBuild
if errorlevel 1 goto Error_CleanFailed
call %ENGINE%\Build\BatchFiles\Clean.bat ShaderCompileWorker Win64 Development -WaitMutex -FromMSBuild
if errorlevel 1 goto Error_CleanFailed
call %ENGINE%\Build\BatchFiles\Clean.bat UnrealLightmass Win64 Development -WaitMutex -FromMSBuild
if errorlevel 1 goto Error_CleanFailed
call %ENGINE%\Build\BatchFiles\Clean.bat UnrealFrontend Win64 Development -WaitMutex -FromMSBuild
if errorlevel 1 goto Error_CleanFailed
call %ENGINE%\Build\BatchFiles\Clean.bat UnrealInsights Win64 Development -WaitMutex -FromMSBuild
if errorlevel 1 goto Error_CleanFailed
call %ENGINE%\Build\BatchFiles\Clean.bat UnrealMultiUserServer Win64 Development -WaitMutex -FromMSBuild
if errorlevel 1 goto Error_CleanFailed
call %ENGINE%\Build\BatchFiles\Clean.bat CrashReportClient Win64 Shipping -WaitMutex -FromMSBuild
if errorlevel 1 goto Error_CleanFailed
call %ENGINE%\Build\BatchFiles\Clean.bat CrashReportClientEditor Win64 Shipping -WaitMutex -FromMSBuild
if errorlevel 1 goto Error_CleanFailed

echo.
echo %date% %time% 清理编辑器...
echo.

call %ENGINE%\Build\BatchFiles\Clean.bat -Target="UE5Editor Win64 Development" -WaitMutex -FromMSBuild
if errorlevel 1 goto Error_CleanFailed

echo.
echo %date% %time% Cleaning Editor Game (UE5Game)...
echo.

call %ENGINE%\Build\BatchFiles\Clean.bat UE5Game Win64 Development -WaitMutex -FromMSBuild
if errorlevel 1 goto Error_CleanFailed
call %ENGINE%\Build\BatchFiles\Clean.bat UE5Game Win64 Shipping -WaitMutex -FromMSBuild
if errorlevel 1 goto Error_CleanFailed
call %ENGINE%\Build\BatchFiles\Clean.bat UE5Game Win64 DebugGame -WaitMutex -FromMSBuild
if errorlevel 1 goto Error_CleanFailed

REM - 检查项目是否存在 .sln 文件。如果存在，则它是一个 C++ 项目，可以构建游戏编辑器和游戏。
REM - 否则它是一个蓝图项目。
if exist "%UNREALPROJECTS%\%PROJECT_NAME%\%PROJECT_NAME%.sln" (
    echo.
    echo %date% %time% 清理游戏编辑器...
    echo.

    call %ENGINE%\Build\BatchFiles\Clean.bat -Target="%PROJECT_NAME%Editor Win64 Development" -Project="%UNREALPROJECTS%\%PROJECT_NAME%\%PROJECT_NAME%.uproject" -WaitMutex -FromMSBuild
    if errorlevel 1 goto Error_CleanFailed

    echo.
    echo %date% %time% 清理游戏...
    echo.

    call %ENGINE%\Build\BatchFiles\Clean.bat -Target="%PROJECT_NAME% Win64 Development" -Target="%PROJECT_NAME% Win64 Shipping" -Target="%PROJECT_NAME% Win64 DebugGame" -Project="%UNREALPROJECTS%\%PROJECT_NAME%\%PROJECT_NAME%.uproject" -WaitMutex -FromMSBuild
    if errorlevel 1 goto Error_CleanFailed
)

echo.
echo %date% %time% 构建工具...
echo.

%ENGINE%\Binaries\DotNET\UnrealBuildTool.exe UnrealFrontend Win64 Development -WaitMutex -FromMSBuild
if errorlevel 1 goto Error_BuildToolsFailed
%ENGINE%\Binaries\DotNET\UnrealBuildTool.exe UnrealInsights Win64 Development -WaitMutex -FromMSBuild
if errorlevel 1 goto Error_BuildToolsFailed
%ENGINE%\Binaries\DotNET\UnrealBuildTool.exe UnrealMultiUserServer Win64 Development -WaitMutex -FromMSBuild
if errorlevel 1 goto Error_BuildToolsFailed

REM - 当构建编辑器时，其他工具将由 UBT 构建（当未指定 -notools 时）

echo.
echo %date% %time% 构建编辑器...
echo.

call %ENGINE%\Build\BatchFiles\RunUAT.bat BuildEditor
if errorlevel 1 goto Error_BuildEditorFailed

echo.
echo %date% %time% Building Editor Game (UE5Game)...
echo.

call %ENGINE%\Build\BatchFiles\RunUAT.bat BuildGame -platform=Win64 -configuration=Development+Shipping+DebugGame
if errorlevel 1 goto Error_BuildGameFailed

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
echo %date% %time% 构建完成！

goto Exit

:Error_CleanFailed
echo.
echo %date% %time% 错误 - 清理失败！
type NUL > CLEAN_FAILED.txt
pause
goto Exit

:Error_BuildToolsFailed
echo.
echo %date% %time% 错误 - 构建工具失败！
type NUL > BUILD_TOOLS_FAILED.txt
pause
goto Exit

:Error_BuildEditorFailed
echo.
echo %date% %time% 错误 - 构建编辑器失败！
type NUL > BUILD_EDITOR_FAILED.txt
pause
goto Exit

:Error_BuildGameFailed
echo.
echo %date% %time% 错误 - 构建游戏失败！
type NUL > BUILD_GAME_FAILED.txt
pause
goto Exit

:Exit
