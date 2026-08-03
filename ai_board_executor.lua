local Executor = {}

local function pieceById(board, id)
    for _, piece in ipairs(board.pieces) do
        if piece.id == id then return piece end
    end
end

function Executor.select(board, action)
    board:clearSelection()
    for _, id in ipairs(action.actorIds) do
        local piece = pieceById(board, id)
        if not piece then board:clearSelection() return false end
        board.selectedPieces[piece] = true
    end
    return true
end

function Executor.prepare(board, flow, action)
    local anchor = pieceById(board, action.anchorId)
    if not anchor or not Executor.select(board, action) then return false end
    local started
    if action.type == "move" then started = flow:beginMove() else started = flow:beginAttack() end
    if not started then board:clearSelection() return false end
    return true, anchor.column + action.columnOffset, anchor.row + action.rowOffset
end

function Executor.execute(flow, action, column, row)
    if action.type == "move" then return flow:moveTo(column, row) end
    return flow:attackAt(column, row)
end

return Executor
