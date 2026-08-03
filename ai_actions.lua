local Rules = require("board_rules")
local SkillAttack = require("skill_attack")
local State = require("ai_state")
local Formations = require("ai_formations")
local Meta = require("ai_action_meta")

local Actions = {}

local function viewFor(state, actorIds)
    local view = {
        size = state.size, pieces = state.pieces, selectedPieces = {},
        moveTargets = {}, moveCommands = {}, skillTargets = {}, skillCommands = {},
        skillPreviewTargets = {},
    }
    local actors = {}
    for _, id in ipairs(actorIds) do
        local piece = State.find(state, id)
        if not piece then return nil end
        view.selectedPieces[piece], actors[#actors + 1] = true, piece
    end
    table.sort(actors, function(a, b) return a.id < b.id end)
    return view, actors
end

local function actionKey(action)
    return table.concat({ action.type, table.concat(action.actorIds, ","),
        action.columnOffset, action.rowOffset }, "|")
end

local function add(result, seen, kind, actors, offset, meta)
    local actorIds = {}
    for _, actor in ipairs(actors) do actorIds[#actorIds + 1] = actor.id end
    local action = {
        type = kind,
        actorIds = actorIds,
        anchorId = actorIds[1],
        columnOffset = offset.columnOffset,
        rowOffset = offset.rowOffset,
        meta = meta,
    }
    action.meta.formationSize = #actorIds
    action.meta.preserve = action.meta.kingKill or (kind == "move" and actors[1].kind == "king")
    local key = actionKey(action)
    if not seen[key] then seen[key], result[#result + 1] = true, action end
end

local function offsetsFrom(commands)
    local offsets, seen = {}, {}
    for _, list in pairs(commands) do
        for _, offset in ipairs(list) do
            local key = offset.columnOffset .. ":" .. offset.rowOffset
            if not seen[key] then seen[key], offsets[#offsets + 1] = true, offset end
        end
    end
    return offsets
end

local function addSelection(state, actorIds, result, seen, emptySkills)
    local view, actors = viewFor(state, actorIds)
    if not view then return end
    if Rules.beginMove(view) then
        for _, offset in ipairs(offsetsFrom(view.moveCommands)) do
            add(result, seen, "move", actors, offset,
                Meta.move(state, actors, offset.columnOffset, offset.rowOffset))
        end
        Rules.cancelMove(view)
    end
    if SkillAttack.begin(view) then
        for _, offset in ipairs(offsetsFrom(view.skillCommands)) do
            local meta = Meta.skill(state, actors, offset.columnOffset, offset.rowOffset)
            if meta.damage > 0 then
                add(result, seen, "skill", actors, offset, meta)
            elseif not emptySkills[1] then
                emptySkills[1] = { actors = actors, offset = offset, meta = meta }
            end
        end
        SkillAttack.cancel(view)
    end
end

function Actions.generate(state, team)
    local result, seen, emptySkills = {}, {}, {}
    for _, piece in ipairs(state.pieces) do
        if piece.team == team then addSelection(state, { piece.id }, result, seen, emptySkills) end
    end
    for _, actorIds in ipairs(Formations.groups(state, team)) do
        addSelection(state, actorIds, result, seen, emptySkills)
    end
    if #result == 0 and emptySkills[1] then
        local fallback = emptySkills[1]
        add(result, seen, "skill", fallback.actors, fallback.offset, fallback.meta)
    end
    table.sort(result, function(a, b)
        if a.meta.quick == b.meta.quick then return actionKey(a) < actionKey(b) end
        return a.meta.quick > b.meta.quick
    end)
    return result
end

function Actions.key(action) return actionKey(action) end

return Actions
