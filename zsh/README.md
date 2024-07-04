# Install and set up zsh as default
If necessary, follow these steps to install Zsh:

1. There are two main ways to install Zsh:

    * With the package manager of your choice, e.g. `sudo apt install zsh`  
    * From source, following the instructions from the Zsh FAQ.
2. Verify installation by running `zsh --version`. Expected result: zsh 5.0.8 or more recent.

3. Make it your default shell: `chsh -s $(which zsh)` or use `sudo lchsh $USER` if you are on Fedora.

    * Note that this will not work if Zsh is not in your authorized shells list (/etc/shells) or if you don't have permission to use chsh. If that's the case you'll need to use a different procedure.
    * If you use lchsh you need to type /bin/zsh to make it your default shell.
4. Log out and log back in again to use your new default shell.

5. Test that it worked with `echo $SHELL`. Expected result: `/bin/zsh` or similar.

6. Test with `$SHELL --version`. Expected result: 'zsh 5.8' or similar

# Oh-My-Zsh Installation
## Customization dependencies
* wget or curl
* pfetch

There are two ways to do a basic install:
1. Via curl: `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`
2. Via wget: `sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`