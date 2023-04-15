import os, sets, strutils, strformat, tables, json, options, sequtils, times
import dimscord
import ../globals, ../fileio/logger, typedefs, filehandler, users


# -----------------------------------------------------------------------------
# Nation Procs:
# -----------------------------------------------------------------------------

const
    invalid_nation_characters: HashSet[char] = toHashSet ['"', '\\', '/', '`', '*']
    max_nation_character_length*: int = 32
    time_format_creation_date*: string = "yyyy-MM-dd HH:mm"

proc getGuildNations(guild_id: string): seq[Nation] =
    if not nation_cache.hasKey(guild_id): return
    for nation in nation_cache[guild_id]:
        result.add(nation)
    return result

proc getGuildNationByOwner*(guild_id, owner_id: string): Option[Nation] =
    let nations: seq[Nation] = guild_id.getGuildNations()
    for nation in nations:
        if nation.owner_id == owner_id:
            result = some nation
            break
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
        owner_id: owner_id,
        creation_date: some now().utc().format(time_format_creation_date)
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


proc modifyNation*(i: Interaction, field_name: string, max_length: int = 9999): (bool, string) =
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
    elif new_value.get().len() > max_length:
        return (false, &"Max length of {max_length} exceeded. (try to remove {new_value.get().len() - max_length} characters)")

    return modifyNationField[string](guild_id, user_nation.get(), field_name, new_value.get())


proc resetNationField*[T](i: Interaction, field: string): (bool, string) =
    let
        guild_id: string = i.guild_id.get()
        owner_id: string = i.member.get().user.id
        nation_maybe: Option[Nation] = guild_id.getGuildNationByOwner(owner_id)

    if nation_maybe.isNone():
        return (false, &"You are not an owner of any nation. You cannot reset its '{field}' field!")

    var
        nation: Nation = nation_maybe.get()
        nationJson: JsonNode = %nation
    nationJson[field] = %none T
    nation = nationJson.to(Nation)

    return guild_id.writeGuildNation(nation)


proc addUserToNation*(guild_id, user_id, nation_name: string): (bool, string) =
    var
        nation_maybe: Option[Nation] = guild_id.getGuildNationByName(nation_name)
        members: seq[string]
    
    if nation_maybe.isNone(): return (false, "The requested nation does not exist.")
    var nation: Nation = nation_maybe.get()

    if nation.member_ids.isSome():
        members = nation.member_ids.get()
    members.add(user_id)
    nation.member_ids = some members
    return guild_id.writeGuildNation(nation)


proc removeUserFromNation*(guild_id, user_id, nation_name: string): (bool, string) =
    var nation_maybe: Option[Nation] = guild_id.getGuildNationByName(nation_name)

    if nation_maybe.isNone(): return (false, "Requested nation does not exist.")
    var nation: Nation = nation_maybe.get()

    let owner_text: string = " Owners cannot leave a nation, they have to permanently delete them!"
    if nation.member_ids.isNone(): return (false, "The nation does not have any members." & owner_text)
    let member_list: seq[string] = nation.member_ids.get()

    if user_id notin member_list: return (false, "Member not in this nation..." & owner_text)

    var members: seq[string]
    for i in members:
        if i == user_id: continue
        members.add(i)
    
    nation.member_ids = some members
    return guild_id.writeGuildNation(nation)


proc deleteNation*(i: Interaction, nation_name: string): (bool, string) =
    let
        guild_id: string = i.guild_id.get()
        user_id: string = i.member.get().user.id
        nation_maybe: Option[Nation] = guild_id.getGuildNationByName(nation_name)

    if nation_maybe.isNone():
        return (false, "You do not rule this nation, you cannot delete it. Did you make a typo in the name?")
    let nation_to_del: Nation = nation_maybe.get()
    if nation_to_del.owner_id != user_id:
        return (false, "You cannot delete this nation. You are not the owner.")

    var nations: Table[string, Nation]
    for name, nation in guild_id.loadGuildNations():
        if name == nation_to_del.name: continue
        nations[name] = nation

    return guild_id.writeGuildNations(nations)



