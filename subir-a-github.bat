@echo off
REM Sube la documentacion al repositorio privado del grupo.
REM La primera vez Git abrira el navegador para iniciar sesion en GitHub.
cd /d C:\Telecom\TelecomFinal
if not exist .git (
  git init -b main
  git remote add origin https://github.com/ByronRodM/TelecomFinal.git
)
git config user.name >nul 2>&1 || git config user.name "Byron Rodriguez"
git config user.email >nul 2>&1 || git config user.email "brodriguezm6@miumg.edu.gt"
git add -A
git commit -m "Documentacion del proyecto: %date% %time%"
git push -u origin main
pause
