import sys

import mdformat


def format_markdown(markdown_text):
    """
    Formats Markdown text using mdformat.
    """
    return mdformat.text(markdown_text, options={
        "number": True,  # switch on consecutive numbering of ordered lists
    })


if __name__ == "__main__":
    markdown_input = sys.stdin.read()
    markdown_output = format_markdown(markdown_input)
    sys.stdout.write(markdown_output)
