import options, strutils, strformat, tables, sequtils
import dimscord
import ../globals, utils, ../nation/[utils, typedefs, users]

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
# Profile commands:
# -----------------------------------------------------------------------------

proc linkMinecraftUsernameCommand*(s, i, data): Re =
    return getResponse linkMinecraftUsername(i.guild_id.get(), i.member.get().user.id, data.options["username"].str)


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
        return ERROR_USAGE.errorMessage(&"No nation with the name '{nation_name}' was found...")
    let nation: Nation = nation_maybe.get()

    var emb = Embed(
        title: some nation.name,
        description: nation.desc,
        url: nation.wiki_link
    )
    # Title (Name + Nickname):
    if nation.nickname.isSome():
        emb.title = some emb.title.get() & &" ({nation.nickname.get()})"

    # Fields:
    var member_list: seq[string]
    if nation.member_ids.isSome(): member_list = nation.member_ids.get()
    member_list.add(nation.owner_id)


    var fields: seq[EmbedField] = @[
        EmbedField(
            name: "Members",
            value: member_list.fullName(guild_id).join("\n")
        )
    ]
    if nation.creation_date.isSome():
        fields.add EmbedField(
            name: "Creation Time",
            value: nation.creation_date.get()
        )
    emb.fields = some fields

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

proc createNationCommand*(s, i, data): Re =
    let
        nation_name: string = data.options["nation"].str
        owner_id: string = i.member.get().user.id
        status: (bool, string) = i.guild_id.get().createNation(nation_name, owner_id)
    return getResponse status

proc deleteNationCommand*(s, i, data): Re =
    return getResponse deleteNation(i, data.options["delete_nation_confirmation"].str)

proc leaveNationCommand*(s, i, data): Re =
    return getResponse removeUserFromNation(i.guild_id.get(), i.member.get().user.id, data.options["nation"].str)

proc removeUserFromNationCommand*(s, i, data): Re =
    let
        guild_id: string = i.guild_id.get()
        owner_id: string = i.member.get().user.id
        user_id: string = data.options["user"].user_id
        nation_maybe: Option[Nation] = guild_id.getGuildNationByOwner(owner_id)
    
    if nation_maybe.isNone():
        return getResponse (false, "You do not rule a nation. You cannot remove this member from it.")
    return getResponse removeUserFromNation(guild_id, user_id, nation_maybe.get().name)


# Customization:

proc setNationNicknameCommand*(s, i, data): Re =
    return getResponse modifyNation(i, "nickname", max_nation_character_length)

proc resetNationNicknameCommand*(s, i, data): Re =
    return getResponse resetNationField[string](i, "nickname")

proc setNationDescriptionCommand*(s, i, data): Re =
    return getResponse modifyNation(i, "desc", 2048)  # 2048 is the limit discord sets for embed descriptions

proc setNationWikiLinkCommand*(s, i, data): Re =
    return getresponse modifyNation(i, "wiki_link")

proc setNationFlagLinkCommand*(s, i, data): Re =
    return getResponse modifyNation(i, "flag_link")

proc setNationMapLinkCommand*(s, i, data): Re =
    return getResponse modifyNation(i, "map_link")


# Invites:

proc sendInviteCommand*(s, i, data): Re =
    return getResponse sendPlayerInvite(i, data.options["user"].user_id)

proc displayPendingInvitesCommand*(s, i, data): Re =
    return Re(
        embeds: @[Embed(
            title: some "Pending invites",
            description: some getPendingInvites(i.guild_id.get(), i.member.get().user.id)
        )]
    )

proc acceptInviteCommand*(s, i, data): Re =
    return getResponse nationInviteAct(i.guild_id.get(), i.member.get().user.id, data.options["nation"].str, true)

proc declineInviteCommand*(s, i, data): Re =
    return getResponse nationInviteAct(i.guild_id.get(), i.member.get().user.id, data.options["nation"].str, false)
