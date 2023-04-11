import os, options, tables, json, strutils, strformat
import ../globals, ../fileio/logger, typedefs

proc fileName(guild_id: string): string =
    return &"{$dirNations}{guild_id}.json"


proc createGuildFile(guild_id: string): bool =
    let serverFile: string = guild_id.fileName()
    try:
        if not serverFile.fileExists():
            serverFile.writeFile("{}")
        return true
    except Exception as e:
        e.entry("Could not cwrite new guild nation file.")
        return false


proc loadGuildNationsAsJson*(guild_id: string): JsonNode =
    let serverFile: string = guild_id.fileName()
    discard createGuildFile(guild_id)
    return serverFile.readFile().parseJson()


proc loadGuildNations*(guild_id: string): Table[string, Nation] =
    guild_id.loadGuildNationsAsJson().to(Table[string, Nation])


proc cacheGuildNationsData*(guild_id: string) =
    let data: Table[string, Nation] = guild_id.loadGuildNations()
    var cache: seq[Nation]

    for _, nation in data:
        cache.add(nation)
    nation_cache[guild_id] = cache


proc initNationCache*() =
    let suffix: string = ".json"
    for file in walkDir($dirNations):
        if file.kind != pcFile: continue
        if not file.path.endsWith(suffix): continue
        try:
            let guild_id: string = file.path.split('/')[^1][0..^suffix.len() + 1]
            guild_id.cacheGuildNationsData()
        except Exception as e:
            e.entry()


proc writeGuildNations*(guild_id: string, nations: Table[string, Nation]): (bool, string) =
    let
        serverFile: string = guild_id.fileName()
        jsonString: string = $(%nations)

    try:
        serverFile.writeFile(jsonString)
        return (true, "Successfully written changes to disk!")
    except Exception as e:
        e.entry(&"Could not save guild nation file ({serverFile})!")
        return (false, "Unable to write to disk, changes will not be saved.")
    finally:
        guild_id.cacheGuildNationsData()


proc writeGuildNation*(guild_id: string, nation: Nation): (bool, string) =
    var nationTable: Table[string, Nation] = loadGuildNations(guild_id)
    nationTable[nation.name] = nation
    return writeGuildNations(guild_id, nationTable)


