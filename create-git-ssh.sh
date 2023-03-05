#!/bin/bash
# Docs
# - Generate keys
#   https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
# - Add key
#   https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account

# Generates the key
# TODO pass a file-name
ssh-keygen -t ed25519 -C "juanordaz2020@gmail.com"

# Start the ssh-agent in the background.
eval "$(ssh-agent -s)"

# Copy
pbcopy < ~/.ssh/githubs/id_ed25519.pub

# Paste the key on github
