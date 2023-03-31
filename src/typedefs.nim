import options
import dimscord/[objects, constants]

type
    DirsLocation* = enum
        dirPrivate = "private/"
        dirServers = "private/servers/"
        dirLogs = "private/logs/"

    FileLocation* = enum
        fileDiscordToken = $dirPrivate & "discord_token.txt"
        fileLogError = $dirLogs & "error.log"
        fileLogDebug = $dirLogs & "debug.log"
        fileLogUsage = $dirLogs & "usage.log"

    Response* = object
        channel_id*, content*: string
        attachments*: seq[Attachment]
        embeds*: seq[Embed]
    
    CommandCategory* = enum
        SYSTEM = "⚙️ System"
        NATIONS = "🌍 Nations"
        NATION_MANAGEMENT = "🛠️ Nation Management"
        UNDEFINED = "❓ Misc"

    SlashOption* = ApplicationCommandOption
    SlashChoice* = ApplicationCommandOptionChoice
    SlashCommand* = object
        name*, desc*: string 
        category*: CommandCategory
        serverOnly*: bool
        options*: seq[SlashOption]
        permissions*: Option[seq[PermissionFlags]]



