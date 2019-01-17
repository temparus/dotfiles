# Dotfiles

Clone the dotfiles repository into the home directory of your user.

To prevent having the whole home directory in a git repository, you should do:

1. Rename the `.git` directory to `.dots.git`.
2. Add `alias dots='git --git-dir=$HOME/.dots.git/ --work-tree=$HOME'` to your `.bashrc` / `.zshrc` file.
