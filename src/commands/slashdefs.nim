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
    category: topic,
    serverOnly: true,
    permissions: none seq[PermissionFlags]
)


# -----------------------------------------------------------------------------
# Nation Management Commands:
# -----------------------------------------------------------------------------
topic = NATION_MANAGEMENT

add SlashCommand(
    name: "create nation",
    desc: "Creates a nation. (only one nation can be ruled at once, name cannot be changed)",
    category: topic,
    serverOnly: true,
    permissions: none seq[PermissionFlags]
)

add SlashCommand(
    name: "abandon nation",
    desc: "Makes you leave a nation. (cannot be undone)",
    category: topic,
    serverOnly: true,
    permissions: none seq[PermissionFlags]
)

add SlashCommand(
    name: "invite member",
    desc: "Invites a member to your currently ruled nation.",
    category: topic,
    serverOnly: true,
    permissions: none seq[PermissionFlags]
)

add SlashCommand(
    name: "remove member",
    desc: "Removes a member from your currently ruled nation.",
    category: topic,
    serverOnly: true,
    permissions: none seq[PermissionFlags]
)

add SlashCommand(
    name: "set nation nickname",
    desc: "Sets the current nickname for your nation.",
    call: setNationNicknameCommand,
    category: topic,
    serverOnly: true,
    permissions: none seq[PermissionFlags]
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
    category: topic,
    serverOnly: true,
    permissions: none seq[PermissionFlags]
)

add SlashCommand(
    name: "set nation wiki",
    desc: "Links an external wiki page to your nation.",
    category: topic,
    serverOnly: true,
    permissions: none seq[PermissionFlags]
)

add SlashCommand(
    name: "set nation flag",
    desc: "Sets your nations flag. (accepts urls to picutre)",
    category: topic,
    serverOnly: true,
    permissions: none seq[PermissionFlags]
)


