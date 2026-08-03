local Combat = require("combat")
local SkillCatalog = require("skill_catalog")

local SkillAttack = {}

local function key(column, row)
    return column .. ":" .. row
end

local function distance(firstColumn, firstRow, secondColumn, secondRow)
    return math.abs(firstColumn - secondColumn) + math.abs(firstRow - secondRow)
end

local function selectedPieces(board)
    -- Board exposes the whole selection for formation actions.  Keeping the
    -- selectedPiece fallback makes the skill module usable by small test and
    -- tool boards that only provide the original single-selection API.
    if board.selectedPieces then
        local pieces = {}
        for piece in pairs(board.selectedPieces) do table.insert(pieces, piece) end
        table.sort(pieces, function(first, second)
            if first.column == second.column then return first.row < second.row end
            return first.column < second.column
        end)
        return pieces
    end
    local piece = board:selectedPiece()
    return piece and { piece } or {}
end

local function isInside(board, column, row)
    return column >= 0 and column < board.size and row >= 0 and row < board.size
end

local function addFormationTargets(board, pieces, definition)
    board.skillTargets, board.skillCommands = {}, {}
    for columnOffset = -definition.range, definition.range do
        for rowOffset = -definition.range, definition.range do
            local offsetDistance = distance(0, 0, columnOffset, rowOffset)
            if offsetDistance > 0 and offsetDistance <= definition.range then
                local valid = true
                for _, piece in ipairs(pieces) do
                    if not isInside(board, piece.column + columnOffset, piece.row + rowOffset) then
                        valid = false
                        break
                    end
                end
                if valid then
                    local offset = { columnOffset = columnOffset, rowOffset = rowOffset }
                    for _, piece in ipairs(pieces) do
                        local targetKey = key(piece.column + columnOffset, piece.row + rowOffset)
                        board.skillTargets[targetKey] = true
                        board.skillCommands[targetKey] = board.skillCommands[targetKey] or {}
                        table.insert(board.skillCommands[targetKey], offset)
                    end
                end
            end
        end
    end
end

function SkillAttack.isTarget(board, column, row)
    return column ~= nil and row ~= nil and board.skillTargets[key(column, row)] == true
end

function SkillAttack.isPreviewTarget(board, column, row)
    return column ~= nil and row ~= nil and board.skillPreviewTargets[key(column, row)] == true
end

function SkillAttack.begin(board)
    local pieces = selectedPieces(board)
    if #pieces == 0 then return false, "Select a piece to use a skill." end

    local definition = SkillCatalog.get(pieces[1].skillId)
    assert(definition, "Unknown skill '" .. tostring(pieces[1].skillId) .. "'.")
    assert(definition.range and definition.effectRadius,
        "Skill '" .. pieces[1].skillId .. "' needs range and effectRadius values.")
    for index = 2, #pieces do
        if pieces[index].skillId ~= pieces[1].skillId then
            return false, "The selected pieces must use the same skill."
        end
    end

    addFormationTargets(board, pieces, definition)
    if next(board.skillTargets) == nil then
        return false, "The selected pieces do not share a valid skill target."
    end
    board.skillPreviewTargets = {}
    board.attackingPieces = pieces
    -- Retain this field for integrations that still inspect the original
    -- single-attacker state.
    board.attackingPiece = pieces[1]
    return true, (definition.name or "Skill") .. ": range " .. definition.range .. ", effect radius "
        .. definition.effectRadius .. ". Click an orange tile to fire the selection in formation."
end

function SkillAttack.previewAt(board, column, row)
    board.skillPreviewTargets = {}
    if not SkillAttack.isTarget(board, column, row) then return end

    local attackers = board.attackingPieces or { board.attackingPiece }
    local definition = SkillCatalog.get(attackers[1].skillId)
    if definition.effectRadius <= 0 then return end

    for _, offset in ipairs(board.skillCommands[key(column, row)] or {}) do
        for _, attacker in ipairs(attackers) do
            local targetColumn = attacker.column + offset.columnOffset
            local targetRow = attacker.row + offset.rowOffset
            for previewColumn = 0, board.size - 1 do
                for previewRow = 0, board.size - 1 do
                    if distance(previewColumn, previewRow, targetColumn, targetRow) <= definition.effectRadius then
                        board.skillPreviewTargets[key(previewColumn, previewRow)] = true
                    end
                end
            end
        end
    end
end

function SkillAttack.cancel(board)
    board.skillTargets = {}
    board.skillCommands = {}
    board.skillPreviewTargets = {}
    board.attackingPieces = nil
    board.attackingPiece = nil
end

function SkillAttack.execute(board, column, row)
    local attackers = board.attackingPieces or (board.attackingPiece and { board.attackingPiece })
    if column == nil or row == nil then return false end
    local commands = board.skillCommands and board.skillCommands[key(column, row)]
    if not attackers or not commands or not SkillAttack.isTarget(board, column, row) then return false end

    local offset = commands[1]
    local definition = SkillCatalog.get(attackers[1].skillId)
    local destroyed, damaged, targetCount = false, false, 0
    for _, attacker in ipairs(attackers) do
        local targetColumn = attacker.column + offset.columnOffset
        local targetRow = attacker.row + offset.rowOffset
        if board.skillEffects then
            board.skillEffects:trigger(attacker.skillId,
                attacker.column, attacker.row, targetColumn, targetRow)
        end

        local victims = {}
        for _, piece in ipairs(board.pieces) do
            if piece.team ~= attacker.team
                and distance(piece.column, piece.row, targetColumn, targetRow) <= definition.effectRadius then
                table.insert(victims, piece)
            end
        end

        for _, victim in ipairs(victims) do
            local targetDestroyed, targetDamaged = Combat.resolve(board, attacker, victim)
            destroyed = destroyed or targetDestroyed
            damaged = damaged or targetDamaged
            targetCount = targetCount + 1
        end
    end
    SkillAttack.cancel(board)
    return true, destroyed, damaged, targetCount
end

return SkillAttack
