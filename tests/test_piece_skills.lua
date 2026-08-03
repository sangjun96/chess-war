local PieceSkills = require("piece_skills")
local SkillCatalog = require("skill_catalog")
local StartingPieces = require("starting_pieces")

return function()
    assert(PieceSkills.validate())
    assert(PieceSkills.skillFor("king") == "royal_calamity")
    assert(SkillCatalog.get("defense") == nil)
    for _, piece in ipairs(StartingPieces.create(16)) do
        assert(piece.skillId == PieceSkills.skillFor(piece.kind))
        local skill = SkillCatalog.get(piece.skillId)
        assert(type(skill.range) == "number" and skill.range > 0)
        assert(type(skill.effectRadius) == "number" and skill.effectRadius >= 0)
        assert(#skill.layers >= 3, piece.kind .. " should combine multiple attack effects.")
    end

    local original = PieceSkills.assignments.pawn
    PieceSkills.assignments.pawn = "lightning"
    local pieces = StartingPieces.create(16)
    for _, piece in ipairs(pieces) do
        if piece.kind == "pawn" then assert(piece.skillId == "lightning") end
    end

    PieceSkills.assignments.pawn = "missing-skill"
    local valid, message = pcall(PieceSkills.validate)
    assert(not valid)
    assert(message:find("unknown skill", 1, true))
    PieceSkills.assignments.pawn = original
    assert(PieceSkills.validate())
end
