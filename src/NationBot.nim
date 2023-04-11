import os, strutils, strformat, asyncdispatch, times, segfaults
import dimscord
import typedefs, globals, slashcommands, fileio/logger, nation/filehandler

# Create valid environment:
for dir in DirsLocation:
    if not dirExists($dir): createDir($dir)

using
    s: Shard
    m: Message
    i: Interaction
    g: Guild
    r: Ready


# -----------------------------------------------------------------------------
# Events:
# -----------------------------------------------------------------------------

proc onReady(s, r) {.event(discord).} =
    # Update status and send commands to discord:
    discard s.updateStatus(
        activities = @[ActivityStatus(
            name: "testing, beep boop",
            kind: atPlaying
        )],
        status = "online",
        afk = false
    )
    discard await discord.api.bulkOverwriteApplicationCommands(
        s.user.id,
        getApplicationCommandList()
    )

    # Load data:
    initNationCache()

    # Exit with confirmation:
    let starttime: string = now().format("yyyy-MM-dd HH:mm:ss (zzz)")
    echo &"Ready as {r.user} in {r.guilds.len()} guild(s)  @  {starttime}"


proc guildCreate(s, g) {.event(discord).} =
    g.id.cacheGuildNationsData()

proc interactionCreate(s, i) {.event(discord).} =
    discard handleInteraction(s, i)


# -----------------------------------------------------------------------------
# Connect to discord:
# -----------------------------------------------------------------------------

try:
    waitFor discord.startSession(
        autoreconnect = true,
        gateway_intents = {giDirectMessages, giGuildMessages, giGuilds, giGuildMembers, giMessageContent}
    )
except Exception as e:
    echo "Could not connect to discord :(\nSee log files for more information!"
    e.entry()
    quit(1)
