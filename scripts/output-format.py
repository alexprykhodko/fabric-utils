import re
import sys

from rich.console import Console
from rich.markdown import Markdown
from rich.rule import Rule

LINES_THRESHOLD = 200


def extract_content(content):
    """
    Extracts the <think> tag content from the message content.

    Returns:
        A tuple containing the content without the <think> tag and the <think> tag content.
    """
    think_pattern = re.compile(r'<think>(.*?)</think>', re.DOTALL)
    think_content = think_pattern.findall(content)
    content_without_think = think_pattern.sub('', content)

    # Break down the content into lines and return only the last 50 lines:
    content_lines = content_without_think.split('\n')
    if len(content_lines) > LINES_THRESHOLD:
        content_without_think = '\n'.join(content_lines[-LINES_THRESHOLD:])
        content_without_think += '[Truncated messages; showing last {} lines; total lines: {}]'.format(
            LINES_THRESHOLD,
            len(content_lines)
        )

    return content_without_think, ' '.join(think_content)


def display_output(value):
    console = Console()

    console.print()
    content, think_content = extract_content(value)

    if think_content:
        console.print("-- [italic]ASSISTANT THINKING[/italic] --")
        console.print(think_content)
        console.print("-- [italic]END OF ASSISTANT THINKING[/italic] --")
        console.print()

    console.print(Markdown(content))

    console.print()
    console.print(Rule())
    console.print()


if __name__ == "__main__":
    # Read JSON input from stdin
    value = sys.stdin.read()

    # Display messages
    display_output(value)
