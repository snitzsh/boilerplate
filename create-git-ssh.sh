# Generates the key
# TODO pass a file-name
ssh-keygen -t ed25519 -C "juanordaz2020@gmail.com"

# Start the ssh-agent in the background.
eval "$(ssh-agent -s)"

# Copy
pbcopy < ~/.ssh/githubs/id_ed25519.pub

# Paste the key on github
