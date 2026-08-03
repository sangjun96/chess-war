local Rules = require("board_rules")

return function()
    local attacker = {
        column = 0,
        row = 0,
        kind = "pawn",
        team = "red",
        attack = 1,
        skillId = "impact",
    }
    local target = {
        column = 1,
        row = 1,
        kind = "pawn",
        team = "blue",
        hp = 3,
        maxHp = 3,
    }
    local triggered
    local board = {
        size = 4,
        pieces = { attacker, target },
        selectedPieces = { [attacker] = true },
        movingPieces = { attacker },
        moveTargets = { ["1:1"] = true },
        moveCommands = { ["1:1"] = { { columnOffset = 1, rowOffset = 1 } } },
        skillEffects = {
            trigger = function(_, ...)
                triggered = { ... }
            end,
        },
    }

    local moved, destroyed, damaged = Rules.moveTo(board, 1, 1)
    assert(moved and not destroyed and damaged)
    assert(target.hp == 2)
    assert(attacker.column == 0 and attacker.row == 0)
    assert(triggered == nil)
end
