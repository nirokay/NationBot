import tables, options

type
    Nation* = object
        name*: string
        nickname*, desc*, wiki_link*, flag_link*, map_link*: Option[string]
        colour*: Option[int]

        owner_id*: string
        member_ids*: Option[seq[string]]
    
    Player* = object
        id*: string
        player_name*: Option[string]
        invite_list*: Option[seq[string]]


var nation_cache* {.global.}: Table[string, seq[Nation]] # only used for reading, not writing!

