set Openeuodir=c:\program files\ultima online classic\openeuo
set Uodir=C:\Program Files (x86)\Electronic Arts\Ultima Online Classic

@echo off
color 2
title Wesley's Ultime Online Junction Installer
cls


echo Welcome to Wesley's Ultime Online Junction Installer
echo. 
echo By executing the included command line, you will be creating a link to your 
echo Ultima Online game files. This link in theory could allow OpenEUO scripts to
echo harm, change, or corrupt said files.
echo.
echo I am not responsible for the misuse of this link.
:invalid_choice
set /p choice=Install Junction? (y/n): 
if %choice%==y goto yes
if %choice%==n exit
echo invalid choice: %choice%
goto invalid_choice

:yes
cls
echo OpenEUO directory is "%Openeuodir%"  
echo Ultima Online directory is "%Uodir%"
echo.
echo "n" will allow you to input different locations.
:invalid_choice2
set /p choice=Confirm these locations! (y/n): 
if %choice%==y goto confirm
if %choice%==n goto input
echo invalid choice: %choice%
goto invalid_choice2

:input
cls
echo OK, So you want to type the directorys in? If you open this file in Notepad, 
echo you can paste the directories in the first two lines!
echo.
echo Enter OpenEUO directory (eg. "c:\Openeuo" with no quotations) 
set /p Openeuodir=OEUO:
echo Enter Ultima directory (eg. "c:\UO" with no quotations) 
set /p Uodir=UO:
goto yes

:confirm
set Openeuodir="%Openeuodir%\Ultima Online Classic"
set Uodir="%Uodir%"

MKLINK /J %Openeuodir% %Uodir%
pause
echo on