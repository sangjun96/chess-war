local Board = require("board")
local Controller = require("ai_controller")
local GameFlow = require("game_flow")

return function()
    local board = Board.new(16, 68, 1, nil)
    local flow = GameFlow.new(board, "red")
    local effects = { isBusy = function() return false end }
    local controller = Controller.new(board, flow, effects, "easy", 7, false)
    assert(not controller:canHumanAct())
    for _ = 1, 120 do controller:update(0.02) end
    assert(flow.activeTeam == "blue" and flow.turnNumber == 2)
    assert(controller:canHumanAct() and board:selectedCount() == 0)
    local advanced = 0
    for _, pawn in ipairs(board.pieces) do
        if pawn.team == "red" and pawn.kind == "pawn" and pawn.row > 1 then advanced = advanced + 1 end
    end
    assert(advanced > 1, "The AI opening should be able to execute a multi-pawn formation.")
end
