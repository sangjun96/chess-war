local PieceHealth = {}

local stats = {
    pawn = { maxHp = 3, attack = 1 },
    knight = { maxHp = 5, attack = 2 },
    bishop = { maxHp = 5, attack = 2 },
    rook = { maxHp = 7, attack = 2 },
    queen = { maxHp = 9, attack = 3 },
    king = { maxHp = 12, attack = 2 },
}

function PieceHealth.create(kind)
    local stat = stats[kind]
    return { hp = stat.maxHp, maxHp = stat.maxHp, attack = stat.attack }
end

function PieceHealth.damage(piece, amount)
    piece.hp = math.max(0, piece.hp - amount)
    return piece.hp == 0
end

return PieceHealth
