local State = {}

local function copyPiece(piece, index)
    return {
        id = piece.id or string.format("%s-%s-%02d", piece.team, piece.kind, index),
        column = piece.column,
        row = piece.row,
        kind = piece.kind,
        team = piece.team,
        hp = piece.hp,
        maxHp = piece.maxHp,
        attack = piece.attack,
        skillId = piece.skillId,
    }
end

local function make(size, pieces, activeTeam)
    return {
        size = size,
        pieces = pieces,
        activeTeam = activeTeam,
        selectedPieces = {},
        moveTargets = {},
        moveCommands = {},
        skillTargets = {},
        skillCommands = {},
        skillPreviewTargets = {},
    }
end

function State.snapshot(board, activeTeam)
    local pieces = {}
    for index, piece in ipairs(board.pieces) do pieces[index] = copyPiece(piece, index) end
    return make(board.size, pieces, activeTeam)
end

function State.clone(state)
    local pieces = {}
    for index, piece in ipairs(state.pieces) do pieces[index] = copyPiece(piece, index) end
    return make(state.size, pieces, state.activeTeam)
end

function State.find(state, id)
    for _, piece in ipairs(state.pieces) do
        if piece.id == id then return piece end
    end
end

function State.select(state, actorIds)
    state.selectedPieces = {}
    for _, id in ipairs(actorIds) do
        local piece = State.find(state, id)
        if not piece then return false end
        state.selectedPieces[piece] = true
    end
    return true
end

function State.hasKing(state, team)
    for _, piece in ipairs(state.pieces) do
        if piece.team == team and piece.kind == "king" then return true end
    end
    return false
end

function State.hash(state)
    local parts = { state.activeTeam }
    local pieces = {}
    for _, piece in ipairs(state.pieces) do pieces[#pieces + 1] = piece end
    table.sort(pieces, function(a, b) return a.id < b.id end)
    for _, piece in ipairs(pieces) do
        parts[#parts + 1] = table.concat({ piece.id, piece.column, piece.row, piece.hp }, ":")
    end
    return table.concat(parts, "|")
end

return State
