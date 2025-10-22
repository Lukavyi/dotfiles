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
      description: 'Package manager and packages (Work: basic tools only, Personal: includes AI tools)',
      script: './brew/install.sh',
      details: [
        'Install Homebrew package manager if not present',
        'Work: Install ~49 CLI tools from Brewfile.basic',
        'Linux: Also install Linux-specific packages (glibc, strace)',
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
        'Oh My Zsh framework with plugins (Personal: includes git auto-fetch, AI aliases)',
      script: './zsh/install.sh',
      details: [
        'Install Oh My Zsh framework',
        'Install plugins: zsh-syntax-highlighting, zsh-autosuggestions',
        'Create ~/.zshrc.local for machine-specific settings',
        'Create ~/.zprofile.local for machine-specific login settings',
        'Create ~/.zshenv.local for machine-specific environment settings',
        'Note: Config files are linked by stow (see "Link configurations" item)',
      ],
    },
    {
      id: 'p10k',
      name: 'Powerlevel10k theme',
      description:
        'Fast, flexible, and beautiful Zsh theme with icons and git status',
      script: './p10k/install.sh',
      details: [
        'Clone Powerlevel10k theme to ~/.oh-my-zsh/custom/themes/',
        'Enables git status, icons, and command execution time in prompt',
        'Note: .p10k.zsh config is linked by stow (see "Link configurations" item)',
      ],
    },
    {
      id: 'tmux',
      name: 'Tmux with TPM',
      description: 'Terminal multiplexer with plugin manager',
      script: './tmux/install.sh',
      details: [
        'Install Tmux Plugin Manager (TPM)',
        'Install/update plugins: tmux-sensible, tmux-resurrect, tmux-continuum',
        'Note: .tmux.conf is linked by stow (see "Link configurations" item)',
        'Plugins provide session persistence and sensible defaults',
      ],
    },
  ],
  Configurations: [
    {
      id: 'stow_configs',
      name: 'Link configurations (stow)',
      description:
        'Create symlinks for dotfiles (Personal: includes .zshrc.personal with API keys)',
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
        'Generate ~/.gitconfig.local from pass password manager',
        'Retrieves git user.name and user.email from pass',
        'Retrieves SSH signing key from pass (if available)',
        'Note: .gitconfig is linked by stow (see "Link configurations" item)',
        'Requires pass (password-store) to be configured',
      ],
    },
    {
      id: 'claude_config',
      name: 'Claude configuration',
      description: 'Install Claude Code CLI and configuration files',
      script: './claude/install.sh',
      profile: 'personal', // Only in personal profiles - contains API keys
      details: [
        'Copy settings.json to ~/.claude/ with environment variable expansion',
        'Copy .mcp.json to ~/.claude/ with API key substitution',
        'Configure MCP servers: playwright, chrome-devtools, zen',
        'Shell aliases: use "claudem" with MCPs, "claude" without',
        'Note: opencode, claude-squad commands installed via Brewfile.personal',
        'Requires OPENROUTER_API_KEY and OPENAI_API_KEY environment variables',
      ],
    },
    {
      id: 'claude_code_router',
      name: 'Claude Code Router',
      description: 'Multi-provider routing for Claude Code (OpenRouter, Anthropic, etc.)',
      script: './claude-code-router/install.sh',
      profile: 'personal', // Only in personal profiles - contains API keys
      details: [
        'Install @musistudio/claude-code-router npm package',
        'Copy config.json to ~/.claude-code-router/ with API key substitution',
        'Configure providers: OpenRouter (1M context), Anthropic',
        'Default model: anthropic/claude-sonnet-4-5-20250929:extended',
        'Shell aliases: use "ccr" without MCPs, "ccrm" with MCPs',
        'Dynamic model switching with /model command',
        'Requires OPENROUTER_API_KEY and optionally ANTHROPIC_API_KEY',
      ],
    },
    {
      id: 'chunkhound',
      name: 'Chunkhound',
      description: 'AI-powered code search and indexing with MCP server support',
      script: './chunkhound/install.sh',
      profile: 'personal', // Only in personal profiles - AI coding tool
      details: [
        'Install chunkhound via uv tool install',
        'Semantic code search across 22+ programming languages',
        'Integrates with Claude Code as MCP server',
        'Index projects: chunkhound index /path/to/project',
        'Configure per-project by adding .mcp.json with chunkhound server',
        'Supports multiple embedding providers (VoyageAI, OpenAI, Ollama)',
        'Requires uv (installed via Homebrew)',
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
        'AI coding tools and package managers',
      script: './npm/install.sh',
      profile: 'personal', // Only in personal profiles - contains AI coding tools
      details: [
        'Install from npm/package.json',
        'AI Tools: @anthropic-ai/claude-code, @musistudio/claude-code-router',
        'Additional: @just-every/code, @openai/codex, happy-coder',
        'Usage tracking: ccusage',
        'Package managers: corepack, yarn',
      ],
    },
    {
      id: 'nvchad',
      name: 'NvChad configuration',
      description: 'Neovim configuration with IDE-like features and plugins',
      script: './nvchad-custom/install.sh',
      details: [
        'Clone NvChad starter configuration',
        'Copy custom configurations to ~/.config/nvim/lua/',
        'Files: chadrc.lua, mappings.lua, options.lua, conform.lua, plugins/init.lua',
        'Configure plugins: telescope, treesitter, mason, etc.',
        'Set up IDE features: autocomplete, formatting, LSP support',
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
        'Update Brewfile.basic, Brewfile.personal, Brewfile.macos, and Brewfile.linux',
        'Include: formulae, casks, taps, and Mac App Store apps',
        'Smart deduplication between all Brewfiles',
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
