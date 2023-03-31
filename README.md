# My PC Setup

I created this repository to keep my own development setup documented so that I can stand up a new development environment easily if I ever need to.  The scripts below install and update everything I need for development and daily use after a fresh OS install of either ``Ubuntu``, ``Pop!_OS``, ``Debian``, or ``Windows 10/11``.

_The scripts below will require modification unless you want my exact setup, which should only be the case if you are me._

## Operating Systems

**Primary Operating System:** [Ubuntu 22.04](https://ubuntu.com/) with [Pop Shell](https://support.system76.com/articles/pop-shell/)

**Virtual Machine:** [Windows 10](https://www.microsoft.com/en-us/software-download/windows10ISO)

## Hardware

**Primary Workstation (Desktop)** - Intel Core i9-12900KS, 128GB DDR5-6000, 2TB M2, NVIDIA RTX 4090 24GB

**Secondary Workstation (Laptop)** - Upgraded HP X360, AMD Ryzen 7 4700U, 32GB DDR4-3200, 512GB M2

**Mouse** - Logitech G502 ([Button Bindings Below](https://github.com/Josh-XT/Setup#mouse-bindings-with-piper-for-logitech-g502))

**Keyboard** - Logitech K350

**Headset** - SteelSeries Arctis 7+

## Workstation Setup

The ``WorkstationSetup.sh`` script handles all of my application installs and git configurations on a workstation so that I can stand up a new development environment for myself in minutes without missing any of my critical software or configurations.  ``WorkstationSetup.sh`` was created to work on any ``Debian`` based distrobution, such as ``Ubuntu``, ``Pop!_OS``, ``Mint``, etc.

Open terminal and copy/paste the following:

```
sudo apt install -y git
git clone https://github.com/Josh-XT/Setup.git
cd Setup
sudo chmod 755 ./WorkstationSetup.sh
```

_**Note: WorkstationSetup.sh should be modified before running it so that you can enter your own details in the git config and add or remove any apt packages you might want or not want.  This script is specifically set up for me to use after a fresh image.**_

```
sudo ./WorkstationSetup.sh
```

## Ubuntu Server Setup

The ``ServerSetup.sh`` is similar to the ``WorkstationSetup.sh`` script, but is geared towards installing the essentials that I need for a new ``Ubuntu Server`` virtual machine on any given project that I am working on.  This includes ``Docker``, ``NodeJS``, ``Yarn``, ``PowerShell``, ``Python``, ``.NET Runtimes`` and all updates from ``apt`` and ``snap``.  It also sets the timezone on the server to ``America/New_York``.

```
sudo apt install -y git
git clone https://github.com/Josh-XT/Setup.git
cd Setup
sudo chmod 755 ./ServerSetup.sh
sudo ./ServerSetup.sh
```

## Windows 10 and WinSetup.ps1 Script

I have a Windows 10 VM just in case I ever need it, but it is honestly pretty rare for me to use it.  The WinSetup.ps1 script sets up a Windows 10/11 machine to be a development machine for me as if it were my desktop environment, because it used to be before I switched back to Linux.

Use Boxes (Gnome Virtual Machine software) to create a new Windows 10 VM with 16GB RAM and 150GB storage.

The ``WinSetup.ps1`` script downloads and installs packages from Chocolatey, then the script creates a scheduled task to ensure those packages are always installed and up to date daily.  Packages can be found on [Chocolatey's website](https://chocolatey.org).

The package list used by the script can be modified any time, it is located at ``C:\ProgramData\Automation\packages.csv``.

Running the script may take some time, it downloads and installs some larger software packages such as Visual Studio 2022.

Open PowerShell as Administrator and run the following:

```
Set-ExecutionPolicy Bypass
.\WinSetup.ps1
```

## Mouse Bindings with ``Piper`` for ``Logitech G502``

``G4`` bound to ``Backward`` button in the web browser.

``G5`` bound to ``Forward`` button in the web browser.

``G6/Target`` (thumb button) bound to ``CTRL + T`` to open a new web browser tab.

``G7`` bound to ``CTRL + SUPER + DOWNARROW`` to navigate to the workspace down from the current one.

``G8`` bound to ``CTRL + SUPER + UPARROW`` to navigate to the workspace up from the curren one.

``G9`` bound to ``SUPER + B`` to open a new web browser window.

## Why Pop!_OS or Linux in general?

[Ubuntu](https://ubuntu.com/) and [Pop!_OS](https://pop.system76.com/) are my primary operating systems for several reasons, I'll talk about some of those below.

**Auto Tiling and Multiple Workspace Workflows**

The main reason I went to ``Pop!_OS`` (or ``Pop Shell`` in ``Ubuntu``) is the auto tiling feature.  The amount of time that I save in not having to move windows around and resize them is crazy.  I would encourage you to [go to their website](https://pop.system76.com/) and watch some of the short videos of the auto tiling in action.

I found that multiple workspaces and binding unused mouse buttons to switching workspaces makes staying focused on a task easy, but switching to another one without losing your place even easier.  I multi-task a lot where I am working on multiple issues/projects at a time, putting anything related to whatever I am working on in one workspace separate from all of the other things I am working on keeps me extremely organized and with ``Pop!_OS`` auto tiling in each of those workspaces, I never lose a window related to what I am working on and I don't get pieces of tasks mixed up while multi-tasking due to the multiple desktops and auto tiling.  Auto tiling also encourages me to close windows when I am done with them so that they're not taking up space, further keeping me organized.

**Much faster**

Linux utilizes so little resources for todays hardware which makes for a mostly delay-free desktop experience.  Fast paced workloads call for fast paced operating systems.

**Everything is Available (And Usually Free)**

As a penny pinching developer still trying to make my way in the world, tools being free and available to me is important.  What is even more important is that many of those tools are open source, so if I ever want to really know what makes them tick or change how they behave, I can do those things.

**Less Ridiculous Requirements**

With Windows 11 requiring TPM and a Microsoft account now, it feels good to skip the ridiculous requirements and have an operating system that I can put on any of my devices.

**Improved Security & Privacy**

This should speak for itself if you know much about Linux vs Windows in general.  There are many great articles that go far in depth about this topic and how to best secure your OS, I'll leave it to those experts to explain this particular topic.