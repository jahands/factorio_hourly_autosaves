set shell := ["zsh", "-c"]
set dotenv-load := true

[private]
@help:
  just --list

@clean:
  rm -rf dist
  mkdir -p dist

build:
  just clean
  pnpm fmtk package --outdir dist

upload:
  pnpm fmtk upload ./dist/*.zip

publish:
  just clean
  pnpm fmtk publish
