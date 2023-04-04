import options, strutils, strformat, tables
import dimscord
import ../globals, utils

using
    s: Shard
    i: Interaction
    r: Response
    data: ApplicationCommandInteractionData


# -----------------------------------------------------------------------------
# System commands:
# -----------------------------------------------------------------------------

proc pingCommand*(s, i, data): Response =
    return Response(
        embeds: @[Embed(
            title: some "Pong!",
            description: some &"Current latency is {s.latency}ms!"
        )]
    )

