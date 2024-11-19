@echo off
echo RDP CREATION SUCCESSFUL!

tasklist | find /i "localtonet.exe" >Nul && goto check || echo "Unable to get Localtonet tunnel. Make sure your Localtonet service is running and properly configured." & ping 127.0.0.1 >Nul & exit

:check
ping 127.0.0.1 >nul
cls
echo RDP CREATION SUCCESSFUL!
goto check