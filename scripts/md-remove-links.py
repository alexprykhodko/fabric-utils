import re
import sys


def remove_empty_links(markdown_text):
    """
    Removes empty links (empty link text or empty URL) in Markdown.
    """

    # Remove links with empty link text: []() or [ ]() or [  ]() etc.
    markdown_text = re.sub(r'\[\s*?\]\((.*?)\)', '', markdown_text)

    # Remove links with empty URL: [](url) or [text]() or [text]( ) etc.
    markdown_text = re.sub(r'\[(.*?)\]\(\s*?\)', '', markdown_text)

    return markdown_text


if __name__ == "__main__":
    markdown_input = sys.stdin.read()
    markdown_output = remove_empty_links(markdown_input)
    sys.stdout.write(markdown_output)
