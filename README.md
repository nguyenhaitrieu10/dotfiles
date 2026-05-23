Bootstrap on a new machine

# 1. Clone the bare repo
git clone --bare git@github.com:nguyenhaitrieu10/dotfiles.git $HOME/.dotfiles
alias gitdot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# 2. Back up any conflicting files (fresh installs usually have a default .bashrc)
mkdir -p $HOME/.dotfiles-backup
gitdot checkout 2>&1 | grep -E "^\s+\." | awk '{print $1}' \
  | xargs -I{} mv {} $HOME/.dotfiles-backup/{} 2>/dev/null || true

# 3. Check out into $HOME and hide untracked files
gitdot checkout
gitdot config --local status.showUntrackedFiles no

