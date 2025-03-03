#!/bin/zsh

set -e

source ./shell-utils.sh

fp-python-class p-claude "Create a class for managing a music store selling CDs" \
| fp-python-expert p-flash "Please provide improvements for the class above" \
| f-format
