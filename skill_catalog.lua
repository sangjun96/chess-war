local skills = {
    impact = require("skill_definitions.pawn"),
    lightning = require("skill_definitions.knight"),
    absorb = require("skill_definitions.bishop"),
    explosion = require("skill_definitions.rook"),
    sparkle = require("skill_definitions.queen"),
    royal_calamity = require("skill_definitions.king"),
}

local SkillCatalog = {}

function SkillCatalog.get(skillId)
    return skills[skillId]
end

function SkillCatalog.all()
    return skills
end

return SkillCatalog
