import dimscord
import typedefs, fileio/discordtoken

let discord* = newDiscordClient(getDiscordToken())

var slash_command_list* {.global.}: seq[SlashCommand]

export discord, typedefs
