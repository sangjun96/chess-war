local Logger = {}
Logger.__index = Logger

local function reasons(action)
    local result = {}
    if action.meta.kingKill then result[#result + 1] = "king_kill" end
    if action.meta.kills > 0 then result[#result + 1] = "finish" end
    if action.meta.hits > 1 then result[#result + 1] = "multi_hit" end
    if action.meta.damage == 0 then result[#result + 1] = "advance" end
    return #result > 0 and table.concat(result, ",") or "pressure"
end

function Logger.new(enabled, sink)
    return setmetatable({ enabled = enabled == true, sink = sink or print, last = nil }, Logger)
end

function Logger:record(turn, difficulty, action, info)
    local top = {}
    for index = 1, math.min(5, #(info.ranked or {})) do
        local item = info.ranked[index]
        top[#top + 1] = string.format("%s=%.1f", item.action.type, item.score)
    end
    self.last = {
        turn = turn, difficulty = difficulty, action = action,
        nodes = info.nodes, depth = info.depth, top = top, reasons = reasons(action),
    }
    if self.enabled then
        self.sink(string.format("[AI] turn=%d level=%s depth=%d nodes=%d action=%s actors=%d reasons=%s top=%s",
            turn, difficulty, info.depth or 0, info.nodes or 0, action.type, #action.actorIds,
            self.last.reasons, table.concat(top, ";")))
    end
end

return Logger
