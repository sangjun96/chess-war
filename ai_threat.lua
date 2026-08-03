local MoveGeneration = require("move_generation")
local SkillCatalog = require("skill_catalog")

local Threat = {}

local function kingFor(state, team)
    for _, piece in ipairs(state.pieces) do
        if piece.team == team and piece.kind == "king" then return piece end
    end
end

local function skillCanHit(state, attacker, target)
    local definition = SkillCatalog.get(attacker.skillId)
    for dc = -definition.range, definition.range do
        for dr = -definition.range, definition.range do
            local range = math.abs(dc) + math.abs(dr)
            local column, row = attacker.column + dc, attacker.row + dr
            local hitDistance = math.abs(target.column - column) + math.abs(target.row - row)
            if range > 0 and range <= definition.range and column >= 0 and column < state.size
                and row >= 0 and row < state.size and hitDistance <= definition.effectRadius then
                return true
            end
        end
    end
    return false
end

local function moveCanHit(state, attacker, target)
    local dc, dr = target.column - attacker.column, target.row - attacker.row
    return MoveGeneration.legalOffsets(state, attacker)[MoveGeneration.offsetKey(dc, dr)] ~= nil
end

function Threat.king(state, team)
    local king = kingFor(state, team)
    if not king then return { damage = 1000000, lethal = true } end
    local maximum, attackers = 0, 0
    for _, piece in ipairs(state.pieces) do
        if piece.team ~= team and (skillCanHit(state, piece, king) or moveCanHit(state, piece, king)) then
            maximum = math.max(maximum, piece.attack)
            attackers = attackers + 1
        end
    end
    return { damage = maximum, lethal = maximum >= king.hp, attackers = attackers }
end

function Threat.pressure(state, team)
    local score = 0
    for _, attacker in ipairs(state.pieces) do
        if attacker.team == team then
            local definition = SkillCatalog.get(attacker.skillId)
            local targets = 0
            for _, target in ipairs(state.pieces) do
                local distance = math.abs(attacker.column - target.column) + math.abs(attacker.row - target.row)
                if target.team ~= team and distance <= definition.range + definition.effectRadius then
                    targets = targets + 1
                end
            end
            score = score + math.min(targets, 3) * attacker.attack * 8
        end
    end
    return score
end

return Threat
