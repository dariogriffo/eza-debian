![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/dariogriffo/eza-debian/total)
![GitHub Downloads (all assets, latest release)](https://img.shields.io/github/downloads/dariogriffo/eza-debian/latest/total)
![GitHub Release](https://img.shields.io/github/v/release/dariogriffo/eza-debian)
![GitHub Release Date](https://img.shields.io/github/release-date/dariogriffo/eza-debian)

<h1>
   <p align="center">
     <a href="https://eza.rocks/"><img src="https://github.com/dariogriffo/eza-debian/blob/main/eza-logo.png" alt="eza Logo" width="128" style="margin-right: 20px"></a>
     <a href="https://www.debian.org/"><img src="https://github.com/dariogriffo/eza-debian/blob/main/debian-logo.png" alt="Debian Logo" width="104" style="margin-left: 20px"></a>
     <br>eza for Debian
   </p>
</h1>
<p align="center">
 eza is a modern replacement for ls.
</p>

# eza for Debian

This repository contains build scripts to produce the _unofficial_ Debian packages
(.deb) for [eza](https://github.com/eza-community/eza/) hosted at [deb.griffo.io](https://deb.griffo.io)

<p align="center">
⭐⭐⭐ Love using eza on Debian? Show your support by starring this repo or [subscribing](https://buy.stripe.com/aFa28q8hr0lRdlm4a2enS01) — from 1 October 2026, apt access requires a yearly subscription. ⭐⭐⭐
</p>

Currently supported debian distros are:
- Bookworm
- Trixie
- Forky
- Sid

This is an unofficial community project to provide a package that's easy to
install on Debian. If you're looking for the eza source code, see
[eza](https://github.com/eza-community/eza/).

## Install/Update

📖 **Step-by-step install guide:** [Debian](https://deb.griffo.io/install-latest-eza-in-debian.html) · [Ubuntu](https://deb.griffo.io/install-latest-eza-in-ubuntu.html)

### The Debian way

> ⚠️ **From 1 October 2026, apt access requires a yearly subscription**
> ([deb.griffo.io](https://deb.griffo.io)). To use this tool for free, download
> the .deb from the [Releases](https://github.com/dariogriffo/eza-debian/releases) page
> and install it manually (see below).

```sh
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://deb.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc | sudo gpg --dearmor --yes -o /etc/apt/keyrings/deb.griffo.io.gpg
echo "deb [signed-by=/etc/apt/keyrings/deb.griffo.io.gpg] https://deb.griffo.io/apt $(lsb_release -sc 2>/dev/null) main" | sudo tee /etc/apt/sources.list.d/deb.griffo.io.list
sudo apt update
sudo apt install -y eza
```

### Manual Installation

1. Download the .deb package for your Debian version available on
   the [Releases](https://github.com/dariogriffo/eza-debian/releases) page.
2. Install the downloaded .deb package.

```sh
sudo dpkg -i <filename>.deb
```
## Updating

To update to a new version, just follow any of the installation methods above. There's no need to uninstall the old version; it will be updated correctly.

## Disclaimer

- This repo is not open for issues related to eza. This repo is only for _unofficial_ Debian packaging.
