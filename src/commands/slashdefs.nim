import options
import dimscord
import ../globals, slashprocs

var topic: CommandCategory
proc add(cmd: SlashCommand) =
    slash_command_list.add(cmd)



# -----------------------------------------------------------------------------
# System Commands:
# -----------------------------------------------------------------------------
topic = SYSTEM

add SlashCommand(
    name: "help",
    desc: "Provides information about the bot and commands.",
    call: helpCommand,
    category: topic,
    permissions: none seq[PermissionFlags]
)

add SlashCommand(
    name: "ping",
    desc: "Pong!",
    call: pingCommand,
    category: topic,
    permissions: none seq[PermissionFlags]
)


# -----------------------------------------------------------------------------
# Nation Commands:
# -----------------------------------------------------------------------------
topic = NATIONS

add SlashCommand(
    name: "list nations",
    desc: "Lists all nations on this server.",
    call: listNationsCommand,
    category: topic,
    serverOnly: true,
    permissions: none seq[PermissionFlags]
)

add SlashCommand(
    name: "display nation",
    desc: "Displays the specified nation and its details.",
    call: displayNationCommand,
    category: topic,
    serverOnly: true,
    permissions: none seq[PermissionFlags],
    options: @[SlashOption(
        kind: acotStr,
        name: "nation",
        description: "Pick a nation to display.",
        required: some true
        #choices: @[] #! Add them here for each guild! Update with write to disk call
    )]
)


# -----------------------------------------------------------------------------
# Nation Management Commands:
# -----------------------------------------------------------------------------
topic = NATION_MANAGEMENT

add SlashCommand(
    name: "create nation",
    desc: "Creates a nation. (only one nation can be ruled at once, name cannot be changed)",
    call: createNationCommand,
    category: topic,
    serverOnly: true,
    permissions: none seq[PermissionFlags],
    options: @[SlashOption(
        kind: acotStr,
        name: "nation",
        description: "Create a nation. The nation name cannot be changed later on!",
        required: some true
    )]
)

add SlashCommand(
    name: "abandon nation",
    desc: "Makes you leave a nation. (cannot be undone)",
    category: topic,
    serverOnly: true,
    permissions: none seq[PermissionFlags],
    options: @[SlashOption(
        kind: acotStr,
        name: "nation",
        description: "Leaves the specified nation. You have to type out its full name!",
        required: some true
    )]
)

add SlashCommand(
    name: "invite member",
    desc: "Invites a member to your currently ruled nation.",
    category: topic,
    serverOnly: true,
    permissions: none seq[PermissionFlags],
    options: @[SlashOption(
        kind: acotUser,
        name: "user",
        description: "Invite this member.",
        required: some true
    )]
)

add SlashCommand(
    name: "remove member",
    desc: "Removes a member from your currently ruled nation.",
    category: topic,
    serverOnly: true,
    permissions: none seq[PermissionFlags],
    options: @[SlashOption(
        kind: acotUser,
        name: "user",
        description: "Removes this member from your main nation.",
        required: some true
    )]
)

add SlashCommand(
    name: "set nation nickname",
    desc: "Sets the current nickname for your nation.",
    call: setNationNicknameCommand,
    category: topic,
    serverOnly: true,
    permissions: none seq[PermissionFlags],
    options: @[SlashOption(
        kind: acotStr,
        name: "nickname",
        description: "Sets a new nickname for your nation.",
        required: some true
    )]
)

add SlashCommand(
    name: "reset nation nickname",
    desc: "Removes the current nickname of your nation.",
    category: topic,
    serverOnly: true,
    permissions: none seq[PermissionFlags]
)

add SlashCommand(
    name: "set nation description",
    desc: "Sets your nations description.",
    call: setNationDescriptionCommand,
    category: topic,
    serverOnly: true,
    permissions: none seq[PermissionFlags],
    options: @[SlashOption(
        kind: acotStr,
        name: "description",
        description: "This description will be visible on the nation display.",
        required: some true
    )]
)

add SlashCommand(
    name: "set nation wiki",
    desc: "Links an external wiki page to your nation.",
    call: setNationWikiLinkCommand,
    category: topic,
    serverOnly: true,
    permissions: none seq[PermissionFlags],
    options: @[SlashOption(
        kind: acotStr,
        name: "link",
        description: "Links your nation to a wiki page.",
        required: some true
    )]
)

add SlashCommand(
    name: "set nation flag",
    desc: "Sets your nations flag. (accepts urls to pictures)",
    call: setNationFlagLinkCommand,
    category: topic,
    serverOnly: true,
    permissions: none seq[PermissionFlags],
    options: @[SlashOption(
        kind: acotStr,
        name: "link",
        description: "Accepts direct links to image files.",
        required: some true
    )]
)

add SlashCommand(
    name: "set nation map",
    desc: "Set an image as a map for your nation. (accepts urls to pictures)",
    call: setNationMapLinkCommand,
    category: topic,
    serverOnly: true,
    permissions: none seq[PermissionFlags],
    options: @[SlashOption(
        kind: acotStr,
        name: "link",
        description: "Accepts direct links to image files.",
        required: some true
    )]
)


