local SkillAttack = require("skill_attack")

return function()
    local attacker = {
        column = 1,
        row = 1,
        kind = "rook",
        team = "red",
        attack = 2,
        skillId = "explosion",
    }
    local directTarget = {
        column = 5,
        row = 2,
        kind = "pawn",
        team = "blue",
        hp = 2,
        maxHp = 3,
    }
    local areaTarget = {
        column = 5,
        row = 3,
        kind = "bishop",
        team = "blue",
        hp = 5,
        maxHp = 5,
    }
    local friendly = {
        column = 4,
        row = 2,
        kind = "pawn",
        team = "red",
        hp = 3,
        maxHp = 3,
    }
    local effect
    local board = {
        size = 8,
        pieces = { attacker, directTarget, areaTarget, friendly },
        skillTargets = {},
        selectedPiece = function() return attacker end,
        skillEffects = {
            trigger = function(_, ...)
                effect = { ... }
            end,
        },
    }

    local started = SkillAttack.begin(board)
    assert(started and board.attackingPiece == attacker)
    assert(SkillAttack.isTarget(board, 5, 2))
    assert(not SkillAttack.isTarget(board, 7, 2))

    SkillAttack.previewAt(board, 5, 2)
    assert(SkillAttack.isPreviewTarget(board, 5, 2))
    assert(SkillAttack.isPreviewTarget(board, 4, 2))
    assert(SkillAttack.isPreviewTarget(board, 5, 3))
    assert(not SkillAttack.isPreviewTarget(board, 4, 3))

    SkillAttack.previewAt(board, 7, 2)
    assert(next(board.skillPreviewTargets) == nil)

    local fired, destroyed, damaged, count = SkillAttack.execute(board, 5, 2)
    assert(fired and destroyed and damaged and count == 2)
    assert(attacker.column == 1 and attacker.row == 1)
    assert(areaTarget.hp == 3)
    assert(friendly.hp == 3)
    assert(effect[1] == "explosion")
    assert(effect[2] == 1 and effect[3] == 1)
    assert(effect[4] == 5 and effect[5] == 2)
    assert(board.attackingPiece == nil and next(board.skillTargets) == nil)
    assert(next(board.skillPreviewTargets) == nil)

    board.selectedPiece = function() return nil end
    local valid, message = SkillAttack.begin(board)
    assert(not valid and message:find("Select a piece", 1, true))

    local firstPawn = {
        column = 1, row = 1, kind = "pawn", team = "red", attack = 1, skillId = "impact",
    }
    local secondPawn = {
        column = 2, row = 1, kind = "pawn", team = "red", attack = 1, skillId = "impact",
    }
    local firstTarget = {
        column = 3, row = 1, kind = "pawn", team = "blue", hp = 3, maxHp = 3,
    }
    local secondTarget = {
        column = 4, row = 1, kind = "pawn", team = "blue", hp = 3, maxHp = 3,
    }
    local formationEffects = {}
    local formationBoard = {
        size = 8,
        pieces = { firstPawn, secondPawn, firstTarget, secondTarget },
        selectedPieces = { [firstPawn] = true, [secondPawn] = true },
        skillTargets = {},
        skillEffects = {
            trigger = function(_, ...)
                table.insert(formationEffects, { ... })
            end,
        },
    }

    started = SkillAttack.begin(formationBoard)
    assert(started and formationBoard.attackingPieces[1] and formationBoard.attackingPieces[2])
    assert(SkillAttack.isTarget(formationBoard, 4, 1))

    fired, destroyed, damaged, count = SkillAttack.execute(formationBoard, 4, 1)
    assert(fired and not destroyed and damaged and count == 2)
    assert(firstTarget.hp == 2 and secondTarget.hp == 2)
    assert(#formationEffects == 2)
    local effectTargets = {}
    for _, effect in ipairs(formationEffects) do
        effectTargets[effect[4] .. ":" .. effect[5]] = true
    end
    assert(effectTargets["3:1"] and effectTargets["4:1"])
end
