# dotfiles

Personal config files for nvim, tmux, ghostty, and zsh — managed with [GNU Stow](https://www.gnu.org/software/stow/).

## What's included

- **nvim** — Neovim config with lazy.nvim, treesitter, and LSP
- **tmux** — Nord theme via `nord-tmux`, TPM plugins, vim-tmux-navigator
- **ghostty** — Terminal config with custom smear shader
- **zsh** — oh-my-zsh with fzf-tab, zsh-syntax-highlighting, and zsh-autosuggestions

## Fresh machine setup

### 1. Clone and stow

```bash
git clone https://github.com/BrandonLim8890/dotfiles.git ~/dotfiles
cd ~/dotfiles
# Remove any conflicting files first
mv ~/.zshrc ~/.zshrc.bak
mv ~/.zprofile ~/.zprofile.bak
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.config/tmux ~/.config/tmux.bak
mv ~/.config/ghostty ~/.config/ghostty.bak
# Symlink everything
stow --target=$HOME .
```

### 2. Zsh plugins

```bash
# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  ~/.oh-my-zsh/plugins/zsh-syntax-highlighting

# fzf-tab
git clone https://github.com/Aloxaf/fzf-tab \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab

source ~/.zshrc
```

### 3. Tmux plugins

```bash
# Install TPM
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Then start tmux and press `Ctrl+a + I` to install all plugins.

### 4. Neovim

Open `nvim` and let lazy.nvim sync all plugins automatically. Once done, install treesitter parsers:

```
:TSUpdate
```

Also install the tree-sitter CLI if you get build errors:

```bash
brew install tree-sitter-cli
```

### 5. Ghostty shaders

The smear shader is included in `.config/ghostty/shaders/`. If it doesn't load, make sure the path in your ghostty config points to the real file:

```
custom-shader = /Users/<you>/dotfiles/.config/ghostty/shaders/smear.glsl
custom-shader-animation = always
```

## Notes

- Tmux prefix is `Ctrl+a`
- Pane navigation: `Ctrl+h/j/k/l` (via vim-tmux-navigator)
