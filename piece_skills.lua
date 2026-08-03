local SkillCatalog = require("skill_catalog")

local PieceSkills = {
    assignments = {
        pawn = "impact",
        knight = "lightning",
        bishop = "absorb",
        rook = "explosion",
        queen = "sparkle",
        king = "royal_calamity",
    },
}

local pieceKinds = { "pawn", "knight", "bishop", "rook", "queen", "king" }

function PieceSkills.skillFor(pieceKind)
    local skillId = PieceSkills.assignments[pieceKind]
    assert(skillId, "No skill is assigned to piece type '" .. tostring(pieceKind) .. "'.")
    assert(SkillCatalog.get(skillId),
        "Piece type '" .. pieceKind .. "' references unknown skill '" .. tostring(skillId) .. "'.")
    return skillId
end

function PieceSkills.validate()
    for _, pieceKind in ipairs(pieceKinds) do PieceSkills.skillFor(pieceKind) end
    return true
end

return PieceSkills
