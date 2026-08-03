local PieceHealth = require("piece_health")

local Combat = {}

function Combat.resolve(board, attacker, target)
    if not target then return false, false end
    if not PieceHealth.damage(target, attacker.attack) then return false, true end
    for index, piece in ipairs(board.pieces) do
        if piece == target then table.remove(board.pieces, index); break end
    end
    return true, true
end

return Combat
