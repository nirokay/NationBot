import options, strutils, strformat, tables
import dimscord
import ../globals, utils

using
    s: Shard
    i: Interaction
    r: Response
    data: ApplicationCommandInteractionData

type Re = Response


# -----------------------------------------------------------------------------
# System commands:
# -----------------------------------------------------------------------------

proc helpCommand*(s, i, data): Re =
    var catTable: Table[CommandCategory, seq[string]]
    for cmd in slash_command_list:
        if not catTable.hasKey(cmd.category): catTable[cmd.category] = @[]
        catTable[cmd.category].add(cmd.name)
    
    let embInline: bool = true
    var fields: seq[EmbedField]
    for cat, cmds in catTable:
        fields.add(EmbedField(
            name: $cat,
            value: "`" & cmds.join("`\n`") & "`",
            inline: some embInline
        ))

    return Re(
        embeds: @[Embed(
            title: some "This is a list of all commands.",
            description: some "Commands are split into categories. You may not be able to use all of them, " &
                "depending on your permissions or if you are executing them in direct messages or a server.",
            fields: some fields
        )]
    )

proc pingCommand*(s, i, data): Re =
    return Re(
        embeds: @[Embed(
            title: some "Pong!",
            description: some &"Current latency is {s.latency}ms!"
        )]
    )




