export interface InstallItem {
  id: string;
  name: string;
  description: string;
  script: string; // Path to the installation script
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
    },
  ],
  'Terminal & Shell': [
    {
      id: 'zsh',
      name: 'Zsh with Oh My Zsh',
      description:
        'Oh My Zsh framework with plugins (syntax highlighting, autosuggestions)',
      script: './zsh/install.sh',
    },
    {
      id: 'p10k',
      name: 'Powerlevel10k theme',
      description:
        'Fast, flexible, and beautiful Zsh theme with icons and git status',
      script: './p10k/install.sh',
    },
    {
      id: 'tmux',
      name: 'Tmux with TPM',
      description: 'Terminal multiplexer with plugin manager',
      script: './tmux/install.sh',
    },
  ],
  Configurations: [
    {
      id: 'stow_configs',
      name: 'Link configurations (stow)',
      description:
        'Create symlinks for all dotfiles using GNU Stow (zsh, git, tmux, etc.)',
      script: './config/install.sh',
    },
    {
      id: 'git_config',
      name: 'Git configuration',
      description: 'Set up git user, email, and signing key configuration',
      script: './git/install.sh',
    },
    {
      id: 'claude_config',
      name: 'Claude configuration',
      description: 'Install Claude Code CLI and configuration files',
      script: './claude/install.sh',
    },
  ],
  Development: [
    {
      id: 'nvm_node',
      name: 'NVM & Node.js',
      description:
        'Node Version Manager and latest LTS Node.js for JavaScript development',
      script: './nvm/install.sh',
    },
    {
      id: 'npm_packages',
      name: 'Global npm packages',
      description:
        'Essential npm packages (typescript, prettier, eslint, etc.)',
      script: './npm/install.sh',
    },
    {
      id: 'nvchad',
      name: 'NvChad configuration',
      description: 'Neovim configuration with IDE-like features and plugins',
      script: './nvchad-custom/install.sh',
    },
  ],
  'macOS Only': [
    {
      id: 'macos_apps',
      name: 'Check macOS applications',
      description: 'Scan and inventory installed macOS applications',
      script: './apps/check_apps.sh',
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
  'git_config',
];
