local AIController = require("ai_controller")

local Roster = {}
Roster.__index = Roster

function Roster.new(board, flow, effects, mode, seed)
    local controllers = {
        red = AIController.new(board, flow, effects, mode.redDifficulty, seed, false, "red"),
    }
    if mode.automated then
        controllers.blue = AIController.new(board, flow, effects,
            mode.blueDifficulty, seed + 104729, false, "blue")
    end
    return setmetatable({ controllers = controllers, flow = flow, automated = mode.automated }, Roster)
end

function Roster:update(dt)
    self.controllers.red:update(dt)
    if self.controllers.blue then self.controllers.blue:update(dt) end
end

function Roster:canHumanAct()
    return not self.automated and self.controllers.red:canHumanAct()
end

function Roster:status()
    local controller = self.controllers[self.flow.activeTeam]
    return controller and controller:status() or nil
end

return Roster
