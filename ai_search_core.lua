local Actions = require("ai_actions")
local Evaluator = require("ai_evaluator")
local Simulator = require("ai_simulator")
local State = require("ai_state")
local TacticalPotential = require("ai_tactical_potential")

local Core = {}
Core.__index = Core

function Core.new(profile, cooperative)
    return setmetatable({
        profile = profile, cooperative = cooperative, nodes = 0, started = os.clock(), cancelled = false, cache = {},
    }, Core)
end

function Core:checkpoint()
    if self.cooperative then coroutine.yield() end
end

function Core:touch()
    if self.nodes >= self.profile.nodeBudget or os.clock() - self.started >= self.profile.timeBudget then
        self.cancelled = true
        return false
    end
    self.nodes = self.nodes + 1
    self:checkpoint()
    return true
end

function Core:generate(state)
    return Actions.generate(state, state.activeTeam, function() self:checkpoint() end)
end

function Core:limited(state, tacticalOnly)
    local generated, result, seen = self:generate(state), {}, {}
    local function include(action)
        local key = Actions.key(action)
        if not seen[key] then seen[key], result[#result + 1] = true, action end
    end
    for _, action in ipairs(generated) do
        if action.meta.preserve and (not tacticalOnly or action.meta.tactical) then include(action) end
    end
    local limit = tacticalOnly and math.min(12, self.profile.beam) or self.profile.beam
    for _, action in ipairs(generated) do
        if (not tacticalOnly or action.meta.tactical) and #result < limit then include(action) end
    end
    table.sort(result, function(a, b) return a.meta.quick > b.meta.quick end)
    return result
end

function Core:qsearch(state, depth, alpha, beta)
    if not self:touch() then return nil end
    local stand = Evaluator.score(state, state.activeTeam)
    if depth <= 0 or stand >= beta then return stand end
    if not TacticalPotential.has(state, state.activeTeam) then return stand end
    if stand > alpha then alpha = stand end
    for _, action in ipairs(self:limited(state, true)) do
        local child = Simulator.apply(state, action)
        if child then
            local reply = self:qsearch(child, depth - 1, -beta, -alpha)
            if reply == nil then return nil end
            local score = -reply
            if score >= beta then return score end
            if score > alpha then alpha = score end
        end
    end
    return alpha
end

function Core:negamax(state, depth, alpha, beta)
    if not self:touch() then return nil end
    if Simulator.winner(state) then return Evaluator.score(state, state.activeTeam) end
    if depth <= 0 then return self:qsearch(state, self.profile.qDepth, alpha, beta) end
    if not TacticalPotential.has(state, state.activeTeam) then
        return Evaluator.score(state, state.activeTeam)
    end
    local cacheKey = depth .. ":" .. State.hash(state)
    if self.cache[cacheKey] then return self.cache[cacheKey] end
    local best, cutoff = -math.huge, false
    local actions = self:limited(state, false)
    if #actions == 0 then return Evaluator.score(state, state.activeTeam) end
    for _, action in ipairs(actions) do
        local child = Simulator.apply(state, action)
        if child then
            local reply = self:negamax(child, depth - 1, -beta, -alpha)
            if reply == nil then return nil end
            local score = -reply
            if score > best then best = score end
            if score > alpha then alpha = score end
            if alpha >= beta then cutoff = true break end
        end
    end
    if not cutoff then self.cache[cacheKey] = best end
    return best
end

function Core:root(state, depth, memory)
    local actions, ranked = self:limited(state, false), {}
    local alpha = -math.huge
    for _, action in ipairs(actions) do
        local child = Simulator.apply(state, action)
        if child then
            local reply = self:negamax(child, depth - 1, -math.huge, -alpha)
            if reply == nil then return nil, actions end
            local rawScore = -reply
            local score = rawScore + (memory and memory:bonus(action) or 0)
            ranked[#ranked + 1] = { action = action, score = score }
            if rawScore > alpha then alpha = rawScore end
        end
    end
    table.sort(ranked, function(a, b) return a.score > b.score end)
    return ranked, actions
end

return Core
