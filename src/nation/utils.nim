import os, sets, strutils, strformat, tables, json
import dimscord
import ../globals, ../fileio/logger, typedefs, filehandler

const invalid_nation_characters: HashSet[char] = toHashSet ['"', '\\', '/']

proc getGuildNations(guild_id: string): seq[Nation] =
    if not nation_cache.hasKey(guild_id): return
    for nation in nation_cache[guild_id]:
        result.add(nation)
    return result


proc getCurrentNationNames*(guild_id: string): seq[string] =
    for nation in guild_id.getGuildNations():
        result.add(nation.name)
    return result


proc nationNameIsValid(name: string): bool =
    let name_set: HashSet[char] = toHashSet(name)
    return invalid_nation_characters.intersection(name_set).len() == 0


proc createNation*(guild_id, nation_name, owner_id: string): (bool, string) =
    # Validity checks:
    if not nation_name.strip().nationNameIsValid(): return (false, &"Name contains invalid characters: ({$invalid_nation_characters})")
    for existing_nation in guild_id.getGuildNations():
        # Assigned owner check:
        if owner_id == existing_nation.owner_id:
            return (false, &"You already rule a nation. To form another you have to abandon your current one.")
        # Existing names check:
        if nation_name.toLower().strip() == existing_nation.name.toLower().strip():
            return (false, &"The nation name '{nation_name}' already exists. Please try another name!")        

    # Create Nation:
    return guild_id.writeGuildNation(Nation(
        name: nation_name.strip(),
        owner_id: owner_id
    ))


proc modifyNationField*[T](guild_id, nation_name, field_name: string, new_value: T): (bool, string) =
    try:
        var
            nation: Nation = guild_id.loadGuildNations()[nation_name]
            nationJson: JsonNode = %nation
        nationJson[field_name] = %new_value
        nation = nationJson.to(Nation)
        return(true, &"Successfully set field '{field_name}' to value '{$new_value}'!")
    except Exception as e:
        e.entry()
        return (false, &"Could not set field '{field_name}' to value '{$new_value}'...")


proc modifyNation*[T](i: Interaction): (bool, string) =
    let
        guild_id: string = i.guild_id.get()
        user: User = i.member.user.get()
    return

