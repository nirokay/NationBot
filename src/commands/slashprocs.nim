import options, strutils, strformat, tables
import dimscord
import ../globals, utils, ../nation/[utils, typedefs]

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


# -----------------------------------------------------------------------------
# Nation commands:
# -----------------------------------------------------------------------------

proc listNationsCommand*(s, i, data): Re =
    return Re(
        embeds: @[Embed(
            title: some "List of all nations.",
            description: some getCurrentNationNames(i.guild_id.get()).join("\n")
        )]
    )

proc displayNationCommand*(s, i, data): Re =
    let guild_id: string = i.guild_id.get()

    # Very janky, but it works... 🥴
    var nation_name: string
    for i, value in data.options:
        nation_name = value.str
        break

    let nation_maybe: Option[Nation] = guild_id.getGuildNationByName(nation_name)
    if nation_maybe.isNone():
        return ERROR_INTERNAL.errorMessage(&"No nation with the name '{nation_name}' was found...")
    let nation: Nation = nation_maybe.get()

    var emb = Embed(
        title: some nation.name,
        description: nation.desc,
        url: nation.wiki_link
    )
    # Title (Name + Nickname):
    if nation.nickname.isSome():
        emb.title = some emb.title.get() & &" ({nation.nickname.get()})"

    # Images:
    if nation.flag_link.isSome():
        emb.thumbnail = some EmbedThumbnail(url: nation.flag_link.get())
    if nation.map_link.isSome():
        emb.image = some EmbedImage(url: nation.map_link.get())

    return Re(
        embeds: @[emb]
    )

# -----------------------------------------------------------------------------
# Nation Management Commands:
# -----------------------------------------------------------------------------

proc setNationNicknameCommand*(s, i, data): Re =
    return getResponse modifyNation(i, "nickname")

proc setNationDescriptionCommand*(s, i, data): Re =
    return getResponse modifyNation(i, "desc")

proc setNationWikiLinkCommand*(s, i, data): Re =
    return getresponse modifyNation(i, "wiki_link")

proc setNationFlagLinkCommand*(s, i, data): Re =
    return getResponse modifyNation(i, "flag_link")

proc setNationMapLinkCommand*(s, i, data): Re =
    return getResponse modifyNation(i, "map_link")

