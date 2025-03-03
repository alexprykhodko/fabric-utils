import json
import re
import sys

from rich.console import Console
from rich.markdown import Markdown
from rich.rule import Rule

LINES_THRESHOLD = 50


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


def display_messages(messages):
    console = Console()
    for message in messages:
        if message['role'] == 'meta':
            continue
        console.print(f"-- [bold underline]{message['role'].upper()}[/bold underline] --")
        console.print()
        content, think_content = extract_content(message['content'])

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
    json_input = sys.stdin.read()
    if not json_input.strip():
        print("No input provided")
        sys.exit(1)

    messages = json.loads(json_input)

    # Display messages
    display_messages(messages)
