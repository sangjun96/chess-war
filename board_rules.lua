local Rules = {}

local knightOffsets = {
    { 1, 2 }, { 2, 1 }, { 2, -1 }, { 1, -2 },
    { -1, -2 }, { -2, -1 }, { -2, 1 }, { -1, 2 },
}
local rookDirections = { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }
local bishopDirections = { { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } }
local queenDirections = {
    { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 },
    { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 },
}

function Rules.targetKey(column, row)
    return column .. ":" .. row
end

function Rules.pieceAt(board, column, row)
    for _, piece in ipairs(board.pieces) do
        if piece.column == column and piece.row == row then return piece end
    end
end

function Rules.isInside(board, column, row)
    return column >= 0 and column < board.size and row >= 0 and row < board.size
end

function Rules.isMoveTarget(board, column, row)
    return board.moveTargets[Rules.targetKey(column, row)] == true
end

function Rules.selectedPiece(board)
    local piece = nil
    for selected in pairs(board.selectedPieces) do
        if piece then return nil end
        piece = selected
    end
    return piece
end

local function addMoveTarget(board, piece, column, row)
    if not Rules.isInside(board, column, row) then return false end
    local occupant = Rules.pieceAt(board, column, row)
    if occupant and occupant.team == piece.team then return false end
    board.moveTargets[Rules.targetKey(column, row)] = true
    return occupant == nil
end

local function addSlidingMoveTargets(board, piece, directions)
    for _, direction in ipairs(directions) do
        local column, row = piece.column + direction[1], piece.row + direction[2]
        while Rules.isInside(board, column, row) do
            if not addMoveTarget(board, piece, column, row) then break end
            column, row = column + direction[1], row + direction[2]
        end
    end
end

function Rules.beginMove(board)
    local piece = Rules.selectedPiece(board)
    if not piece then return false, "Select exactly one piece to move." end
    board.moveTargets = {}
    board.movingPiece = piece

    if piece.kind == "pawn" then
        local direction = piece.team == "red" and 1 or -1
        local startRow = piece.team == "red" and 1 or board.size - 2
        local nextRow = piece.row + direction
        if Rules.isInside(board, piece.column, nextRow) and not Rules.pieceAt(board, piece.column, nextRow) then
            board.moveTargets[Rules.targetKey(piece.column, nextRow)] = true
            local doubleRow = piece.row + direction * 2
            if piece.row == startRow and not Rules.pieceAt(board, piece.column, doubleRow) then
                board.moveTargets[Rules.targetKey(piece.column, doubleRow)] = true
            end
        end
        for _, column in ipairs({ piece.column - 1, piece.column + 1 }) do
            local target = Rules.pieceAt(board, column, nextRow)
            if target and target.team ~= piece.team then
                board.moveTargets[Rules.targetKey(column, nextRow)] = true
            end
        end
    elseif piece.kind == "knight" then
        for _, offset in ipairs(knightOffsets) do addMoveTarget(board, piece, piece.column + offset[1], piece.row + offset[2]) end
    elseif piece.kind == "king" then
        for columnOffset = -1, 1 do
            for rowOffset = -1, 1 do
                if columnOffset ~= 0 or rowOffset ~= 0 then
                    addMoveTarget(board, piece, piece.column + columnOffset, piece.row + rowOffset)
                end
            end
        end
    elseif piece.kind == "rook" then
        addSlidingMoveTargets(board, piece, rookDirections)
    elseif piece.kind == "bishop" then
        addSlidingMoveTargets(board, piece, bishopDirections)
    elseif piece.kind == "queen" then
        addSlidingMoveTargets(board, piece, queenDirections)
    end

    if next(board.moveTargets) == nil then
        Rules.cancelMove(board)
        return false, "This piece has no valid moves."
    end
    return true
end

function Rules.isMoving(board)
    return board.movingPiece ~= nil
end

function Rules.cancelMove(board)
    board.moveTargets = {}
    board.movingPiece = nil
end

function Rules.moveTo(board, column, row)
    if not board.movingPiece or column == nil or row == nil or not Rules.isMoveTarget(board, column, row) then return false end
    local captured = Rules.pieceAt(board, column, row)
    if captured then
        for index, piece in ipairs(board.pieces) do
            if piece == captured then table.remove(board.pieces, index); break end
        end
    end
    board.movingPiece.column, board.movingPiece.row = column, row
    Rules.cancelMove(board)
    return true, captured
end

return Rules
