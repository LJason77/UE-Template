if "%1"=="hide" goto CmdBegin
start mshta vbscript:createobject("wscript.shell").run("""%~0"" hide",0)(window.close)&&exit
:CmdBegin

cd ..
set uproject_file=
for %%f in (*.uproject) do (
  set uproject_file=%%f
)

if defined uproject_file (
  "C:\Program Files\Epic Games\UE_5.3\Engine\Binaries\Win64\UnrealEditor.exe" "%CD%\%uproject_file%" -game -ResX=960 -ResY=540 -log -WINDOWED
) else (
  echo No .uproject file found
)
