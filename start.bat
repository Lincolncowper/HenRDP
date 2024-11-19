@echo off
:: Nonaktifkan Test Signing dan reboot
bcdedit -set TESTSIGNING OFF
shutdown /r /t 5

:: Konfigurasi sistem dasar
del /f "C:\Users\Public\Desktop\Epic Games Launcher.lnk" > out.txt 2>&1
net config server /srvcomment:"Windows Server Custom RDP" > out.txt 2>&1
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /V EnableAutoTray /T REG_DWORD /D 0 /F > out.txt 2>&1
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /f /v Wallpaper /t REG_SZ /d D:\a\wallpaper.bat
net user administrator CustomRDP /add >nul
net localgroup administrators administrator /add >nul
net user administrator /active:yes >nul
net user installer /delete
diskperf -Y >nul
sc config Audiosrv start= auto >nul
sc start audiosrv >nul
ICACLS C:\Windows\Temp /grant administrator:F >nul
ICACLS C:\Windows\installer /grant administrator:F >nul
echo Successfully Installed RDP System!

:: Membuka akses RDP dan memulai tunnel
echo Starting RDP Service and Tunnel...
tasklist | find /i "localtonet.exe" >nul || (
    echo Starting Localtonet...
    start /b localtonet.exe tcp --port 3389 --token "%LOCALTONET_TOKEN%"
)
echo RDP Created Successfully! Monitoring Process...

:: Monitoring dan otomatis rebuild jika perlu
:monitor
tasklist | find /i "localtonet.exe" >nul || goto rebuild
ping -n 10 127.0.0.1 >nul
goto monitor

:rebuild
echo Localtonet Tunnel Stopped. Triggering GitHub Actions Rebuild...
curl -X POST -H "Accept: application/vnd.github+json" `
     -H "Authorization: token %GITHUB_PERSONAL_ACCESS_TOKEN%" `
     https://api.github.com/repos/<your-username>/<your-repo>/actions/workflows/<workflow-id>/dispatches `
     -d "{\"ref\":\"main\"}"
echo Rebuild Triggered. Exiting...
exit