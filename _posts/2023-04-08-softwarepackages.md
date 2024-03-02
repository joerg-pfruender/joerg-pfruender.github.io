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

# Ubuntu

Ubuntu usually uses the debian package format. But firefox is pre-installed and provided as a snap package.
On the one hand, you don't need to install it manually. On the other hand, snap-packaging breaks printer integration.

VLC is provided both as a debian package and as a snap package. But the deb package will be left outdated with security issues (unless you register for Ubuntu Pro and [allow Ubuntu to send all your data to chinese government authorities](https://ubuntu.com/legal/ubuntu-pro/personal)).

So installation of the remaining favourite packages is:
```
sudo apt install -y thunderbird libreoffice gimp
sudo snap install vlc
```

# Raspberry Pi OS

Raspberry Pi OS uses the debian package, too.
So installing my favourite open-source software goes like this:
```
sudo apt install -y firefox-esr thunderbird libreoffice gimp vlc
```

# MacOS and Homebrew

On Apple's macOS, you can use homebrew for package management: [https://brew.sh/](https://brew.sh/)

After installing homebrew, we can install OSS software like this:
```
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

# Windows and Chocolatey

Setting up the computer for a friend was always a long way of work.
I had to download all the software and install it.
Recently I have found [https://chocolatey.org/](https://chocolatey.org/), where I found all my favourite packages.
Next time I will only have to install Chocolatey and then:
```
choco install firefox thunderbird libreoffice gimp vlc
```

#### Update 2024-02-20/2024-03-01

# Upgrade all software

You should update your software regularly.

## Ubuntu

```
sudo apt-get update && sudo apt-get upgrade
sudo snap refresh
```


## Raspberry Pi OS

```
sudo apt-get update && sudo apt-get upgrade
```

## Homebrew

```
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

# more packages
There are two more programs, that I recommend:

* Draw.io   (vector graphics)   [https://www.drawio.com/](https://www.drawio.com/)
* Bitwarden (password manager)  [https://bitwarden.com/](https://bitwarden.com/)

Although Bitwarden and Bacula are legally open source software, there's a company that dominates the development process.
Still in their domain, they are probably one of most mature free software solutions that you can find.

Chocolatey:
```
choco install drawio bitwarden
```

Homebrew:

```
brew install --cask drawio
brew install --cask bitwarden
```

*Any comments or suggestions? Leave an issue or a pull request!*