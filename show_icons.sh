cd ~/Games
find  . -maxdepth 1 -mindepth 1 -type d | cut -b 1-2 --complement > .hidden
