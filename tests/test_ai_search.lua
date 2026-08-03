local Actions = require("ai_actions")
local Memory = require("ai_memory")
local Profiles = require("ai_profiles")
local Random = require("ai_random")
local Search = require("ai_search")
local Simulator = require("ai_simulator")
local State = require("ai_state")

local function piece(id, column, row, kind, team, hp, maxHp, attack, skillId)
    return { id = id, column = column, row = row, kind = kind, team = team,
        hp = hp, maxHp = maxHp, attack = attack, skillId = skillId }
end

return function()
    local pieces = {
        piece("red-king", 0, 0, "king", "red", 12, 12, 2, "royal_calamity"),
        piece("red-rook", 1, 1, "rook", "red", 7, 7, 2, "explosion"),
        piece("blue-king", 4, 1, "king", "blue", 2, 12, 2, "royal_calamity"),
    }
    local state = State.snapshot({ size = 8, pieces = pieces }, "red")
    local action = Search.new(state, "red", Profiles.get("easy"), Random.new(42), Memory.new()):run()
    assert(action and action.meta.kingKill, "Every difficulty must take an immediate king kill.")
    local result = assert(Simulator.apply(state, action))
    assert(Simulator.winner(result) == "red")

    local first = Search.new(State.clone(state), "red", Profiles.get("easy"),
        Random.new(77), Memory.new()):run()
    local second = Search.new(State.clone(state), "red", Profiles.get("easy"),
        Random.new(77), Memory.new()):run()
    assert(Actions.key(first) == Actions.key(second))
end
