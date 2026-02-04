# zsh functions

This folder contains personal zsh functions. Sensitive values are kept out of
the repository and loaded from local files or environment variables.

## Setup

1. Copy the example files:

```
cp ~/.zshrc_function/data/ssh-sites.example.json ~/.zshrc_function/data/ssh-sites.json
cp ~/.zshrc_function/data/aws-tunneling.example.json ~/.zshrc_function/data/aws-tunneling.json
```

2. Export required environment variables in your shell profile:

```
export SITE_A_USER="user"
export SITE_A_HOST="x.x.x.x"
export SITE_B_KEY_PATH="/path/to/key.pem"
export SITE_B_USER="user"
export SITE_B_HOST="x.x.x.x"
export SITE_C_USER="user"
export SITE_C_HOST="x.x.x.x"
export SITE_C_PORT="22"
```

3. Reload your shell:

```
source ~/.zshrc
```

## Notes

- `data/ssh-sites.json` are ignored by git.
- `data/aws-tunneling.json` are ignored by git.
- Keep key files private and with restricted permissions (e.g., `chmod 600`).
