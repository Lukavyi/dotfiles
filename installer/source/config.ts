export interface InstallItem {
  id: string;
  name: string;
  description: string;
  script: string; // Path to the installation script
  profile?: 'work' | 'personal' | 'all'; // Profile restriction
  details: string[]; // Detailed list of actions this item will perform
}

export interface Categories {
  [category: string]: InstallItem[];
}

export const categories: Categories = {
  Core: [
    {
      id: 'homebrew',
      name: 'Homebrew & packages',
      description: 'Package manager and all packages defined in Brewfile',
      script: './brew/install.sh',
      details: [
        'Install Homebrew package manager if not present',
        'Work: Install ~40 CLI tools from Brewfile.basic',
        'Personal: Also install personal CLI tools (claude-squad, pass, opencode)',
        'Personal macOS: Additionally install GUI apps and Mac App Store items',
        'Tools: git, neovim, tmux, fzf, ripgrep, bat, eza, lazygit',
      ],
    },
  ],
  'Terminal & Shell': [
    {
      id: 'zsh',
      name: 'Zsh with Oh My Zsh',
      description:
        'Oh My Zsh framework with plugins (syntax highlighting, autosuggestions)',
      script: './zsh/install.sh',
      details: [
        'Install Oh My Zsh framework',
        'Install plugins: zsh-syntax-highlighting, zsh-autosuggestions',
        'Link: ~/.zshrc → zsh/.zshrc (16KB config)',
        'Link: ~/.zshenv → zsh/.zshenv',
        'Link: ~/.zprofile → zsh/.zprofile',
        'Create ~/.zshrc.local for machine-specific settings',
      ],
    },
    {
      id: 'p10k',
      name: 'Powerlevel10k theme',
      description:
        'Fast, flexible, and beautiful Zsh theme with icons and git status',
      script: './p10k/install.sh',
      details: [
        'Clone Powerlevel10k theme to ~/.oh-my-zsh/themes/',
        'Link: ~/.p10k.zsh → p10k/.p10k.zsh (100KB config)',
        'Enables git status, icons, and command execution time in prompt',
      ],
    },
    {
      id: 'tmux',
      name: 'Tmux with TPM',
      description: 'Terminal multiplexer with plugin manager',
      script: './tmux/install.sh',
      details: [
        'Install Tmux Plugin Manager (TPM)',
        'Link: ~/.tmux.conf → tmux/.tmux.conf (1.8KB config)',
        'Plugins: tmux-sensible, tmux-resurrect, tmux-continuum',
        'Custom keybindings and theme configuration',
      ],
    },
  ],
  Configurations: [
    {
      id: 'stow_configs',
      name: 'Link configurations (stow)',
      description:
        'Create symlinks for all dotfiles using GNU Stow (zsh, git, tmux, etc.)',
      script: './config/install.sh',
      profile: 'all', // Available for all profiles
      details: [
        'Link: ~/.config/bat → config/.config/bat (syntax highlighting)',
        'Link: ~/.config/yazi → config/.config/yazi (file manager)',
        'Work profile: Standard dev tool configs only',
        'Personal profiles: Also links ~/.zshrc.full with:',
        '  - API keys (OpenAI, OpenRouter)',
        '  - Personal aliases (claude, opencode, claude-squad)',
        '  - 1Password SSH agent configuration',
      ],
    },
    {
      id: 'git_config',
      name: 'Git configuration',
      description: 'Set up git user, email, and signing key configuration',
      script: './git/install.sh',
      profile: 'personal', // Only in personal profiles - contains personal git credentials
      details: [
        'Link: ~/.gitconfig → git/.gitconfig',
        'Configure git user.name and user.email',
        'Set up SSH signing key for commits',
        'Configure git aliases and diff tools',
        'Platform-specific settings (macOS/Linux)',
      ],
    },
    {
      id: 'claude_config',
      name: 'Claude configuration',
      description: 'Install Claude Code CLI and configuration files',
      script: './claude/install.sh',
      profile: 'personal', // Only in personal profiles - contains API keys
      details: [
        'Link: ~/.claude → claude/',
        'Configure MCP servers and tools',
        'Set up API keys for Claude Code CLI',
        'Install claude, opencode, claude-squad commands',
      ],
    },
  ],
  Development: [
    {
      id: 'nvm_node',
      name: 'NVM & Node.js',
      description:
        'Node Version Manager and latest LTS Node.js for JavaScript development',
      script: './nvm/install.sh',
      details: [
        'Install NVM (Node Version Manager)',
        'Install latest LTS version of Node.js',
        'Configure shell integration for nvm command',
        'Set default Node.js version',
      ],
    },
    {
      id: 'go_tools',
      name: 'Go-based tools',
      description: 'Install Go-based development tools (lazynpm)',
      script: './go-tools/install.sh',
      details: [
        'Install lazynpm via go install',
        'Terminal UI for npm package management',
        'Requires Go (installed via Homebrew)',
        'Installs to $GOPATH/bin (~/go/bin by default)',
        'Accessible via "lnpm" alias in .zshrc',
      ],
    },
    {
      id: 'npm_packages',
      name: 'Global npm packages',
      description:
        'Essential npm packages (typescript, prettier, eslint, etc.)',
      script: './npm/install.sh',
      details: [
        'Install from npm/package.json',
        'Packages: typescript, prettier, eslint',
        'Tools: npm-check-updates, serve, lite-server',
        'Utilities: trash-cli, gtop, speed-test',
      ],
    },
    {
      id: 'nvchad',
      name: 'NvChad configuration',
      description: 'Neovim configuration with IDE-like features and plugins',
      script: './nvchad-custom/install.sh',
      details: [
        'Clone NvChad base configuration',
        'Link: ~/.config/nvim/lua/custom → nvchad-custom/',
        'Install LSP servers for multiple languages',
        'Configure plugins: telescope, treesitter, mason, etc.',
        'Set up IDE features: autocomplete, formatting, debugging',
      ],
    },
  ],
  Backup: [
    {
      id: 'backup_homebrew',
      name: 'Backup Homebrew packages',
      description: 'Save current Homebrew packages to Brewfile',
      script: './brew/backup.sh',
      profile: 'all', // Available in both profiles
      details: [
        'Export installed Homebrew packages',
        'Update Brewfile.basic, Brewfile.personal, and Brewfile.macos',
        'Include: formulae, casks, taps, and Mac App Store apps',
        'Smart deduplication between basic and full profiles',
      ],
    },
    {
      id: 'backup_macos_apps',
      name: 'Backup macOS apps inventory',
      description: 'Scan and save installed macOS applications',
      script: './apps/check_apps.sh',
      profile: 'all', // Available in both profiles
      details: [
        'Scan /Applications folder',
        'Update apps/apps.yml with current inventory',
        'Categorize by source: brew, appstore, or manual',
        'Track version numbers and installation status',
      ],
    },
  ],
};

export const defaultSelections: string[] = [
  'homebrew',
  'zsh',
  'p10k',
  'stow_configs',
  'nvm_node',
  'tmux',
];
