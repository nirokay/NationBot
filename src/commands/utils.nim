import asyncdispatch, options, strutils, strformat, tables
import dimscord
import ../globals, ../typedefs, ../fileio/logger, ../nation/[typedefs, utils, users]

using
    s: Shard
    i: Interaction
    m: Message
    r: Response

# Error message stuff:
proc errorMessage*(error: CommandError, msg: string = "No additional details provided."): Response =
    return Response(
        embeds: @[Embed(
            title: some "Error",
            description: some @["**" & $error & "**", msg].join("\n"),
            color: some int colError
        )]
    )

# Shenanigans:
proc modifyEmbedsIfNecessary(embeds: seq[Embed]): seq[Embed] =
    for e in embeds:
        var emb: Embed = e
        if emb.color.isNone():
            emb.color = some int colDefault
        result.add(emb)
    return result


# Slash Command Response:
proc convertSlashResponse(r): InteractionCallbackDataMessage =
    return InteractionCallbackDataMessage(
        content: r.content,
        attachments: r.attachments,
        embeds: r.embeds
    )

proc sendResponse*(s, i, r) =
    var resp: Response = r
    resp.embeds = modifyEmbedsIfNecessary(r.embeds)
    try:
        discard discord.api.interactionResponseMessage(
            i.id, i.token,
            kind = irtChannelMessageWithSource,
            response = resp.convertSlashResponse()
        )
    except Exception as e:
        e.entry(&"Failed to send slash response for command '{i.data.get().name}'.")

proc getResponse*(status: (bool, string)): Response =
    if status[0]: result = Response(content: status[1])
    else: result = ERROR_USAGE.errorMessage(status[1])
    return result

proc sendResponse*(s, i; status: (bool, string)) =
    sendResponse(s, i, status.getResponse())


# Message response:
proc sendResponse*(s, m, r): Future[Message] {.async.} =
    # Apply defualt colour for embeds, if none present:
    var embeds: seq[Embed] = modifyEmbedsIfNecessary(r.embeds)

    # Attempt sending message:
    try:
        return await discord.api.sendMessage(
            m.channel_id,
            content = r.content,
            attachments = r.attachments,
            embeds = embeds
        )
    except Exception as e:
        e.entry(&"Failed to send message.")

proc sendMessage*(s, m, r): Future[Message] {.async.} = return await sendResponse(s, m, r)


# Misc.:
proc mentionUser*(user_id: string): string =
    return &"<@{user_id}>"
proc mentionUser*(user: User): string =
    return mentionUser(user.id)
proc mentionUser*(member: Member): string =
    return mentionUser(member.user.id)

proc fullName*(user_id, guild_id: string): string =
    result = user_id.mentionUser()
    let player: Player = guild_id.getGuildUser(user_id)
    if player.player_name.isSome():
        result.add(&" ({player.player_name.get()})")
    return result
proc fullName*(user_ids: seq[string], guild_id: string): seq[string] =
    for i in user_ids:
        result.add(fullName(i, guild_id))
    return result
