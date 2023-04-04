import asyncdispatch, options, strutils, strformat
import dimscord
import ../globals, ../typedefs, ../fileio/logger

using
    s: Shard
    i: Interaction
    m: Message
    r: Response

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


# Error message stuff:
proc errorMessage*(error: CommandError, msg: string = "No additional details provided."): Response =
    return Response(
        embeds: @[Embed(
            title: some "Error",
            description: some @["**" & $error & "**", msg].join("\n"),
            color: some int colError
        )]
    )

