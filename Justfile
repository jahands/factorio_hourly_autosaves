set shell := ["zsh", "-c"]

[private]
@help:
  just --list

build:
  @mkdir -p dist
  pnpm fmtk package --outdir dist

upload:
  pnpm fmtk upload ./dist/*.zip

publish:
  @mkdir -p dist
  pnpm fmtk publish
