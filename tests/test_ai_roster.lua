local Board = require("board")
local GameFlow = require("game_flow")
local Roster = require("ai_roster")

return function()
    local board = Board.new(16, 68, 1, nil)
    local flow = GameFlow.new(board, "red")
    local effects = { isBusy = function() return false end }
    local mode = { redDifficulty = "easy", blueDifficulty = "easy", automated = true }
    local roster = Roster.new(board, flow, effects, mode, 17)

    assert(roster.automated and not roster:canHumanAct())
    for _ = 1, 320 do
        roster:update(0.02)
        if flow.turnNumber >= 3 then break end
    end
    assert(flow.turnNumber == 3 and flow.activeTeam == "red",
        "An automated roster should complete consecutive Red and Blue turns.")
end
