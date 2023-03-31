import os, strutils, strformat, asyncdispatch, times, segfaults
import dimscord
import typedefs, globals, slashcommands, fileio/logger

# Create valid environment:
for dir in DirsLocation:
    if not dirExists($dir): createDir($dir)

using
    s: Shard
    m: Message
    i: Interaction
    r: Ready

proc onReady(s, r) {.event(discord).} =
    echo "reeeeeeady uwu"
    
    # Exit with confirmation:
    let starttime: string = now().format("yyyy-MM-dd HH:mm:ss (zzz)")
    echo &"Ready as {r.user} in {r.guilds.len()} guild(s)  @  {starttime}"


proc interactionCreate(s, i) {.event(discord).} =
    handleInteraction(s, i)


try:
    waitFor discord.startSession(
        autoreconnect = true,
        gateway_intents = {giDirectMessages, giGuildMessages, giGuilds, giGuildMembers, giMessageContent}
    )
except Exception as e:
    echo "Could not connect to discord :(\nSee log files for more information!"
    e.entry()
    quit(1)
