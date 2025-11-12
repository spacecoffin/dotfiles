#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.13,<3.14"
# dependencies = ["typer==0.20.0"]
# ///

"""
Real usage example:
```bash
~/.scripts/rank-repos.py \
 requirements-new.txt \
 requirements-old.txt
 --output-file=requirements.txt
```
"""

from pathlib import Path
from typing import Annotated

import typer

app = typer.Typer()


@app.command()
def set_diff_lines(
    base: Annotated[str, typer.Argument(help="Base file path")],
    other: Annotated[str, typer.Argument(help="Other file path")],
    output_file: Annotated[str | None, typer.Option(help="Output file path")] = None,
) -> None:
    lhs_lines = set(Path(base).read_text().splitlines())
    rhs_lines = set(Path(other).read_text().splitlines())

    diff_lines = lhs_lines - rhs_lines

    output_path = Path(output_file) if output_file else None
    if output_path is None:
        for line in sorted(diff_lines):
            print(line)
    else:
        output_path.write_text("\n".join(sorted(diff_lines)) + "\n")


if __name__ == "__main__":
    app()
