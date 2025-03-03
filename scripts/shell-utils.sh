#!/bin/zsh

export FABRIC_SCRIPTS="$HOME/.config/fabric/scripts"
export FABRIC_CONTEXTS="$HOME/.config/fabric/contexts"
export FABRIC_SESSIONS="$HOME/.config/fabric/sessions"

# ==============================================================================
# Basic aliases
# ==============================================================================

alias f="fabric"
alias fs="fabric --stream"

alias f-md-remove-links="python3 $FABRIC_SCRIPTS/md-remove-links.py"
alias f-md-format="python3 $FABRIC_SCRIPTS/md-format.py"
alias f-sess-format="python3 $FABRIC_SCRIPTS/sess-format.py"
alias f-format="python3 $FABRIC_SCRIPTS/output-format.py"

alias f-md="f-md-remove-links | f-md-format"

alias f-url="fabric -u"

# ------------------------------------------------------------------------------
# Context and session parameters
# ------------------------------------------------------------------------------

alias -g p-ctx="--context current.md"
alias -g p-sess="--session current"

# ------------------------------------------------------------------------------
# Models parameters
# ------------------------------------------------------------------------------

alias -g p-llama="-m llama-3.3-70b-versatile"
alias -g p-o1="--raw -m o1"
alias -g p-o3="--raw -m o3-mini"
alias -g p-r1="-m deepseek-r1-distill-llama-70b-specdec"
alias -g p-flash="-m gemini-2.0-flash"
alias -g p-claude="-m claude-3-5-sonnet-latest"

# ==============================================================================
# Context management functions
#===============================================================================

# Prints a summary of the current context
function f-summary() {
    # count the number of <document> tags:
    local count=$(grep -c "<document" $FABRIC_CONTEXTS/current.md)

    # Get the context URLs by parsing <document source="...">
    local urls=$(grep "<document source=" $FABRIC_CONTEXTS/current.md | sed 's/.*source="\([^"]*\)".*/\1/')

    echo "Current context documents:"
    echo $urls
    echo
    f-len
}

# Clears the contents of the current context
function f-clear() {
    echo >$FABRIC_CONTEXTS/current.md
}

# Adds a document to the current context by loading it from a URL (Markdown output)
function f-add() {
    ( printf '<document source="%s">\n\n' "$1"; fabric -u "$1" | f-md; printf '</document>\n\n' ) >>$FABRIC_CONTEXTS/current.md
    echo "Added document $1"
    echo
    f-summary
}

# Clears the context and adds each document from the list
function f-set() {
    f-clear
    echo "Cleared the context"
    echo "---"
    for url in $@; do
        f-add $url
        echo "---"
    done
}

# Prints the current context
function f-print() {
    local name=$1
        if [[ -n $name ]]; then
            local file="$FABRIC_CONTEXTS/$name.md"
        else
            local file="$FABRIC_CONTEXTS/current.md"
        fi

    cat "$file"
}

# Lists context by name (or current context if not specified)
function f-len() {
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
function f-save() {
    local name=$1
    cp $FABRIC_CONTEXTS/current.md $FABRIC_CONTEXTS/$name.md
}

# Loads a context from a file
function f-load() {
    local name=$1
    cp $FABRIC_CONTEXTS/$name.md $FABRIC_CONTEXTS/current.md
}

# Lists contexts without loading them; includes length in tokens
function f-list() {
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

# Clears the contents of the current session
function f-new() {
    rm $FABRIC_SESSIONS/current.json 2>/dev/null || echo "Current session is already empty"
}

# Prints the current session in a beautifully-formatted way
function f-sess() {
    cat $FABRIC_SESSIONS/current.json | f-sess-format
}

# ==============================================================================
# Initialization
# ==============================================================================

function _f_load_pattern_aliases() {
    # Loop through all files in the ~/.config/fabric/patterns directory
    for pattern_file in $HOME/.config/fabric/patterns/*/; do
        pattern_name=$(basename "$pattern_file")

        # Skip patterns that start with _
        if [[ $pattern_name == _* ]]; then
            continue
        fi

        pattern_alias=$(echo "fp-$pattern_name" | tr '_' '-')

        alias_command="alias $pattern_alias='fabric --pattern $pattern_name'"
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