# -----------------------------------------------------------------------------
# User Procs:
# -----------------------------------------------------------------------------

proc linkMinecraftUsername*(guild_id, user_id, minecraft_username: string): (bool, string) =
    let valid_chars: HashSet[char] = toHashSet toSeq[char]("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_")

    # Name length check:
    if minecraft_username.len() < 3 or minecraft_username.len() > 16:
        return (false, "Invalid minecraft username. It has to be a value between 3 and 16 (both values inclusive)!")

    # Valid chars check:
    let
        name_chars: HashSet[char] = toHashSet toSeq[char](minecraft_username)
        diff: HashSet[char] = name_chars.difference(valid_chars)
    if diff.len() != 0:
        return (false, &"""Invalid minecraft username. Invalid characters included: ```{$diff}```""")

    var player: Player = guild_id.getGuildUser(user_id)
    player.player_name = some minecraft_username
    guild_id.writeGuildUser(player)


proc sendPlayerInvite*(guild_id, user_id, nation_name: string): (bool, string) =
    var player: Player = guild_id.getGuildUser(user_id)
    let success_invite_text: string = &"<@{user_id}> has been invited to join `{nation_name}`!"

    # No current invites, add invite and return:
    if player.invite_list.isNone():
        player.invite_list = some @[nation_name]
        let status = guild_id.writeGuildUser(player)
        if status[0]: return (true, success_invite_text)
        else: return status

    # Check if already in nation:
    let nation: Nation = guild_id.getGuildNationByName(nation_name).get()
    if nation.member_ids.isSome():
        if user_id in nation.member_ids.get():
            return (false, "This user is already in your nation.")

    # Check if already invited:
    var invites: seq[string] = player.invite_list.get()
    if nation_name in invites:
        return (false, "Invite already pending...")
    
    # Add invite and write to disk:
    invites.add(nation_name)
    player.invite_list = some invites
    let status = guild_id.writeGuildUser(player)
    if status[0]: return (true, success_invite_text)
    else: return status


proc sendPlayerInvite*(i: Interaction, target_id: string): (bool, string) =
    let
        guild_id: string = i.guild_id.get()
        owner_id: string = i.member.get().user.id
        nation_maybe: Option[Nation] = guild_id.getGuildNationByOwner(owner_id)
    if nation_maybe.isNone():
        return (false, "You do not rule a nation, you cannot invite people.")
    return guild_id.sendPlayerInvite(target_id, nation_maybe.get().name)


proc getPendingInvites*(guild_id, user_id: string): string =
    let
        player: Player = guild_id.getGuildUser(user_id)
        no_invites_text: string = "You do not have any pending invites."
        bullet_point: string = "⤷"
    
    if player.invite_list.isNone():
        return no_invites_text

    let invites: seq[string] = player.invite_list.get()
    if invites.len() == 0:
        return no_invites_text

    return bullet_point & invites.join("\n" & bullet_point)


proc removePendingInvite(player: var Player, nation_name: string) =
    if player.invite_list.isNone(): return
    var invites: seq[string]
    for i in player.invite_list.get():
        if i == nation_name: continue
        invites.add(i)
    player.invite_list = some invites


proc nationInviteAct*(guild_id, user_id, nation_name: string, accept: bool): (bool, string) =
    var player: Player = guild_id.getGuildUser(user_id)

    if accept:
        let status = guild_id.addUserToNation(user_id, nation_name)
        if not status[0]: return status

    player.removePendingInvite(nation_name)
    let status = guild_id.writeGuildUser(player)
    if not status[0]: return status

    if accept:
        return (true, &"Invite to `{nation_name}` was accepted.")
    else:
        return (true, &"Invite to `{nation_name}` was declined.")

