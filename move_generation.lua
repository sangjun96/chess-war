local MoveGeneration = {}

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

function MoveGeneration.offsetKey(columnOffset, rowOffset)
    return columnOffset .. ":" .. rowOffset
end

local function isInside(board, column, row)
    return column >= 0 and column < board.size and row >= 0 and row < board.size
end

local function pieceAt(board, column, row)
    for _, piece in ipairs(board.pieces) do
        if piece.column == column and piece.row == row then return piece end
    end
end

local function addOffset(board, piece, offsets, columnOffset, rowOffset)
    local column, row = piece.column + columnOffset, piece.row + rowOffset
    if not isInside(board, column, row) then return false end
    local occupant = pieceAt(board, column, row)
    if occupant and occupant.team == piece.team then return false end
    offsets[MoveGeneration.offsetKey(columnOffset, rowOffset)] = {
        columnOffset = columnOffset,
        rowOffset = rowOffset,
    }
    return occupant == nil
end

local function addSlidingOffsets(board, piece, offsets, directions)
    for _, direction in ipairs(directions) do
        local columnOffset, rowOffset = direction[1], direction[2]
        while isInside(board, piece.column + columnOffset, piece.row + rowOffset) do
            if not addOffset(board, piece, offsets, columnOffset, rowOffset) then break end
            columnOffset = columnOffset + direction[1]
            rowOffset = rowOffset + direction[2]
        end
    end
end

function MoveGeneration.legalOffsets(board, piece)
    local offsets = {}
    if piece.kind == "pawn" then
        local direction = piece.team == "red" and 1 or -1
        local startRow = piece.team == "red" and 1 or board.size - 2
        if not pieceAt(board, piece.column, piece.row + direction) then
            addOffset(board, piece, offsets, 0, direction)
            if piece.row == startRow and not pieceAt(board, piece.column, piece.row + direction * 2) then
                addOffset(board, piece, offsets, 0, direction * 2)
            end
        end
        for _, columnOffset in ipairs({ -1, 1 }) do
            local target = pieceAt(board, piece.column + columnOffset, piece.row + direction)
            if target and target.team ~= piece.team then
                addOffset(board, piece, offsets, columnOffset, direction)
            end
        end
    elseif piece.kind == "knight" then
        for _, offset in ipairs(knightOffsets) do addOffset(board, piece, offsets, offset[1], offset[2]) end
    elseif piece.kind == "king" then
        for columnOffset = -1, 1 do
            for rowOffset = -1, 1 do
                if columnOffset ~= 0 or rowOffset ~= 0 then
                    addOffset(board, piece, offsets, columnOffset, rowOffset)
                end
            end
        end
    elseif piece.kind == "rook" then
        addSlidingOffsets(board, piece, offsets, rookDirections)
    elseif piece.kind == "bishop" then
        addSlidingOffsets(board, piece, offsets, bishopDirections)
    elseif piece.kind == "queen" then
        addSlidingOffsets(board, piece, offsets, queenDirections)
    end
    return offsets
end

return MoveGeneration
