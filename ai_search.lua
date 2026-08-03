local Actions = require("ai_actions")
local Core = require("ai_search_core")

local Search = {}
Search.__index = Search

local function quickFallback(actions)
    local ranked = {}
    for _, action in ipairs(actions or {}) do ranked[#ranked + 1] = { action = action, score = action.meta.quick } end
    table.sort(ranked, function(a, b) return a.score > b.score end)
    return ranked
end

local function choose(ranked, profile, random)
    if not ranked or not ranked[1] then return nil end
    if ranked[1].action.meta.kingKill then return ranked[1].action end
    local best, choices, total = ranked[1].score, {}, 0
    for _, item in ipairs(ranked) do
        local regret = best - item.score
        if regret <= profile.regret then
            local weight = math.exp(-regret / profile.temperature)
            choices[#choices + 1], total = { item = item, weight = weight }, total + weight
        end
    end
    local target = random:next() * total
    for _, choice in ipairs(choices) do
        target = target - choice.weight
        if target <= 0 then return choice.item.action end
    end
    return choices[#choices].item.action
end

function Search.new(state, team, profile, random, memory)
    state.activeTeam = team
    local self = setmetatable({
        state = state, profile = profile, random = random, memory = memory,
        core = Core.new(profile, true), done = false, completedDepth = 0,
    }, Search)
    self.thread = coroutine.create(function() self:work() end)
    return self
end

function Search:work()
    local fallback
    for depth = 1, self.profile.depth do
        local ranked, actions = self.core:root(self.state, depth, self.memory)
        fallback = fallback or actions
        if not ranked then break end
        self.ranked, self.completedDepth = ranked, depth
    end
    self.ranked = self.ranked or quickFallback(fallback or self.core:generate(self.state))
    self.action = choose(self.ranked, self.profile, self.random)
    self.done = true
end

function Search:step()
    if self.done then return true end
    local ok, message = coroutine.resume(self.thread)
    if not ok then error(message) end
    if coroutine.status(self.thread) == "dead" then self.done = true end
    return self.done
end

function Search:run()
    while not self.done do self:step() end
    return self:result()
end

function Search:result()
    if not self.done then return nil end
    return self.action, {
        nodes = self.core.nodes,
        depth = self.completedDepth,
        ranked = self.ranked,
        cancelled = self.core.cancelled,
    }
end

return Search
