import os, options, strutils, strformat, json, tables

import typedefs, ../globals, ../fileio/logger
# This file could be made redundant with generics, i will note this down and
# not do anything about this for atleast a couple of weeks :)))

proc fileName(guild_id: string): string =
    return &"{$dirUsers}{guild_id}.json"


proc createGuildUsersFile(guild_id: string): bool =
    let serverFile: string = guild_id.fileName()
    try:
        if not serverFile.fileExists():
            serverFile.writeFile("{}")
        return true
    except Exception as e:
        e.entry("Could not write new guild users file.")
        return false


proc loadGuildUsers*(guild_id: string): Table[string, Player] =
    let serverfile: string = guild_id.fileName()
    discard guild_id.createGuildUsersFile()
    return serverfile.readFile().parseJson().to(Table[string, Player])


proc getGuildUser*(guild_id, user_id: string): Player =
    let playerTable: Table[string, Player] = guild_id.loadGuildUsers()
    if not playerTable.hasKey(user_id):
        return Player(
            id: user_id
        )
    return playerTable[user_id]


proc writeGuildUsers*(guild_id: string, playerTable: Table[string, Player]): (bool, string) =
    let
        serverFile: string = guild_id.fileName()
        jsonString: string = $(%playerTable)
    
    try:
        serverFile.writeFile(jsonString)
        return (true, "Successfully written changes to disk!")
    except Exception as e:
        e.entry(&"Could not save guild users file ({serverFile})!")
        return (false, "Unable to write to disk, changes will not be saved.")


proc writeGuildUser*(guild_id: string, player: Player): (bool, string) =
    var playerTable: Table[string, Player] = guild_id.loadGuildUsers()
    playerTable[player.id] = player
    return guild_id.writeGuildUsers(playerTable)



