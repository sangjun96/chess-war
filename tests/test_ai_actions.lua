local Actions = require("ai_actions")
local Simulator = require("ai_simulator")
local StartingPieces = require("starting_pieces")
local State = require("ai_state")

local function piece(id, column, row, kind, team, hp, attack, skillId)
    return { id = id, column = column, row = row, kind = kind, team = team,
        hp = hp, maxHp = hp, attack = attack, skillId = skillId }
end

return function()
    local opening = State.snapshot({ size = 16, pieces = StartingPieces.create(16) }, "red")
    local openingActions, formationSizes = Actions.generate(opening, "red"), {}
    for _, action in ipairs(openingActions) do formationSizes[#action.actorIds] = true end
    assert(formationSizes[1] and formationSizes[2] and formationSizes[4])
    assert(formationSizes[8] and formationSizes[16], "The full pawn line must be an AI candidate.")

    local pieces = {
        piece("red-king", 0, 0, "king", "red", 12, 2, "royal_calamity"),
        piece("blue-king", 7, 7, "king", "blue", 12, 2, "royal_calamity"),
    }
    for column = 1, 4 do
        pieces[#pieces + 1] = piece("red-pawn-" .. column, column, 1, "pawn", "red", 3, 1, "impact")
        pieces[#pieces + 1] = piece("blue-pawn-" .. column, column, 3, "pawn", "blue", 3, 1, "impact")
    end
    local state = State.snapshot({ size = 8, pieces = pieces }, "red")
    local volley
    for _, action in ipairs(Actions.generate(state, "red")) do
        if action.type == "skill" and #action.actorIds == 4
            and action.columnOffset == 0 and action.rowOffset == 2 then volley = action break end
    end
    assert(volley and volley.meta.hits == 4 and volley.meta.damage == 4)
    local result = assert(Simulator.apply(state, volley))
    for _, target in ipairs(result.pieces) do
        if target.team == "blue" and target.kind == "pawn" then assert(target.hp == 2) end
    end
end
