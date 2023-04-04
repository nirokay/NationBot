import options
import dimscord/[objects, constants]

type
    # File/Dir locations:
    DirsLocation* = enum
        dirPrivate = "private/"
        dirServers = "private/servers/"
        dirLogs = "private/logs/"
        dirTokens = "private/tokens/"

    FileLocation* = enum
        fileDiscordToken = $dirTokens & "discord.txt"
        fileLogError = $dirLogs & "error.log"
        fileLogDebug = $dirLogs & "debug.log"
        fileLogUsage = $dirLogs & "usage.log"

    # Message stuff:
    CommandError* = enum
        ERROR_INTERNAL = "Internal error - please report this!"
        ERROR_SERVERONLY = "The command you tried to execute can only be run on servers."
        ERROR_USAGE = "Invalid command usage, please see `help` for further information."
    
    CommandCategory* = enum
        SYSTEM = "⚙️ System"
        NATIONS = "🌍 Nations"
        NATION_MANAGEMENT = "🛠️ Nation Management"
        UNDEFINED = "❓ Misc"
    
    EmbedColour* = enum
        colError = 0xB32050
        colDefault = 0xBD93F9
        colWarning = 0xE6B800

    Response* = object
        channel_id*, content*: string
        attachments*: seq[Attachment]
        embeds*: seq[Embed]

    SlashOption* = ApplicationCommandOption
    SlashChoice* = ApplicationCommandOptionChoice
    SlashCommand* = object
        name*, desc*: string 
        category*: CommandCategory
        serverOnly*: bool
        call*: proc(s: Shard, i: Interaction, data: ApplicationCommandInteractionData): Response
        kind*: Option[ApplicationCommandType]  # default is 'atSlash'
        options*: seq[SlashOption]
        permissions*: Option[seq[PermissionFlags]]



