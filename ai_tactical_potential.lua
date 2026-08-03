local MoveGeneration = require("move_generation")
local SkillCatalog = require("skill_catalog")

local Potential = {}

function Potential.has(state, team)
    for _, attacker in ipairs(state.pieces) do
        if attacker.team == team then
            local moves = MoveGeneration.legalOffsets(state, attacker)
            local definition = SkillCatalog.get(attacker.skillId)
            for _, target in ipairs(state.pieces) do
                if target.team ~= team then
                    local dc, dr = target.column - attacker.column, target.row - attacker.row
                    local distance = math.abs(dc) + math.abs(dr)
                    if moves[MoveGeneration.offsetKey(dc, dr)]
                        or distance <= definition.range + definition.effectRadius then
                        return true
                    end
                end
            end
        end
    end
    return false
end

return Potential
