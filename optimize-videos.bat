@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ==============================================================
rem optimize-videos.bat (simple)
rem Double-click to create an "optimized-videos" folder with web-
rem friendly MP4 (H.264 + AAC) copies of videos from this folder
rem and all subfolders.
rem
rem Requires: ffmpeg in PATH (https://ffmpeg.org/)
rem Originals are never modified.
rem ==============================================================

cd /d "%~dp0"

set "FFMPEG=ffmpeg"
if exist "%~dp0ffmpeg.exe" set "FFMPEG=%~dp0ffmpeg.exe"

"%FFMPEG%" -version >nul 2>&1
if errorlevel 1 (
  echo ERROR: ffmpeg not found.
  echo Put ffmpeg.exe next to this .bat or add it to PATH.
  echo.
  pause
  exit /b 1
)

set "OUTROOT=%~dp0optimized-videos"
if not exist "%OUTROOT%" mkdir "%OUTROOT%" >nul 2>&1

set /a SEEN=0
set /a DONE=0

for %%F in (*.mp4 *.mov *.m4v *.mkv *.avi *.webm *.mpg *.mpeg *.3gp *.3g2 *.mts *.m2ts) do (
  if exist "%%~fF" (
    set "IN=%%~fF"
    set /a SEEN+=1
    set "OUT=%OUTROOT%\%%~nF.mp4"
    call :PROCESS_ONE "%%~fF" "!OUT!"
  )
)

echo.
echo Done. Seen: !SEEN!  Wrote: !DONE!

echo.
pause
exit /b 0

:PROCESS_ONE
set "IN=%~1"
set "OUT=%~2"

if /i "%~x1"==".mp4" (
  "%FFMPEG%" -hide_banner -loglevel error -y -i "%IN%" -map_metadata -1 -sn -c copy -movflags +faststart "%OUT%" >nul 2>&1
) else (
  "%FFMPEG%" -hide_banner -loglevel error -y -i "%IN%" -map_metadata -1 -sn -vf "scale='min(iw,1280)':-2" -c:v libx264 -preset medium -crf 23 -pix_fmt yuv420p -c:a aac -b:a 128k -movflags +faststart "%OUT%" >nul 2>&1
)

if not errorlevel 1 if exist "%OUT%" (
  set /a DONE+=1
  echo WROTE: %~nx1 ^> "%OUT%"
) else (
  echo FAIL: %~nx1
)

goto :eof
