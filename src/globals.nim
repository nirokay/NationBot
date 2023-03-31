import dimscord
import typedefs, fileio/discordtoken

let discord* = newDiscordClient(getDiscordToken())

var slash_commands*: seq[SlashCommand]

export discord, typedefs
