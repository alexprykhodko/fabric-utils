#!/usr/bin/env zsh

export FABRIC_SCRIPTS="$HOME/.config/fabric/scripts"
export FABRIC_CONTEXTS="$HOME/.config/fabric/contexts"
export FABRIC_SESSIONS="$HOME/.config/fabric/sessions"

# ==============================================================================
# Basic aliases
# ==============================================================================

#alias f="fabric"
#alias fs="fabric --stream"

alias ai="fabric"
alias ai-md-remove-links="python3 $FABRIC_SCRIPTS/md-remove-links.py"
alias ai-md-format="python3 $FABRIC_SCRIPTS/md-format.py"
alias ai-sess-format="python3 $FABRIC_SCRIPTS/sess-format.py"
alias ai-format="python3 $FABRIC_SCRIPTS/output-format.py"

alias ai-md="ai-md-remove-links | ai-md-format"

alias ai-get-url="fabric -u"

# ------------------------------------------------------------------------------
# Context and session parameters
# ------------------------------------------------------------------------------

alias -g p-ctx="--context current.md"
alias -g p-sess="--session current"

source $FABRIC_SCRIPTS/config.sh

# ==============================================================================
# Context management functions
#===============================================================================

# Prints the current context
function ai-ctx() {
    local name=$1
        if [[ -n $name ]]; then
            local file="$FABRIC_CONTEXTS/$name.md"
        else
            local file="$FABRIC_CONTEXTS/current.md"
        fi

    cat "$file"
}

# Prints a summary of the current context
function ai-ctx-describe() {
    # count the number of <document> tags:
    local count=$(grep -c "<document" $FABRIC_CONTEXTS/current.md)

    # Get the context URLs by parsing <document source="...">
    local urls=$(grep "<document source=" $FABRIC_CONTEXTS/current.md | sed 's/.*source="\([^"]*\)".*/\1/')

    echo "Current context documents:"
    echo $urls
    echo
    ai-ctx-len
}

# Clears the contents of the current context
function ai-ctx-clear() {
    rm "$FABRIC_CONTEXTS/current.md" 2>/dev/null || echo "Current context is already empty"
}

# Adds a document to the current context by loading it from a URL (Markdown output)
function ai-ctx-add() {
    ( printf '<document source="%s">\n\n' "$1"; fabric -u "$1" | ai-md; printf '</document>\n\n' ) >>$FABRIC_CONTEXTS/current.md
    echo "Added document $1"
    echo
    ai-ctx-describe
}

# Clears the context and adds each document from the list
function ai-ctx-set() {
    ai-ctx-clear
    echo "Cleared the context"
    echo "---"
    for url in $@; do
        ai-ctx-add "$url"
        echo "---"
    done
}

# Lists context by name (or current context if not specified)
function ai-ctx-len() {
    local name=$1
    if [[ -n $name ]]; then
        local file="$FABRIC_CONTEXTS/$name.md"
    else
        local file="$FABRIC_CONTEXTS/current.md"
    fi

    # Get the length of the file in bytes and divide by 4 to get the number of tokens
    local len=$(wc -c <"$file" | xargs)
    local tokens=$((len >= 4 ? len / 4 : 0))

    printf "%'d tokens\n" "$tokens"
    printf "%'d bytes\n" "$len"
}

# Saves the current context to a file
function ai-ctx-save() {
    local name=$1
    cp $FABRIC_CONTEXTS/current.md $FABRIC_CONTEXTS/$name.md
}

# Loads a context from a file
function ai-ctx-load() {
    local name=$1
    cp $FABRIC_CONTEXTS/$name.md $FABRIC_CONTEXTS/current.md
}

# Lists contexts without loading them; includes length in tokens
function ai-ctx-list() {
    for file in $FABRIC_CONTEXTS/*.md; do
        local name=$(basename "$file" .md)
        local len=$(wc -c <"$file" | xargs)
        local tokens=$((len >= 4 ? len / 4 : 0))
        printf "%s: %'d tokens\n" "$name" "$tokens"
    done
}

# ==============================================================================
# Session management functions
#===============================================================================

# Prints the current session in a beautifully-formatted way
function ai-sess() {
    cat "$FABRIC_SESSIONS/current.json" | ai-sess-format
}


# Clears the contents of the current session
function ai-sess-new() {
    rm "$FABRIC_SESSIONS/current.json" 2>/dev/null || echo "Current session is already empty"
}

# ==============================================================================
# Initialization
# ==============================================================================

function ai-reset() {
    ai-ctx-clear
    ai-sess-new
    echo "Context and session cleared"
}

function _f_load_pattern_aliases() {
    # Loop through all files in the ~/.config/fabric/patterns directory
    for pattern_file in $HOME/.config/fabric/patterns/*/; do
        pattern_name=$(basename "$pattern_file")

        # Skip patterns that start with _
        if [[ $pattern_name == _* ]]; then
            continue
        fi

        pattern_alias=$(echo "ai-$pattern_name" | tr '_' '-')

        alias_command="alias $pattern_alias='ai --pattern $pattern_name'"
        eval "$alias_command"
    done
}

function _f_init() {
    _f_load_pattern_aliases
}

# ==============================================================================
# Main body
# ==============================================================================

_f_init
