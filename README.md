# Setup Automation and Documentation

[![GitHub](https://img.shields.io/badge/GitHub-Sponsor%20Josh%20XT-blue?logo=github&style=plastic)](https://github.com/sponsors/Josh-XT) [![PayPal](https://img.shields.io/badge/PayPal-Sponsor%20Josh%20XT-blue.svg?logo=paypal&style=plastic)](https://paypal.me/joshxt) [![Ko-Fi](https://img.shields.io/badge/Kofi-Sponsor%20Josh%20XT-blue.svg?logo=kofi&style=plastic)](https://ko-fi.com/joshxt)

I created this repository to keep my own development setup documented so that I can stand up a new development environment easily if I ever need to.  The scripts below install and update everything I need for development and daily use after a fresh OS install of either `Ubuntu`, `Pop!_OS`, or `Windows 11`. I have also documented my hardware setup and Visual Studio Code settings and extensions below.

My recommendation is to fork this repository and modify the scripts to fit your own needs and so that you can document your own setup for yourself.

_The scripts below will require modification unless you want my exact setup, which should only be the case if you are me._

## Table of Contents 📖

- [Setup Automation and Documentation](#setup-automation-and-documentation)
  - [Table of Contents 📖](#table-of-contents-)
  - [Servers](#servers)
    - [Ubuntu Server Setup](#ubuntu-server-setup)
    - [AGiXT VM Setup](#agixt-vm-setup)
  - [Workstations](#workstations)
  - [Ubuntu Workstation Setup](#ubuntu-workstation-setup)
  - [Windows Workstation Setup](#windows-workstation-setup)
  - [VSCode Setup](#vscode-setup)
    - [Settings](#settings)
    - [Extensions](#extensions)
  - [My Workstation Hardware](#my-workstation-hardware)
    - [Mouse Bindings for `Logitech G502`](#mouse-bindings-for-logitech-g502)

## Servers

### Ubuntu Server Setup

The `ServerSetup.sh` is similar to the `WorkstationSetup.sh` script, but is geared towards installing the essentials that I need for a new [Ubuntu Server](https://ubuntu.com/download/server) virtual machine on any given project that I am working on.  This includes `Docker`, `NodeJS`, `Yarn`, `PowerShell`, `Python`, `.NET Runtimes` and all updates from `apt` and `snap`.  It also sets the timezone on the server to `America/New_York`.

```bash
sudo apt update
sudo apt install -y git
git clone https://github.com/Josh-XT/Setup
./Setup/ServerSetup.sh
```

### AGiXT VM Setup

The `AGiXTSetup.sh` script is used to set up a VM for AGiXT development on a fresh Linux install. It installs all necessary packages for the operating system, installed AGiXT, then runs AGiXT. This makes setting up a new VM for AGiXT development a breeze.

```bash
sudo apt update
sudo apt install -y git
git clone https://github.com/Josh-XT/Setup
./Setup/AGiXTSetup.sh
```

## Workstations

## Ubuntu Workstation Setup

The `WorkstationSetup.sh` script handles all of my application installs and git configurations on a workstation so that I can stand up a new development environment for myself in minutes without missing any of my critical software or configurations.  `WorkstationSetup.sh` was created to work on any `Ubuntu` based distrobution, such as `Pop!_OS`, `Mint`, etc.

Open terminal and copy/paste the following:

```bash
sudo apt update
sudo apt install -y git
git clone https://github.com/Josh-XT/Setup
```

_**Note: WorkstationSetup.sh should be modified before running it so that you can enter your own details in the git config and add or remove any apt packages you might want or not want.  This script is specifically set up for me to use after a fresh image.**_

```bash
./Setup/WorkstationSetup.sh
```

For more information, check out the [AGiXT](https://github.com/Josh-XT/AGiXT) repository.

## Windows Workstation Setup

After a fresh Windows 11 install, open the Windows Store, get all updates, then run windows updates until caught up, then reboot.  After that, open PowerShell as an administrator and run the following commands:

```bash
winget install -e --id Microsoft.VisualStudioCode
winget install -e --id Git.Git
winget install -e --id Microsoft.PowerShell
winget install -e --id Python.Python.3.10
winget install -e --id Google.AndroidStudio
winget install -e --id OpenJS.NodeJS.LTS
winget install -e --id Oracle.JDK.19
winget install -e --id Oracle.JavaRuntimeEnvironment
winget install -e --id Microsoft.DotNet.SDK.Preview
winget install -e --id Docker.DockerDesktop
winget install -e --id Microsoft.PowerToys
winget install -e --id Valve.Steam
winget install -e --id Discord.Discord
winget install -e --id Zoom.Zoom
winget install -e --id OpenWhisperSystems.Signal
winget install -e --id Google.Chrome
winget install -e --id Brave.Brave
winget install -e --id Spotify.Spotify
winget install -e --id SlackTechnologies.Slack
```

Once the above commands are run, open `Visual Studio Code` and sign in with your GitHub account to sync settings and extensions.

## VSCode Setup

I have settings sync enabled and sync with my GitHub account, but I've found it very helpful to other to have a list of the settings and extensions that I use.

### Settings

Some settings I'd highly recommend setting up the auto save on focus change as well as the auto format on save.  Set Python Black as your default formatter for python.  Click on the settings gear in the bottom left of VSCode, then `Settings`.  You'll be able to search for the settings below and change them there.

| Setting                       | Value             |
|-------------------------------|-------------------|
| `Files: Auto Save`            | `onFocusChange`   |
| `Formatting: Provider`        | `black`           |
| `Formatting: Black Path`      | `black`           |
| `Editor: Format on Save`      | `Checked`         |
| `Editor: Format On Save Mode` | `file`            |

### Extensions

To install the same VSCode extensions that I use, run the `CodeExtensions.sh` script in the `Setup` directory.

```bash
git clone https://github.com/Josh-XT/Setup
./Setup/CodeExtensions.sh
```

## My Workstation Hardware

| Item  | Desktop | Laptop |
|-------------------|-------------------|-------------------|
| **Model**             | Custom Built | [Alienware x17 R2](https://www.microcenter.com/product/647646/dell-alienware-x17-r2-173-gaming-laptop-computer-white) |
| **CPU**               | [Intel Core i9-12900KS](https://ark.intel.com/content/www/us/en/ark/products/225916/intel-core-i912900ks-processor-30m-cache-up-to-5-50-ghz.html)   | Intel Core i9-12900HK |
| **GPU**               | [NVIDIA GeForce RTX 4090 24GB](https://www.asus.com/us/motherboards-components/graphics-cards/tuf-gaming/tuf-rtx4090-o24g-gaming/) | NVIDIA GeForce RTX 3080 Ti 16GB |
| **RAM**               | [128GB DDR5-5200](https://www.gskill.com/product/165/377/1649665420/F5-5200J3636D32GX2-RS5W-F5-5200J3636D32GA2-RS5W) | [64GB DDR5-5600](https://www.microcenter.com/product/661345/crucial-64gb-(2-x-32gb)-ddr5-5600-pc5-44800-cl46-dual-channel-laptop-memory-kit-ct2k32g56c46s5-black) |
| **Storage**           | 2TB M2 | 2TB M2 |
| **Mouse**             | [Logitech G502](https://www.logitechg.com/en-us/products/gaming-mice/g502-hero-gaming-mouse.910-005469.html) | -- |
| **Keyboard**          | [Logitech K350](https://www.logitech.com/en-us/products/keyboards/k350-wave-ergonomic.920-001996.html) | -- |
| **Monitor**           | 65in Samsung 4k TV | 17.3" 1080p |

### Mouse Bindings for `Logitech G502`

In Linux, I use `Piper` to configure my mouse.  I have the following bindings set up for my mouse:

| Button | Binding | Action |
|--------|--------|------|
| G4 | Backward | `Backward` button in the web browser. |
| G5 | Forward | `Forward` button in the web browser. |
| G6/Target | CTRL + T | Open a new web browser tab. |
| G7 | CTRL + SUPER + DOWNARROW | Navigate to the workspace down from the current one. |
| G8 | CTRL + SUPER + UPARROW | Navigate to the workspace up from the current one. |
| G9 | SUPER + B | Open a new web browser window. |
