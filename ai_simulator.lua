local Rules = require("board_rules")
local SkillAttack = require("skill_attack")
local State = require("ai_state")

local Simulator = {}

local nextTeam = { red = "blue", blue = "red" }

function Simulator.apply(state, action)
    local result = State.clone(state)
    if not State.select(result, action.actorIds) then return nil, "missing actor" end
    local anchor = State.find(result, action.anchorId)
    if not anchor then return nil, "missing anchor" end
    local column = anchor.column + action.columnOffset
    local row = anchor.row + action.rowOffset
    local acted, destroyed, damaged, targets
    if action.type == "move" then
        if not Rules.beginMove(result) then return nil, "illegal move selection" end
        acted, destroyed, damaged = Rules.moveTo(result, column, row)
    elseif action.type == "skill" then
        if not SkillAttack.begin(result) then return nil, "illegal skill selection" end
        acted, destroyed, damaged, targets = SkillAttack.execute(result, column, row)
    end
    if not acted then return nil, "illegal target" end
    result.activeTeam = nextTeam[state.activeTeam]
    return result, {
        destroyed = destroyed == true,
        damaged = damaged == true,
        targets = targets or (damaged and 1 or 0),
        kingRemoved = not State.hasKing(result, result.activeTeam),
    }
end

function Simulator.winner(state)
    if not State.hasKing(state, "red") then return "blue" end
    if not State.hasKing(state, "blue") then return "red" end
end

return Simulator
