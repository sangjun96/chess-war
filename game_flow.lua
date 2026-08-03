local GameFlow = {}
GameFlow.__index = GameFlow

local nextTeam = {
    red = "blue",
    blue = "red",
}

local teamName = {
    red = "Red",
    blue = "Blue",
}

local function selectionBelongsTo(board, team)
    local count = 0
    for piece in pairs(board.selectedPieces) do
        if piece.team ~= team then return false end
        count = count + 1
    end
    return count > 0
end

function GameFlow.new(board, startingTeam)
    local self = setmetatable({
        board = board,
        activeTeam = startingTeam or "red",
        winner = nil,
        finished = false,
    }, GameFlow)
    self.status = self:turnStatus()
    return self
end

function GameFlow:isPlaying()
    return not self.finished
end

function GameFlow:turnStatus()
    return teamName[self.activeTeam] .. " turn. Select a " .. self.activeTeam .. " piece."
end

function GameFlow:canSelect(piece)
    return self:isPlaying() and piece ~= nil and piece.team == self.activeTeam
end

function GameFlow:canAct()
    if not self:isPlaying() then return false, "Game over. " .. teamName[self.winner] .. " wins."
    end
    if not selectionBelongsTo(self.board, self.activeTeam) then
        return false, "Select a " .. self.activeTeam .. " piece first."
    end
    return true
end

function GameFlow:beginMove()
    local valid, message = self:canAct()
    if not valid then return false, message end
    return self.board:beginMove()
end

function GameFlow:beginAttack()
    local valid, message = self:canAct()
    if not valid then return false, message end
    return self.board:beginAttack()
end

function GameFlow:hasKing(team)
    for _, piece in ipairs(self.board.pieces) do
        if piece.team == team and piece.kind == "king" then return true end
    end
    return false
end

function GameFlow:finishIfKingRemoved()
    local defeatedTeam
    if not self:hasKing("red") then
        defeatedTeam = "red"
    elseif not self:hasKing("blue") then
        defeatedTeam = "blue"
    end
    if not defeatedTeam then return false end

    self.winner = nextTeam[defeatedTeam]
    self.finished = true
    self.board:clearSelection()
    self.status = teamName[self.winner] .. " wins! The " .. defeatedTeam .. " king was removed."
    return true
end

function GameFlow:completeAction(action)
    if self:finishIfKingRemoved() then return end
    self.activeTeam = nextTeam[self.activeTeam]
    self.board:clearSelection()
    self.status = teamName[self.activeTeam] .. " turn. " .. action .. " complete."
end

function GameFlow:moveTo(column, row)
    if not self:isPlaying() then return false end
    local moved, destroyed, damaged = self.board:moveTo(column, row)
    if moved then self:completeAction("Move") end
    return moved, destroyed, damaged
end

function GameFlow:attackAt(column, row)
    if not self:isPlaying() then return false end
    local fired, destroyed, damaged, targets = self.board:attackAt(column, row)
    if fired then self:completeAction("Skill") end
    return fired, destroyed, damaged, targets
end

return GameFlow
