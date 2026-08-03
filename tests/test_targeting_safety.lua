local Rules = require("board_rules")
local SkillAttack = require("skill_attack")

return function()
    local mover = { column = 1, row = 1, kind = "pawn", team = "red" }
    local moveBoard = {
        size = 8,
        pieces = { mover },
        moveTargets = {},
        moveCommands = {},
        movingPieces = { mover },
    }
    assert(not Rules.isInside(moveBoard, nil, nil))
    assert(not Rules.isMoveTarget(moveBoard, nil, nil))
    assert(not Rules.moveTo(moveBoard, nil, nil))

    local attacker = {
        column = 1, row = 1, kind = "pawn", team = "red", attack = 1, skillId = "impact",
    }
    local skillBoard = {
        size = 8,
        pieces = { attacker },
        selectedPieces = { [attacker] = true },
        skillTargets = {},
    }
    assert(SkillAttack.begin(skillBoard))
    SkillAttack.previewAt(skillBoard, nil, nil)
    assert(not SkillAttack.execute(skillBoard, nil, nil))
    assert(skillBoard.attackingPieces ~= nil)
end
