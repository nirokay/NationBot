import asyncdispatch, options, strformat, strutils
import dimscord
import typedefs, globals, commands/[slashdefs, utils], fileio/logger

using
    s: Shard
    i: Interaction


proc convertSlashToAppCommand(cmd: SlashCommand): ApplicationCommand =
    let defaultPermissions: bool = cmd.permissions.isNone()
    var
        permissions: set[PermissionFlags]
        commandKind: ApplicationCommandType = atSlash
        commandName: string = cmd.name.replace(' ', '_')
    
    # Handle application type:
    if cmd.kind.isSome():
        commandKind = cmd.kind.get()

    # Convert seq to set: (ugly, but it works)
    if cmd.permissions.isSome():
        for perm in cmd.permissions.get():
            let setPerm: set[PermissionFlags] = {perm}
            permissions = permissions + setPerm
    
    # Convert to ApplicationCommand:
    return ApplicationCommand(
        name: commandName,
        description: cmd.desc,
        kind: commandKind,
        options: cmd.options,
        default_permission: defaultPermissions,
        default_member_permissions: some permissions
    )

proc getApplicationCommandList*(): seq[ApplicationCommand] =
    for cmd in slash_command_list:
        result.add(convertSlashToAppCommand(cmd))
    return result


proc handleInteraction*(s, i): Future[void] {.async.} =
    # Should not happen, but WHAT IF????
    if i.data.isNone(): return
    let data = i.data.get()

    var requested_command: SlashCommand
    for command in slash_command_list:
        if command.name.replace(' ', '_') == data.name:
            requested_command = command
            break
    
    # Again, should not happen... BUT:
    if requested_command.name == "":
        sendResponse(s, i, errorMessage(ERROR_INTERNAL, "Command name not found."))
        return
    
    # Handle server-only command:
    if requested_command.serverOnly and i.guild_id.isNone():
        sendResponse(s, i, errorMessage(ERROR_SERVERONLY))
        return
    
    # Attempt calling command:
    try:
        sendResponse(s, i, requested_command.call(s, i, data))
    except Exception as e:
        e.entry(&"Failed to execute command '{data.name}'")



