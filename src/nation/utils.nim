import os, sets, strutils, strformat, tables, json, options
import dimscord
import ../globals, ../fileio/logger, typedefs, filehandler

const
    invalid_nation_characters: HashSet[char] = toHashSet ['"', '\\', '/', '`', '*']
    max_nation_character_length: int = 32

proc getGuildNations(guild_id: string): seq[Nation] =
    if not nation_cache.hasKey(guild_id): return
    for nation in nation_cache[guild_id]:
        result.add(nation)
    return result

proc getGuildNationByName*(guild_id, nation_name: string): Option[Nation] =
    let nations: seq[Nation] = guild_id.getGuildNations()
    for nation in nations:
        if nation_name == nation.name:
            return some nation


proc getCurrentNationNames*(guild_id: string): seq[string] =
    for nation in guild_id.getGuildNations():
        result.add(nation.name)
        if nation.nickname.isSome():
            result[^1].add(&" ({nation.nickname.get()})")
    if result.len() == 0:
        result.add("`no nations were created yet...`")
    return result


proc getUserNationName*(guild_id, user_id: string): Option[string] =
    let nations: seq[Nation] = guild_id.getGuildNations()
    for nation in nations:
        if nation.owner_id == user_id:
            result = some nation.name
            break
    return result


proc nationNameIsValid(name: string): bool =
    let
        name_set: HashSet[char] = toHashSet(name)
        charsCheck: bool = invalid_nation_characters.intersection(name_set).len() == 0
        lengthCheck: bool = name.len() <= max_nation_character_length
    return charsCheck and lengthCheck


proc getInvalidNationChars(): seq[char] =
    for i in invalid_nation_characters.items:
        result.add(i)
    return result

proc createNation*(guild_id, nation_name, owner_id: string): (bool, string) =
    # Validity checks:
    if not nation_name.strip().nationNameIsValid(): return (false, &"""Name is too long (max length: {max_nation_character_length}) or contains invalid characters: {getInvalidNationChars().join(" ")}""")
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

        let status = guild_id.writeGuildNation(nation)
        if status[0]:
            return (true, &"Successfully set field '{field_name}' to value '{$new_value}'!")
        else: return (false, &"Could not set field '{field_name}' to value '{$new_value}'...")
    except Exception as e:
        e.entry()
        return (false, &"Could not set field '{field_name}' to value '{$new_value}'...")


proc modifyNation*(i: Interaction, field_name: string): (bool, string) =
    let
        data: ApplicationCommandInteractionData = i.data.get()
        guild_id: string = i.guild_id.get()
        user: User = i.member.get().user
    var
        new_value: Option[string]
    
    # Users nation check and assignment:
    let user_nation: Option[string] = getUserNationName(guild_id, user.id)
    if user_nation.isNone():
        return (false, "You are not an owner of any nation.")
    
    # This will probably need to be changed in future:
    for i, value in data.options:
        new_value = some value.str
    
    if new_value.isNone():
        return (false, "Received empty data.")
    
    echo field_name
    return modifyNationField[string](guild_id, user_nation.get(), field_name, new_value.get())



