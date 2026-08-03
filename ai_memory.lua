local Actions = require("ai_actions")

local Memory = {}
Memory.__index = Memory

function Memory.new()
    return setmetatable({ recent = {}, focusId = nil }, Memory)
end

function Memory:bonus(action)
    local bonus = 0
    for _, targetId in ipairs(action.meta.targetIds or {}) do
        if targetId == self.focusId then bonus = bonus + 15 end
    end
    local last = self.recent[#self.recent]
    if last and last.anchorId == action.anchorId
        and last.columnOffset == -action.columnOffset and last.rowOffset == -action.rowOffset then
        bonus = bonus - 25
    end
    return math.max(-25, math.min(25, bonus))
end

function Memory:record(action)
    self.recent[#self.recent + 1] = {
        key = Actions.key(action), anchorId = action.anchorId,
        columnOffset = action.columnOffset, rowOffset = action.rowOffset,
    }
    while #self.recent > 4 do table.remove(self.recent, 1) end
    if action.meta.targetIds and action.meta.targetIds[1] then self.focusId = action.meta.targetIds[1] end
end

return Memory
