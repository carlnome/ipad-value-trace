"""Fail CI if the app's Mach-O does not demonstrate the selected link mode."""
import argparse
from pathlib import Path
import re
import subprocess

FRAMEWORK = re.compile(r"\s+\S*/ValueTraceKit\s+\(")
CLASS_SYMBOL = re.compile(r"^[0-9a-fA-F]+\s+\S+\s+_OBJC_CLASS_\$_VTValueEvidence$")

def verify_linkage(configuration, libraries, load_commands, symbols, embedded_binary):
    dependencies = any(FRAMEWORK.match(line) for line in libraries.splitlines())
    if configuration == "Debug":
        blocks = re.split(r"(?m)^Load command \d+\s*$", load_commands)
        reexport = any(
            re.search(r"(?m)^\s*cmd LC_REEXPORT_DYLIB\s*$", block)
            and re.search(r"(?m)^\s*name \S*/ValueTraceKit\s+\(", block)
            for block in blocks
        )
        if not (dependencies and reexport and embedded_binary):
            raise ValueError("Debug must reexport the bundled ValueTraceKit dynamic binary")
    elif configuration == "Release":
        definition = any(CLASS_SYMBOL.fullmatch(line.strip()) for line in symbols.splitlines())
        if dependencies or not definition:
            raise ValueError("Release must define VTValueEvidence without dynamically loading ValueTraceKit")
    else:
        raise ValueError(f"Unsupported configuration: {configuration}")

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("configuration", choices=["Debug", "Release"])
    parser.add_argument("app", type=Path)
    args = parser.parse_args()
    binary = args.app / "ValueTraceExample"
    libraries = subprocess.check_output(["xcrun", "otool", "-L", str(binary)], text=True)
    print(libraries, end="")
    load_commands = subprocess.check_output(["xcrun", "otool", "-l", str(binary)], text=True)
    symbols = subprocess.check_output(["xcrun", "nm", "-U", str(binary)], text=True)
    embedded = any(item.is_file() for item in args.app.rglob("ValueTraceKit"))
    try:
        verify_linkage(args.configuration, libraries, load_commands, symbols, embedded)
    except ValueError as exc:
        parser.exit(1, f"{exc}\n")
    print(f"{args.configuration}: ValueTraceKit linkage verified")

if __name__ == "__main__":
    main()
