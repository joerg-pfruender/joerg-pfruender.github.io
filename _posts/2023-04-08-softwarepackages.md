---
layout: post
title:  "My favourite Desktop Open-Source Software and Package Managers"
date:   2023-04-08 18:00:00 +0200
categories: [software]
tags: [open source software, package managers]
---

# My favourite desktop open-source software

* Firefox      [https://www.mozilla.org/](https://www.mozilla.org/)
* Thunderbird  [https://www.thunderbird.net/](https://www.thunderbird.net/)
* LibreOffice  [https://www.libreoffice.org/](https://www.libreoffice.org/)
* Gimp         [https://www.gimp.org/](https://www.gimp.org/)
* VLC          [https://www.videolan.org/vlc/](https://www.videolan.org/vlc/)

# Linux: Flatpak

## 1. Install flatpak

[https://www.flatpak.org/setup/](https://www.flatpak.org/setup/)

## 2. Install packages from flatpak
```bash
flatpak install -y flathub org.mozilla.firefox
flatpak install -y flathub org.mozilla.Thunderbird
flatpak install -y flathub org.libreoffice.LibreOffice
flatpak install -y flathub org.gimp.GIMP
flatpak install -y flathub org.videolan.VLC
```

# MacOS: Homebrew

## 1. Install Homebrew
[https://brew.sh/](https://brew.sh/)

## 2. Install packages from homebrew
```bash
brew install --cask firefox
brew install --cask thunderbird
brew install --cask libreoffice
brew install --cask gimp
brew install --cask vlc
```

Additional note to self:
When installing a brew package from a git repository, it needs ssh.
But [homebrew cannot deal with passphrase-protected ssh keys](https://github.com/Homebrew/brew/issues/6583).
The easiest workaround is temporarily changing the ssh passphrase to an "empty" string.
After installation, we can change it back to the real passphrase.
[https://www.unixtutorial.org/changing-passphrase-to-your-ssh-private-key](https://www.unixtutorial.org/changing-passphrase-to-your-ssh-private-key)

# Windows: Chocolatey

## 1. Install Chocolatey
[https://chocolatey.org/install](https://chocolatey.org/install)

## 2. Install packages from Chocolatey
```
choco install firefox thunderbird libreoffice gimp vlc
```

# Upgrade all software

You should update your software regularly.

## Flatpak

```bash
flatpak update
```

## Ubuntu

```bash
sudo apt-get update && sudo apt-get upgrade
sudo snap refresh
```


## Raspberry Pi OS

```bash
sudo apt-get update && sudo apt-get upgrade
```

## Homebrew

```bash
brew update && brew upgrade
```

## Chocolatey

```
choco upgrade all -y
```
Windows users usually don't like the command line. 
So with the help of [https://stackoverflow.com/questions/1894967/how-to-request-administrator-access-inside-a-batch-file](https://stackoverflow.com/questions/1894967/how-to-request-administrator-access-inside-a-batch-file) I've created a script:
```
@echo off

:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------    
    choco upgrade all -y
```
Copy this script into a text file and save if as `update.bat` on your desktop. Then for updates, you just need to double-click on the icon.

# more programs
There are a few more programs, that I recommend:

* Draw.io   (vector graphics)   [https://www.drawio.com/](https://www.drawio.com/)
* Bitwarden (password manager)  [https://bitwarden.com/](https://bitwarden.com/)
* Brave (privacy oriented browser) [https://brave.com/](https://brave.com/)
* Backup: 
  * Déjà Dup for Linux [https://apps.gnome.org/de/DejaDup/](https://apps.gnome.org/de/DejaDup/) and 
  * FreeFileSync for Windows [https://freefilesync.org/](https://freefilesync.org/), which has [no support for Chocolatey](https://freefilesync.org/forum/viewtopic.php?t=10390)
* More for Windows: 
  * Create and unpack ZIP archives with 7-zip [https://www.7-zip.org/](https://www.7-zip.org/)
  * Notepad++ Editor [https://notepad-plus-plus.org/](https://notepad-plus-plus.org/)

Although Bitwarden is legally open source software, there's a company that dominates the development process.
Still in its domain, it is probably one of most mature free software solutions that you can find.

Flatpak:
```bash
flatpak install -y flathub com.jgraph.drawio.desktop
flatpak install -y flathub com.bitwarden.desktop
flatpak install -y flathub com.brave.Browser
flatpak install -y flatpak install flathub org.gnome.DejaDup
```

Chocolatey:
```
choco install drawio bitwarden brave 7zip notepadplusplus
```

Homebrew:
```bash
brew install --cask drawio
brew install --cask bitwarden
brew install --cask brave-browser
```

### Links:
* [My favourite tools for software development on Linux](/software/2024/08/17/softwarepackages_for_development.html)
* [Easily switch between java versions with SDKMAN! and 'j'](/software/java/2022/12/30/sdkman_j.html)

### Updates

#### 2024-02-20/2024-03-01

Howto upgrade packages

#### 2024-08-17
* change package managers for Linux to Flatpak
* add Brave browser
* add backup software


*Any comments or suggestions? Leave an issue or a pull request!*