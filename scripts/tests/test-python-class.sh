#!/bin/zsh

set -e

script_dir=$(dirname "$0")

echo "Claude and Gemini 2.0 Flash API keys must be set in Fabric config."

source $script_dir/../shell-utils.sh

ai-python-class pset-claude "Create a class for managing a music store selling CDs" \
| ai-python-expert pset-flash "Please provide improvements for the class above" \
| ai-format
