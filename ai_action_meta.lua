local SkillCatalog = require("skill_catalog")

local Meta = {}

local function pieceAt(state, column, row)
    for _, piece in ipairs(state.pieces) do
        if piece.column == column and piece.row == row then return piece end
    end
end

local function finish(meta, forward)
    meta.quick = meta.damage * 80 + meta.kills * 140 + meta.hits * 12
        + meta.kingDamage * 500 + (meta.kingKill and 1000000 or 0) + (forward or 0) * 4
    meta.tactical = meta.damage > 0 or meta.kingKill
    return meta
end

function Meta.move(state, actors, columnOffset, rowOffset)
    local meta = { damage = 0, kills = 0, hits = 0, kingDamage = 0, targetIds = {} }
    for _, actor in ipairs(actors) do
        local target = pieceAt(state, actor.column + columnOffset, actor.row + rowOffset)
        if target and target.team ~= actor.team then
            local damage = math.min(actor.attack, target.hp)
            meta.damage, meta.hits = meta.damage + damage, meta.hits + 1
            meta.targetIds[#meta.targetIds + 1] = target.id
            if target.hp <= actor.attack then meta.kills = meta.kills + 1 end
            if target.kind == "king" then
                meta.kingDamage = meta.kingDamage + damage
                meta.kingKill = target.hp <= actor.attack
            end
        end
    end
    local direction = actors[1].team == "red" and 1 or -1
    return finish(meta, rowOffset * direction * #actors)
end

function Meta.skill(state, actors, columnOffset, rowOffset)
    local definition = SkillCatalog.get(actors[1].skillId)
    local meta = { damage = 0, kills = 0, hits = 0, kingDamage = 0, targetIds = {} }
    local remaining, recorded = {}, {}
    for _, piece in ipairs(state.pieces) do remaining[piece] = piece.hp end
    for _, actor in ipairs(actors) do
        local targetColumn = actor.column + columnOffset
        local targetRow = actor.row + rowOffset
        for _, victim in ipairs(state.pieces) do
            local distance = math.abs(victim.column - targetColumn) + math.abs(victim.row - targetRow)
            if victim.team ~= actor.team and remaining[victim] > 0 and distance <= definition.effectRadius then
                local damage = math.min(actor.attack, remaining[victim])
                remaining[victim] = remaining[victim] - damage
                meta.damage, meta.hits = meta.damage + damage, meta.hits + 1
                if not recorded[victim] then
                    recorded[victim] = true
                    meta.targetIds[#meta.targetIds + 1] = victim.id
                end
                if victim.kind == "king" then meta.kingDamage = meta.kingDamage + damage end
                if remaining[victim] == 0 then
                    meta.kills = meta.kills + 1
                    if victim.kind == "king" then meta.kingKill = true end
                end
            end
        end
    end
    return finish(meta)
end

return Meta
