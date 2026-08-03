local Combat = require("combat")
local SkillCatalog = require("skill_catalog")

local SkillAttack = {}

local function key(column, row)
    return column .. ":" .. row
end

local function distance(firstColumn, firstRow, secondColumn, secondRow)
    return math.abs(firstColumn - secondColumn) + math.abs(firstRow - secondRow)
end

function SkillAttack.isTarget(board, column, row)
    return column ~= nil and row ~= nil and board.skillTargets[key(column, row)] == true
end

function SkillAttack.isPreviewTarget(board, column, row)
    return column ~= nil and row ~= nil and board.skillPreviewTargets[key(column, row)] == true
end

function SkillAttack.begin(board)
    local piece = board:selectedPiece()
    if not piece then return false, "Select exactly one piece to use a skill." end

    local definition = SkillCatalog.get(piece.skillId)
    assert(definition, "Unknown skill '" .. tostring(piece.skillId) .. "'.")
    assert(definition.range and definition.effectRadius,
        "Skill '" .. piece.skillId .. "' needs range and effectRadius values.")

    board.skillTargets = {}
    board.skillPreviewTargets = {}
    for column = 0, board.size - 1 do
        for row = 0, board.size - 1 do
            local targetDistance = distance(piece.column, piece.row, column, row)
            if targetDistance > 0 and targetDistance <= definition.range then
                board.skillTargets[key(column, row)] = true
            end
        end
    end
    board.attackingPiece = piece
    return true, (definition.name or "Skill") .. ": range " .. definition.range .. ", effect radius "
        .. definition.effectRadius .. ". Click an orange tile to fire without moving."
end

function SkillAttack.previewAt(board, column, row)
    board.skillPreviewTargets = {}
    if not SkillAttack.isTarget(board, column, row) then return end

    local definition = SkillCatalog.get(board.attackingPiece.skillId)
    if definition.effectRadius <= 0 then return end

    for previewColumn = 0, board.size - 1 do
        for previewRow = 0, board.size - 1 do
            if distance(previewColumn, previewRow, column, row) <= definition.effectRadius then
                board.skillPreviewTargets[key(previewColumn, previewRow)] = true
            end
        end
    end
end

function SkillAttack.cancel(board)
    board.skillTargets = {}
    board.skillPreviewTargets = {}
    board.attackingPiece = nil
end

function SkillAttack.execute(board, column, row)
    local attacker = board.attackingPiece
    if not attacker or not SkillAttack.isTarget(board, column, row) then return false end

    local definition = SkillCatalog.get(attacker.skillId)
    if board.skillEffects then
        board.skillEffects:trigger(attacker.skillId,
            attacker.column, attacker.row, column, row)
    end

    local victims = {}
    for _, piece in ipairs(board.pieces) do
        if piece.team ~= attacker.team
            and distance(piece.column, piece.row, column, row) <= definition.effectRadius then
            table.insert(victims, piece)
        end
    end

    local destroyed, damaged = false, false
    for _, victim in ipairs(victims) do
        local targetDestroyed, targetDamaged = Combat.resolve(board, attacker, victim)
        destroyed = destroyed or targetDestroyed
        damaged = damaged or targetDamaged
    end
    SkillAttack.cancel(board)
    return true, destroyed, damaged, #victims
end

return SkillAttack
