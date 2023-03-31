import os, strutils, strformat
import ../typedefs

var discord_token: string

proc getDiscordToken*(): string =
    let discord_token_path: string = $fileDiscordToken

    # Already init:
    if discord_token != "": return "discord token already initiated"

    # Token file not found:
    if not discord_token_path.fileExists():
        echo &"Error!\nFile with token was not found! Please place your discord token into file at '{discord_token_path}'."
        quit(1)

    discord_token = discord_token_path.readFile().strip()
    return discord_token

