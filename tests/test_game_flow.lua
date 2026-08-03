local GameFlow = require("game_flow")

local function boardWith(pieces, selected)
    return {
        pieces = pieces,
        selectedPieces = selected or {},
        clearSelection = function(self) self.selectedPieces = {} end,
        beginMove = function() return true end,
        beginAttack = function() return true end,
        moveTo = function() return true, false, false end,
    }
end

return function()
    local redKing = { kind = "king", team = "red" }
    local blueKing = { kind = "king", team = "blue" }
    local redPawn = { kind = "pawn", team = "red" }
    local board = boardWith({ redKing, blueKing, redPawn }, { [redPawn] = true })
    local flow = GameFlow.new(board)

    assert(flow.activeTeam == "red" and flow:canSelect(redPawn))
    assert(not flow:canSelect(blueKing))
    assert(flow:beginMove())
    assert(flow:moveTo(1, 1))
    assert(flow.activeTeam == "blue" and flow.turnNumber == 2 and next(board.selectedPieces) == nil)

    board.selectedPieces = { [redPawn] = true }
    local winningFlow = GameFlow.new(board)
    board.attackAt = function(self)
        self.pieces = { redKing, redPawn }
        return true, true, true, 1
    end
    assert(winningFlow:beginAttack())
    assert(winningFlow:attackAt(1, 1))
    assert(winningFlow.finished and winningFlow.winner == "red")
    assert(not winningFlow:isPlaying())
    local valid, message = winningFlow:canAct()
    assert(not valid and message:find("Game over", 1, true))
end
