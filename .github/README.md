# Dotfiles

Personal configuration files and setup scripts for my development environment.

## Overview

This repository contains my personal dotfiles, configuration files, and setup scripts that I use to
maintain a consistent development environment across different machines. It includes configurations
for shell environments, development tools, and various utilities.

## Features

- 🔄 Automated synchronization of configuration files
- 🐚 ZSH configuration with customized themes
- 🛠️ Development environment setup for various languages and tools
- 🔧 Preconfigured development tools
- 📊 GitHub workflows and continuous integration

## Installation

Clone the repository to your home directory:

```bash
git clone https://github.com/ss-o/dotfiles.git ~/.dotfiles
```

Run the installation script:

```bash
cd ~/.dotfiles
./install.sh
```

### Script Options

The installation script supports several options:

```bash
./install.sh [options]
```

To see available options, run:

```bash
./install.sh --help
```

###u Using Tags

The installation script supports organizing dotfiles into tagged groups, allowing selective
synchronization.

#### Tag Format in sync.config

The tags are defined in the `sync.config` file. Each tag is a line starting with a `#`, followed by
the tag name and the files associated with it.

```yaml
[files:tagname]
source_file:destination_path
another_file:another_destination
more_files:paths

[files:another_tag]
different_file:different_destination
```

The `sync.config` file is structured to allow you to define groups of files that can be synchronized
together. Each group is defined by a tag, and the files within that group are specified in the
format `source_file:destination_path`.

For example:

```yaml
# Regular files (no tag)
[files]
common_file:~/.common_file
shared_config:~/.config/shared

[files:shell]
zshrc:~/.zshrc
bashrc:~/.bashrc
shell/aliases:~/.config/shell/aliases

[files:git]
gitconfig:~/.gitconfig
gitignore:~/.gitignore

[files:vim]
vimrc:~/.vimrc
vim/plugins:~/.vim/plugins
```

#### Syncing Specific Tags

To synchronize only files with a specific tag:

```bash
./install.sh -c sync-tag shell    # Only sync shell files
./install.sh -c sync-tag git      # Only sync git files
./install.sh -c sync-tag vim      # Only sync vim files
```

## Structure

- `.config/` - Configuration files for various tools
  - `env/` - Environment configuration scripts for various languages/tools
  - `lychee/` - Link checker configuration
  - `zi/` - ZSH Zi plugin manager configuration
- `.github/` - GitHub-related configuration and workflows
- `sync/` - Files to be synchronized across systems
  - `git/` - Git-related configuration
  - `linux/` - Linux-specific configurations

## Customization

You can customize the synchronization by modifying the `sync.config` file. A template is provided at
`sync.config.template`.

## Requirements

- Zsh shell
- Git

## License

See the [LICENSE](LICENSE) file for details.
