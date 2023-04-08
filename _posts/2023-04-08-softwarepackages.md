---
layout: post
title:  "My favourite Desktop Opens-Source Software and Package Managers"
date:   2023-04-08 18:00:00 +0100
categories: [software]
tags: [open source software, package managers]
---

# My favourite desktop open-source software

* Firefox      https://www.mozilla.org/
* Thunderbird  https://www.thunderbird.net/
* LibreOffice  https://www.libreoffice.org/
* Gimp         https://www.gimp.org/
* VLC          https://www.videolan.org/vlc/

# Ubuntu

Ubuntu usually uses the debian package format. But firefox is pre-installed and provided as a snap package.
On the one hand, you need to install it manually. On the other hand, snap-packaging breaks printer integration.

So installation of the remaining favourite packages is:
```
sudo apt install -y thunderbird libreoffice gimp vlc
```
# Raspberry Pi OS

Raspberry Pi OS uses the debian package, too.
So installing my favourite open-source software goes like this:
```
sudo apt install -y firefox-esr thunderbird libreoffice gimp vlc
```

# macOS and Homebrew

On Apple's macOS, you can use homebrew for package management: https://brew.sh/

After installing homebrew, we can install OSS software like this:
```
brew install firefox
brew install thunderbird
brew install libreoffice
brew install gimp
brew install vlc
```


Additional note to self:
When installing a brew package from a git repository, it needs ssh.
But homebrew cannot deal with passphrase-protected ssh keys (https://github.com/Homebrew/brew/issues/6583).
The easiest workaround is temporarily changing the ssh passphrase to an "empty" string.
After installation, we can change it back to the real passphrase.
https://www.unixtutorial.org/changing-passphrase-to-your-ssh-private-key

# Windows and Chocolatey

Setting up the computer for a friend was always a long way of work.
I had to download all the software and install it.
Recently I have found https://chocolatey.org/, where I found all my favourite packages.
Next time I will only have to install Chocolatey and then:
```
choco install firefox
choco install thunderbird
choco install libreoffice
choco install gimp
choco install vlc
```