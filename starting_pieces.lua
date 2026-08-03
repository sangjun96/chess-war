local PieceHealth = require("piece_health")
local PieceSkills = require("piece_skills")

local StartingPieces = {}

local armyRank = {
    "rook", "rook", "knight", "knight", "bishop", "bishop", "knight", "queen",
    "king", "knight", "bishop", "bishop", "knight", "knight", "rook", "rook",
}

local function createPiece(column, row, kind, team)
    local health = PieceHealth.create(kind)
    return {
        column = column,
        row = row,
        kind = kind,
        team = team,
        hp = health.hp,
        maxHp = health.maxHp,
        attack = health.attack,
        skillId = PieceSkills.skillFor(kind),
    }
end

function StartingPieces.create(size)
    local pieces = {}
    for column, kind in ipairs(armyRank) do
        local boardColumn = column - 1
        table.insert(pieces, createPiece(boardColumn, 0, kind, "red"))
        table.insert(pieces, createPiece(boardColumn, 1, "pawn", "red"))
        table.insert(pieces, createPiece(boardColumn, size - 2, "pawn", "blue"))
        table.insert(pieces, createPiece(boardColumn, size - 1, kind, "blue"))
    end
    return pieces
end

return StartingPieces
