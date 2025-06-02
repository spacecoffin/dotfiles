#!/bin/zsh

# Set the target directory
TARGET_DIR="$HOME/.scripts/kubectl-wrapper"

# Check if the target directory exists; exit if it doesn't
if [[ ! -d "$TARGET_DIR" ]]; then
  echo "Directory $TARGET_DIR does not exist. Exiting."
  exit 1
fi

# Create a temporary directory for cloning the repository
TEMP_DIR=$(mktemp -d)
echo "Cloning repository into temporary directory $TEMP_DIR..."

# Clone the private repository.
# You will be prompted for your git credentials if they are not cached.
git clone https://github.com/KoddiDev/DevOpsScripts.git "$TEMP_DIR/DevOpsScripts"
if [[ $? -ne 0 ]]; then
  echo "Failed to clone repository. Exiting."
  rm -rf "$TEMP_DIR"
  exit 1
fi

# Define source file paths from the cloned repository
FUNCTIONS_SRC="$TEMP_DIR/DevOpsScripts/kubectl-wrapper/functions.bash"
KUBECTL_SRC="$TEMP_DIR/DevOpsScripts/kubectl-wrapper/kubectl"

# Copy functions.bash if it exists
if [[ -f "$FUNCTIONS_SRC" ]]; then
  cp "$FUNCTIONS_SRC" "$TARGET_DIR/functions.bash"
  echo "Copied functions.bash to $TARGET_DIR"
else
  echo "File functions.bash not found in the repository."
fi

# Copy kubectl if it exists
if [[ -f "$KUBECTL_SRC" ]]; then
  cp "$KUBECTL_SRC" "$TARGET_DIR/kubectl"
  echo "Copied kubectl to $TARGET_DIR"
else
  echo "File kubectl not found in the repository."
fi

# Remove the temporary directory
rm -rf "$TEMP_DIR"
echo "Temporary files cleaned up."
