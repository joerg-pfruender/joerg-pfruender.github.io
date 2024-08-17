---
layout: post
title:  "My favourite tools for software development on Linux"
date:   2023-04-08 16:00:00 +0200
categories: [software]
tags: [package managers, development]
---

## 1. Install curl, wget, git, zip

```bash
sudo apt install -y curl wget git zip
```

## 2. Install Flatpak

[https://www.flatpak.org/setup/](https://www.flatpak.org/setup/)


## 3. Install favorite software from Flatpack

* [Postman](https://flathub.org/apps/com.getpostman.Postman)
* [IntelliJ IDEA Community](https://flathub.org/apps/com.jetbrains.IntelliJ-IDEA-Community)
* [PyCharm](https://flathub.org/apps/com.jetbrains.PyCharm-Community)
* [DBeaver](https://flathub.org/apps/io.dbeaver.DBeaverCommunity)
* [KeePassXC](https://flathub.org/apps/org.keepassxc.KeePassXC)
```bash
flatpak install -y flathub com.getpostman.Postman
flatpak install -y flathub com.jetbrains.IntelliJ-IDEA-Community
flatpak install -y flathub com.jetbrains.PyCharm-Community
flatpak install -y flathub io.dbeaver.DBeaverCommunity
flatpak install -y flathub org.keepassxc.KeePassXC
```

## 4. Install SDKMAN! and Node Version Manager

* [https://sdkman.io/](https://sdkman.io/)
* [https://github.com/nvm-sh/nvm](https://github.com/nvm-sh/nvm)

```bash
curl -s "https://get.sdkman.io" | bash 
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
```

## 5. create /opt/tools for other tools

```bash
sudo mkdir /opt/tools
```

## 6. install "j" in /opt/tools

[https://github.com/ldziedziul/j/](https://github.com/ldziedziul/j/)

```bash
sudo mkdir /opt/tools/j
sudo chown $USER /opt/tools/j
sudo cat > /opt/tools/j/j.sh << 'EOF'
#!/usr/bin/env bash

function print_usage() {
    VERSIONS=$(\ls $SDKMAN_DIR/candidates/java | \grep -v current | \awk -F'.' '{print $1}' | \sort -nr | \uniq)
    CURRENT=$(\basename $(\readlink $JAVA_HOME || \echo $JAVA_HOME) | \awk -F'.' '{print $1}')
    \echo "Available versions: "
    \echo "$VERSIONS"
    \echo "Current: $CURRENT"
    \echo "Usage: j <java_version>"
}

if [[ $# -eq 1 ]]; then
  VERSION_NUMBER=$1
  IDENTIFIER=$(\ls $SDKMAN_DIR/candidates/java | \grep -v current | \grep "^$VERSION_NUMBER." | \sort -r | \head -n 1)
  sdk use java $IDENTIFIER
else
  print_usage
fi
EOF
chmod u+x /opt/tools/j/j.sh
echo 'alias j=". /opt/tools/j/j.sh"' >> ~/.bashrc
```


### links

* [My favourite Desktop Open-Source Software and Package Managers](https://joerg-pfruender.github.io/software/2023/04/08/softwarepackages.html)
* [Easily switch between java versions with SDKMAN! and 'j'](https://joerg-pfruender.github.io/software/java/2022/12/30/sdkman_j.html)


*Any comments or suggestions? Leave an issue or a pull request!*