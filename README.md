# Arcolinux Customization

The scripts and config files presented here are intended solely for my personal use, but made available so that anyone stumbling across the repo should feel free to adapt them for their own personal use as well.

Scripts are intended to be executed in sequence with full reboots between executions.

[Fixes](https://github.com/bryandodd/arcolinux#fixes) are noted at the bottom.

#### Execution

You'll need to make each script executable ...
``` bash
sudo chmod +x arcomize-1.sh
```
----
Sections in this document:
* [arcomize-1.sh](https://github.com/bryandodd/arcolinux#arcomize-1sh) - Initial OS configuration and settings.
* [arcomize-2.sh](https://github.com/bryandodd/arcolinux#arcomize-2sh) - ZSH configuration and custom applications.
* [custom aliases](https://github.com/bryandodd/arcolinux#customized-aliases)

## arcomize-1.sh

There is one variable you may wish to change near the top (~line 67) of this script: `termPref`.  By default, the script will configure `kitty` as the default terminal emulator for the OS. At present, the only other supported option is `alacritty`.

The script will exit with an error if you do not run with `sudo`.

The following modules will be executed in the order listed:

* vm_install
    * `open-vm-tools` - comment out this module for bare metal installs.
* required_apps
    * `xmlstarlet` - used throughout the script to make modifications to various XML config files
* disable_power_mgmt
    * Sets Sleep-on-AC and Sleep-on-Batt to `0` then disables power management entirely. The purpose of setting the values to zero first is so that if power management is accidentally enabled later, there are no unexpected sleep events.
* switch_to_lightdm
    * SDDM is pretty and all, but meh. This will install LightDM if not already installed and activate it as the preferred login mechanism. Basic configuration settings are applied.
* xfce4_thunar_terminal
    * For XFCE's Thunar file manager, change the "Run" and "Open Terminal Here" options to use the preferred terminal emulator (see above).
* xfce4_helpers_terminal
    * Set XFCE's "default applications" option for terminal emulator to the preferred selection (see above).
* delete_variety_app
    * Get rid of Arco's "Variety" desktop wallpaper selector tool. 
* revert_network_naming
    * By default the system uses [Predictable Network Interface Names](https://systemd.io/PREDICTABLE_INTERFACE_NAMES/), but I prefer the traditional naming convention. This module will [revert to traditional interface names](https://wiki.archlinux.org/title/Network_configuration#Revert_to_traditional_interface_names)
* fetch_kitty_config
    * Fetch my preferred `kitty.conf` file from this repo and use it. 
* switch_to_zsh
    * Bash is the system default - this changes the default to ZSH.
* xfce4_panel_mod
    * Moves the panel to the top of the screen.
    * Whiskermenu button changed to icon only.
    * Repositions a few things in the panel ... adds a "directory tree" for $HOME, quick launch buttons for Sublime, Firefox, and Chrome, and a quick launch selector for a standard terminal window or root terminal window. Move the workspace selector to the left side of the panel.
    * Changes date format to my preference and includes UTC time (ex: `Sun - Sep 26 - 09:58 AM - 14:58 UTC`)
    * Adds a "Network Monitor" to the panel to show upload/download speeds on `eth0`.
    * Adds a "Generic Monitor" to the panel that runs a custom script (also found in this repo). Scripts are stored in `/home/$USER/.local/panel-scripts`. This script simply displays the IP assigned to network interfaces. Supported interface names are `wlan0`, `eth0`, and `tun0`.
* install_p10k_fonts
    * Installs the recommended fonts for the [Powerlevel10k](https://github.com/romkatv/powerlevel10k) ZSH theme via `paru`.
        * `ttf-meslo-nerd-font-powerlevel10k`
        * `awesome-terminal-fonts`
        * `powerline-fonts-git`
        * `nerd-fonts-jetbrains-mono`
    * Note that conflicts will arise. You'll have to decide how you want to handle them during script execution.


## arcomize-2.sh

The script will exit with an error if you do not run with `sudo`.

The following tools/applications will be installed in the order listed below. These are specific applications or tools that I use on a daily basis for work, so feel free to remove or add applications that are relevant or important to you.

* zsh theme - powerlevel 10k
    * Non-essential, but a very nice facelift for terminal. See [romkatv/powerlevel10k](https://github.com/romkatv/powerlevel10k) on GitHub for details. In addition to the theme itself, this script will download a pre-defined configuration file from the repo, along with my customized `.aliases` file.
* python 2 and 3
    * Yes, I know Python 2 has been deprecated, but I need it for several important things that are either not yet fully ported to Python 3 or just flat out broken on Python 3. This script will NOT alter the default `python` or `pip` commands on your install... so this means that running either of those commands without specifying a version will run version 3. You can run version 2 by using `python2` or `pip2` after this is installed.
* flameshot
    * A nice screenshot tool. See [flameshot-org/flameshot](https://github.com/flameshot-org/flameshot) on GitHub for details. This script will set the `print` key keyboard binding to launch `flameshot gui`.
* microsoft vscode
    * Microsoft's VSCode binary. This script will insert additional aliases into the `.aliases` file mentioned above. After install, typing `hosts` or `profile` from terminal will open the `/etc/hosts/` or `~/.zshrc` file (respectively) in VSCode. Script will also insert a line into the `.zshrc` file to set `KUBE_EDITOR="code --wait"` (this is specific to Kubernetes - see additional tools installed below).
* microsoft teams
    * because work.
* slack
    * also because work.
* exa
    * A modern `ls` replacement with some nice features. See [ogham/exa](https://github.com/ogham/exa) on GitHub, or [the.exa.website](https://the.exa.website/) for details. This script will alter an alias in the `.aliases` file: `ll='exa -lah --icons --group-directories-first --time-style long-iso --git'`
* bat
    * A nice `cat` replacement with syntax highlighting support. See [sharkdp/bat](https://github.com/sharkdp/bat) on GitHub for details. This script will also download a copy of my pre-configured bat config file (`/configs/bat/config`) and add two aliases to the `.aliases` file:
        * `cat='bat -P'`
        * `cat-page=bat`
* oath-toolkit
    * Very handy tool for generating OTP codes from the terminal. See the [Oath Toolkit](https://www.nongnu.org/oath-toolkit/) website or their [GitLab](https://gitlab.com/oath-toolkit/oath-toolkit) site for details. 
* aws cli v2
    * Installs the AWS CLI v2. I chose to perform this install via a sub-script rather than using the AUR repository. This script will download two additional scripts - an install/update script (`update-aws-cli.sh`), as well as a delete script (`remove-aws-cli.sh`). These will be saved to `~/.local/helper-scripts`. This script will launch the `update-aws-cli.sh` script to perform the initial install and you can come back to this script regularly to update the tools from AWS, or use the `remove-aws-cli.sh` script to remove the tools completely. See [Amazon's documentation](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html) for details.
* kubectl
    * For Kubernetes. Installed from the `community` repository. 
* kubectx
    * For Kubernetes. Installed from the `community` repository. 
* aws iam authenticator
    * For Kubernetes. Installed from the `AUR` repository. You can find out more about this tool and why it's needed by visiting [Amazon's installation instructions page](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html) or [kubernetes-sigs/aws-iam-authenticator](https://github.com/kubernetes-sigs/aws-iam-authenticator) on GitHub.
* eksctl
    * For Kubernetes. Installed from the `community` repository. 


## customized aliases
The `.aliases` file which will be copied by the script can be found in `/configs/zsh/.aliases`. 

The majority fo the aliases in this file come straight from ArcoLinux, but several have been commented out for my own preferences. As mentioned above in `arcomize-2.sh`, some of the aliases will be modified by the second script. These include:
* `ll='exa -lah --icons --group-directories-first --time-style long-iso --git'`
* `cat='bat -P'`
* `cat-page=bat`

A few additional helpers have been added to the `.aliases` file outside of those provided by ArcoLinux:
* `encode` / `decode`
    * calls a `base64encode` or `base64decode` function to make reading and writing base64 strings easier
* `encodefile`
    * accepts two parameters:
        * Param 1: an existing file on disk which you'd like to have encoded as base64
        * Param 2: an output filename to which the encoded file will be saved
* `ipinfo`
    * if called without any parameters, will return your current public IP address.
    * if provided an IP address, will look up the available information about that IP from `ipinfo.io`.
* `expandurl`
    * takes a Tiny-URL as a string and attempts to return back the ultimate destination of the URL
* `df` 
    * uses `duf` to present disk information in an easy to read format. See [muesli/duf](https://github.com/muesli/duf) on GitHub for details. 


## fixes

* 2021-10-31 : A couple of the repo-hosted config files referenced my specific username in paths. Fixed so they'll be updated to the current user correctly after download from repo.