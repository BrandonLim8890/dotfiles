# tmux config

## Plugins

Plugins are managed by [tpm](https://github.com/tmux-plugins/tpm) and are not
tracked in this repo. After stowing this config on a new machine, install them:

**1. Install tpm**

The `tmux.conf` here expects tpm at the Homebrew path:

```bash
brew install tpm
```

> If you prefer the manual install instead:
> ```bash
> git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
> ```
> Then update the last line of `tmux.conf` to:
> `run '~/.config/tmux/plugins/tpm/tpm'`

**2. Install plugins**

Start a tmux session, then press `prefix + I` (capital i) to fetch and install
all plugins listed in `tmux.conf`.

## Plugins in use

| Plugin | Purpose |
|--------|---------|
| `tmux-plugins/tpm` | Plugin manager |
| `tmux-plugins/tmux-sensible` | Sensible default settings |
| `christoomey/vim-tmux-navigator` | Seamless nvim/tmux pane navigation with `C-h/j/k/l` |
| `arcticicestudio/nord-tmux` | Nord colorscheme |
| `tmux-plugins/tmux-yank` | Copy to system clipboard in copy mode |

## Key bindings (custom)

| Key | Action |
|-----|--------|
| `C-a` | Prefix (replaces default `C-b`) |
| `prefix + v` | Split vertical |
| `prefix + h` | Split horizontal |
| `prefix + q` | Kill pane |
| `prefix + b` | Break pane into new window |
| `prefix + r` | Reload tmux.conf |
| `C-M-h/j/k/l` | Resize pane |
| `prefix + m` | Zoom/unzoom pane |
| `M-H / M-L` | Previous/next window |
| `prefix + C-f` | tmux-sessionizer |
