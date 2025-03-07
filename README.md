# Fabric Utilities

A set of shell shortcuts to speed work with [Fabric](https://github.com/danielmiessler/fabric)

## Synopsis

```bash
# Piping output from one provider to the input of another:
ai-python-class p-claude "Create a class for managing a music store selling CDs" \
| ai-python-expert p-flash "Please provide improvements for the class above" \
| ai-format

# Loading context from URL:
ai-ctx-set "https://www.python.org/about/"
ai p-ctx "Summarize the context please"
```

## Depdendencies

- Fabric
- Zsh
- Python 3.x

## Installation

1. [Install Fabric](https://github.com/danielmiessler/fabric?tab=readme-ov-file#installation)
2. Clone this repo and run in the root: `mkdir -p "$HOME/.config"; ln -s "$PWD" "$HOME/.config/fabric"`
3. Install Python requirements `pip3 install -r scripts/requirements.txt`
4. Prepare your LLM provider's API keys.
5. Run `fabric -S` to run the initial configuration of Fabric. 
6. Finally, add `source "$HOME/.config/fabric/scripts/shell-utils.sh` to your shell init script.
7. See `scripts/config.sh` for the model aliases.
