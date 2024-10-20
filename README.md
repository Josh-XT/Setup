# Setup Automation and Documentation

[![GitHub](https://img.shields.io/badge/GitHub-Sponsor%20Josh%20XT-blue?logo=github&style=plastic)](https://github.com/sponsors/Josh-XT) [![PayPal](https://img.shields.io/badge/PayPal-Sponsor%20Josh%20XT-blue.svg?logo=paypal&style=plastic)](https://paypal.me/joshxt) [![Ko-Fi](https://img.shields.io/badge/Kofi-Sponsor%20Josh%20XT-blue.svg?logo=kofi&style=plastic)](https://ko-fi.com/joshxt)

I created this repository to keep my own development setup documented so that I can stand up a new development environment easily if I ever need to.  The scripts below install and update everything I need for development and daily use after a fresh OS install of `Ubuntu 24.04` server or desktop. I have also documented my hardware setup and Visual Studio Code settings and extensions below.

My recommendation is to fork this repository and modify the scripts to fit your own needs and so that you can document your own setup for yourself.

_The scripts below will require modification unless you want my exact setup, which should only be the case if you are me._

## Table of Contents 📖

- [Setup Automation and Documentation](#setup-automation-and-documentation)
  - [Table of Contents 📖](#table-of-contents-)
  - [Automatic Setup During Ubuntu Installation](#automatic-setup-during-ubuntu-installation)
  - [Manual Setup after Ubuntu Installation](#manual-setup-after-ubuntu-installation)
    - [Ubuntu Server Setup](#ubuntu-server-setup)
    - [Ubuntu Workstation Setup](#ubuntu-workstation-setup)
  - [VSCode Setup](#vscode-setup)
    - [Settings](#settings)
    - [Extensions](#extensions)
  - [Clone All Repositories](#clone-all-repositories)
  - [My Workstation Hardware](#my-workstation-hardware)
    - [Mouse Bindings for `Logitech G502`](#mouse-bindings-for-logitech-g502)
  - [Potentially Important Links](#potentially-important-links)
    - [Operating System Downloads](#operating-system-downloads)
    - [Software Downloads](#software-downloads)

## Automatic Setup During Ubuntu Installation

To automatically set up your environment during the Ubuntu installation process:

1. Download the `cloud-init.yaml` file from this repository.
2. When installing Ubuntu:
   - For server installations using the ISO, you can pass this file using kernel parameters at boot time. Add `autoinstall ds=nocloud-net;s=https://raw.githubusercontent.com/Josh-XT/Setup/main/` to your kernel parameters.
   - For cloud images or VMs, pass the `cloud-init.yaml` file directly to your hypervisor or cloud provider.

This will automatically:

- Install git
- Clone this repository
- Run the appropriate setup script based on whether it's a desktop or server environment
- Set up necessary bash aliases

After the installation is complete and you log in for the first time, your environment will already be set up according to the scripts in this repository.

## Manual Setup after Ubuntu Installation

### Ubuntu Server Setup

The `ServerSetup.sh` is similar to the `WorkstationSetup.sh` script, but is geared towards installing the essentials that I need for a new [Ubuntu Server](https://ubuntu.com/download/server) virtual machine on any given project that I am working on.  This includes `Docker`, `NodeJS`, `Yarn`, `PowerShell`, `Python`, `.NET Runtimes` and all updates from `apt` and `snap`.  It also sets the timezone on the server to `America/New_York`.

```bash
sudo apt update
sudo apt install -y git
git clone https://github.com/Josh-XT/Setup
sudo chmod +x Setup/*.sh
cd Setup
./UbuntuSetup.sh
```

### Ubuntu Workstation Setup

The `WorkstationSetup.sh` script handles all of my application installs and git configurations on a workstation so that I can stand up a new development environment for myself in minutes without missing any of my critical software or configurations.  `WorkstationSetup.sh` was created to work on `Ubuntu 24.04`, but may also work on other Debian-based distributions.

Open terminal and copy/paste the following:

```bash
sudo apt update
sudo apt install -y git
git clone https://github.com/Josh-XT/Setup
sudo chmod +x Setup/*.sh
```

_**Note: WorkstationSetup.sh should be modified before running it so that you can enter your own details in the git config and add or remove any apt packages you might want or not want.  This script is specifically set up for me to use after a fresh image.**_

```bash
cd Setup
./WorkstationSetup.sh
```

For more information, check out the [AGiXT](https://github.com/Josh-XT/AGiXT) repository.

## VSCode Setup

I have settings sync enabled and sync with my GitHub account, but I've found it very helpful to other to have a list of the settings and extensions that I use.

### Settings

Some settings I'd highly recommend setting up the auto save on focus change as well as the auto format on save.  Set Python Black as your default formatter for python.  Click on the settings gear in the bottom left of VSCode, then `Settings`.  You'll be able to search for the settings below and change them there.

| Setting                       | Value             |
|-------------------------------|-------------------|
| `Files: Auto Save`            | `onFocusChange`   |
| `Editor: Default Formatter`   | `Black Formatter` |
| `Editor: Format on Save`      | `Checked`         |
| `Editor: Format On Save Mode` | `file`            |
| `Notebook: Format On Save`    | `Checked`         |

### Extensions

To install the same VSCode extensions that I use, run the `CodeExtensions.sh` script in the `Setup` directory.

```bash
code --install-extension AkashGutha.qiksit-snippets
code --install-extension amazonwebservices.aws-toolkit-vscode
code --install-extension apollographql.vscode-apollo
code --install-extension AykutSarac.jsoncrack-vscode
code --install-extension christian-kohler.npm-intellisense
code --install-extension dbaeumer.vscode-eslint
code --install-extension eamodio.gitlens
code --install-extension elypia.magick-image-reader
code --install-extension esbenp.prettier-vscode
code --install-extension firefox-devtools.vscode-firefox-debug
code --install-extension gamunu.vscode-yarn
code --install-extension GitHub.codespaces
code --install-extension GitHub.copilot-chat
code --install-extension GitHub.copilot-labs
code --install-extension GitHub.copilot-nightly
code --install-extension github.vscode-github-actions
code --install-extension GrapeCity.gc-excelviewer
code --install-extension Gruntfuggly.todo-tree
code --install-extension Ionide.Ionide-fsharp
code --install-extension leo-labs.dotnet
code --install-extension mikestead.dotenv
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-dotnettools.csharp
code --install-extension ms-dotnettools.dotnet-interactive-vscode
code --install-extension ms-dotnettools.vscode-dotnet-runtime
code --install-extension ms-mssql.data-workspace-vscode
code --install-extension ms-mssql.mssql
code --install-extension ms-mssql.sql-bindings-vscode
code --install-extension ms-mssql.sql-database-projects-vscode
code --install-extension ms-python.black-formatter
code --install-extension ms-python.isort
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension ms-toolsai.jupyter
code --install-extension ms-toolsai.jupyter-keymap
code --install-extension ms-toolsai.jupyter-renderers
code --install-extension ms-toolsai.vscode-jupyter-cell-tags
code --install-extension ms-toolsai.vscode-jupyter-slideshow
code --install-extension ms-vscode-remote.remote-containers
code --install-extension ms-vscode-remote.remote-ssh
code --install-extension ms-vscode-remote.remote-ssh-edit
code --install-extension ms-vscode-remote.remote-wsl
code --install-extension ms-vscode-remote.vscode-remote-extensionpack
code --install-extension ms-vscode.azurecli
code --install-extension ms-vscode.powershell
code --install-extension ms-vscode.remote-explorer
code --install-extension ms-vscode.remote-server
code --install-extension ms-vscode.vscode-typescript-next
code --install-extension ms-vsliveshare.vsliveshare
code --install-extension quantum.quantum-devkit-vscode
code --install-extension redhat.vscode-yaml
code --install-extension ShahilKumar.docxreader
code --install-extension stylelint.vscode-stylelint
code --install-extension tomoki1207.pdf
code --install-extension wayou.vscode-todo-highlight
code --install-extension yzhang.markdown-all-in-one
code --install-extension zetta.qsharp-extensionpack
```

## Clone All Repositories

Once the workstation setup is complete, you can clone all of your GitHub repositories easily with the `GetRepos.ipynb` notebook. This will clone all GitHub repositories that you own or collaborate on sorted by organization/owner into your defined `repo_dir`.

- Open the `GetRepos.ipynb` notebook in VSCode
- Enter your [GitHub Personal Access Token](https://github.com/settings/tokens) into the `gh_token` variable
- Update the `repo_dir` with the path that you would like to clone the repositories to
- Run the notebook and wait for all of your repositories to be cloned.
- Open the `repo_dir` in VSCode to start working on your projects.

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
| G7 | SUPER + PAGEDOWN | Navigate to the workspace down from the current one. |
| G8 | SUPER + PAGEUP | Navigate to the workspace up from the current one. |
| G9 | SUPER + B | Open a new web browser window. |

## Potentially Important Links

### Operating System Downloads

- [Ubuntu Server](https://ubuntu.com/download/server)
- [Ubuntu Desktop](https://ubuntu.com/download/desktop)

### Software Downloads

- [Cuda Toolkit](https://developer.nvidia.com/cuda-downloads)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Git](https://git-scm.com/)
- [Docker](https://www.docker.com/)
