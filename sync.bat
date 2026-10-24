@echo off
setlocal
title GitHub sync
cd /d "%~dp0"

rem --- Check of git er is ---
git --version >nul 2>&1
if errorlevel 1 goto :nogit

rem --- Check of dit een git-repo is ---
git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 goto :norepo

rem --- Check of git weet wie je bent (naam + e-mail) ---
git config user.email >nul 2>&1
if errorlevel 1 goto :identity
git config user.name >nul 2>&1
if errorlevel 1 goto :identity

:start
echo.
echo === Wijzigingen verzamelen ===
git add -A

git diff --cached --quiet
if not errorlevel 1 goto :nochanges

echo.
git status --short
echo.
set "msg="
set /p "msg=Korte beschrijving (of gewoon Enter): "
if not defined msg set "msg=Update %date% %time:~0,5%"
git commit -m "%msg%"
if errorlevel 1 goto :fail

:pull
echo.
echo === Nieuwste versie van GitHub ophalen ===
git pull --rebase
if errorlevel 1 goto :conflict

echo.
echo === Naar GitHub sturen ===
echo (De eerste keer opent er een inlogvenster van GitHub.)
git push
if errorlevel 1 goto :fail

echo.
echo Klaar! Alles staat op GitHub.
pause
exit /b 0

:identity
echo.
echo === Eenmalig instellen ===
echo Git moet weten welke naam en e-mail bij je wijzigingen horen.
echo Dit is alleen een label, je wachtwoord vul je hier NIET in.
echo.
echo Tip voor je e-mail: je "noreply"-adres van GitHub, dan blijft je
echo echte e-mail prive. Je vindt het op https://github.com/settings/emails
echo (iets als 12345678+jouwnaam@users.noreply.github.com)
echo.
set "gname="
set "gmail="
set /p "gname=Je naam of GitHub-gebruikersnaam: "
set /p "gmail=Je e-mail: "
if not defined gname goto :identity
if not defined gmail goto :identity
git config --global user.name "%gname%"
git config --global user.email "%gmail%"
echo Opgeslagen! Dit hoef je nooit meer te doen.
goto :start

:nochanges
echo Geen nieuwe wijzigingen gevonden, ik check nog wel of GitHub iets nieuws heeft.
goto :pull

:conflict
echo.
echo Er is een conflict: hetzelfde bestand is zowel hier als op GitHub aangepast.
echo Open de map in GitHub Desktop, daar kun je kiezen welke versie je houdt.
echo (Of typ "git rebase --abort" om terug te gaan naar hoe het was.)
pause
exit /b 1

:nogit
echo Git is niet gevonden. Installeer het via https://git-scm.com/download/win
echo en start dit bestand daarna opnieuw.
pause
exit /b 1

:norepo
echo Dit bestand staat niet in je repo-map. Zet sync.bat in de map die je gecloned hebt.
pause
exit /b 1

:fail
echo.
echo Er ging iets mis, kijk naar de melding hierboven.
pause
exit /b 1
