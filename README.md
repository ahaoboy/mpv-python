# mpv-python

Portable [Python](https://www.python.org/) embeddable environments for [mpv](https://mpv.io/).

Each release bundles a self-contained Python runtime so that mpv scripts can run
Python code without requiring a system-wide Python installation.

## What's inside

Every release ships a zip archive containing a Python embeddable distribution
(with `pip` and `site-packages` enabled) plus the generated `script.json`
manifest, ready to be dropped into mpv's `scripts` directory.

| Package               | Description                     |
| --------------------- | ------------------------------- |
| `mpv-python313.zip`   | Python 3.13 embeddable runtime  |
| `mpv-python314.zip`   | Python 3.14 embeddable runtime  |
| `mpv-python-test.zip` | Standalone OSC test script      |

## Usage

1. Download the zip for the Python version you need from the
   [latest release](https://github.com/ahaoboy/mpv-python/releases/latest).
2. Extract it into your mpv `scripts` directory:

   - Windows: `%APPDATA%\mpv\scripts\`
   - Linux/macOS: `~/.config/mpv/scripts/`

3. Restart mpv. The bundled `test.py` will run automatically and show the
   Python version as an on-screen message.

## Building from source

The build only needs `bash`, `curl`, `unzip`, `zip` and `sed`:

```sh
bash build.sh
```

This downloads the latest Python embeddable releases, installs `pip`, trims
unneeded files, and packs everything into zips at the repository root.

## License

See the repository for details.
