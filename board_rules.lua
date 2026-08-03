local MoveGeneration = require("move_generation")
local Combat = require("combat")

local Rules = {}

function Rules.targetKey(column, row)
    if column == nil or row == nil then return nil end
    return column .. ":" .. row
end

function Rules.pieceAt(board, column, row)
    for _, piece in ipairs(board.pieces) do
        if piece.column == column and piece.row == row then return piece end
    end
end

function Rules.isInside(board, column, row)
    return column ~= nil and row ~= nil
        and column >= 0 and column < board.size and row >= 0 and row < board.size
end

function Rules.isMoveTarget(board, column, row)
    if column == nil or row == nil then return false end
    return board.moveTargets[Rules.targetKey(column, row)] == true
end

function Rules.selectedPieces(board)
    local pieces = {}
    for piece in pairs(board.selectedPieces) do table.insert(pieces, piece) end
    return pieces
end

function Rules.selectedPiece(board)
    local pieces = Rules.selectedPieces(board)
    return #pieces == 1 and pieces[1] or nil
end

local function isLegalFormationMove(board, pieces, offset)
    local key = MoveGeneration.offsetKey(offset.columnOffset, offset.rowOffset)
    local movingPieces = {}
    for _, piece in ipairs(pieces) do movingPieces[piece] = true end
    for _, piece in ipairs(pieces) do
        local target = Rules.pieceAt(board, piece.column + offset.columnOffset, piece.row + offset.rowOffset)
        if (target and movingPieces[target]) or not MoveGeneration.legalOffsets(board, piece)[key] then return false end
    end
    return true
end

local function commonOffsets(board, pieces)
    local common = MoveGeneration.legalOffsets(board, pieces[1])
    for index = 2, #pieces do
        local offsets = MoveGeneration.legalOffsets(board, pieces[index])
        for key in pairs(common) do
            if not offsets[key] then common[key] = nil end
        end
    end
    for key, offset in pairs(common) do if not isLegalFormationMove(board, pieces, offset) then common[key] = nil end end
    return common
end

local function addFormationTargets(board, pieces, offsets)
    board.moveTargets, board.moveCommands = {}, {}
    for _, offset in pairs(offsets) do
        for _, piece in ipairs(pieces) do
            local column = piece.column + offset.columnOffset
            local row = piece.row + offset.rowOffset
            local key = Rules.targetKey(column, row)
            board.moveTargets[key] = true
            board.moveCommands[key] = board.moveCommands[key] or {}
            table.insert(board.moveCommands[key], offset)
        end
    end
end

function Rules.beginMove(board)
    local pieces = Rules.selectedPieces(board)
    if #pieces == 0 then return false, "Select a piece to move." end

    local offsets = commonOffsets(board, pieces)
    if next(offsets) == nil then
        return false, "The selected pieces do not share a legal move."
    end

    board.movingPieces = pieces
    addFormationTargets(board, pieces, offsets)
    return true
end

function Rules.isMoving(board)
    return board.movingPieces ~= nil
end

function Rules.cancelMove(board)
    board.moveTargets = {}
    board.moveCommands = {}
    board.movingPieces = nil
end

function Rules.moveTo(board, column, row)
    if not board.movingPieces or column == nil or row == nil then return false end
    local commands = board.moveCommands[Rules.targetKey(column, row)]
    if not commands then return false end

    for _, offset in ipairs(commands) do
        if isLegalFormationMove(board, board.movingPieces, offset) then
            local destroyed, damaged = false, false
            for _, piece in ipairs(board.movingPieces) do
                local target = Rules.pieceAt(board, piece.column + offset.columnOffset, piece.row + offset.rowOffset)
                local targetDestroyed, targetDamaged = Combat.resolve(board, piece, target)
                destroyed = destroyed or targetDestroyed
                damaged = damaged or targetDamaged
                if not target or targetDestroyed then
                    piece.column = piece.column + offset.columnOffset
                    piece.row = piece.row + offset.rowOffset
                end
            end
            Rules.cancelMove(board)
            return true, destroyed, damaged
        end
    end
    return false
end

return Rules
