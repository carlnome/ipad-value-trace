"""Prepare the public fixture. This is a fixed marker, not the internal AST tool."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
template = (root / "Fixtures/SyntheticCallback.m.in").read_text()
marker = "/* SYNTHETIC_PROBE_SITE */"
if template.count(marker) != 1:
    raise SystemExit("Expected exactly one synthetic probe site")
output = root / "Generated/SyntheticCallback.m"
output.parent.mkdir(exist_ok=True)
output.write_text(template.replace(marker, "if (capture) capture(value, cached);"))
