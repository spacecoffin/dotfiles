#!/bin/zsh

COMPLETION_DIR="$HOME/.zfunc"

GLOBAL_BIN=/usr/local
HOMEBREW_BIN=/opt/homebrew/bin
LOCAL_BIN="$HOME/.local/bin"
GOLANG_BIN="$HOME/.go/bin"
# CARGO_BIN="$HOME/.cargo/bin"

# https://docs.astral.sh/uv/getting-started/installation/#shell-autocompletion
"$LOCAL_BIN/uv" generate-shell-completion zsh > "$COMPLETION_DIR/_uv"

# "$HOMEBREW_BIN/kubectl" completion zsh > "$COMPLETION_DIR/_kubectl"
# "$HOMEBREW_BIN/minikube" completion zsh > "$COMPLETION_DIR/_minikube"

# https://dandavison.github.io/delta/tips-and-tricks/shell-completion.html
# "$HOMEBREW_BIN/delta" --generate-completion zsh > "$COMPLETION_DIR/_delta"

# https://docs.astral.sh/ruff/configuration/#shell-autocompletion
"$LOCAL_BIN/uvx" ruff generate-shell-completion zsh > "$COMPLETION_DIR/_ruff"

# https://hatch.pypa.io/dev/cli/about/#z-shell
_HATCH_COMPLETE=zsh_source "$GLOBAL_BIN/hatch/bin/hatch" > "$COMPLETION_DIR/_hatch"

# https://golangci-lint.run/welcome/integrations/#shell-completion
"$GOLANG_BIN/golangci-lint" completion zsh > "$COMPLETION_DIR/_golangci-lint"
