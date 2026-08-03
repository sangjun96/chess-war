local Actions = require("ai_actions")
local Executor = require("ai_board_executor")
local Logger = require("ai_logger")
local Memory = require("ai_memory")
local Profiles = require("ai_profiles")
local Random = require("ai_random")
local Search = require("ai_search")
local State = require("ai_state")

local Controller = {}
Controller.__index = Controller

function Controller.new(board, flow, effects, difficulty, seed, debugLog)
    return setmetatable({
        board = board, flow = flow, effects = effects, difficulty = difficulty,
        profile = Profiles.get(difficulty), random = Random.new(seed), memory = Memory.new(),
        logger = Logger.new(debugLog), phase = "idle", elapsed = 0, retries = 0,
    }, Controller)
end

function Controller:startThinking()
    self.board:clearSelection()
    local state = State.snapshot(self.board, "red")
    self.search = Search.new(state, "red", self.profile, self.random, self.memory)
    self.phase, self.elapsed = "thinking", 0
end

function Controller:showAction(action, info)
    self.action, self.searchInfo = action, info
    if not action or not Executor.select(self.board, action) then return self:recover() end
    self.phase, self.elapsed = "show_selection", 0
end

function Controller:recover()
    self.board:clearSelection()
    self.retries = self.retries + 1
    if self.retries <= 1 then return self:startThinking() end
    local state = State.snapshot(self.board, "red")
    local fallback = Actions.generate(state, "red")[1]
    self.retries = 0
    if fallback then return self:showAction(fallback, { nodes = 0, depth = 0, ranked = {} }) end
    self.phase = "idle"
end

function Controller:update(dt)
    if not self.flow:isPlaying() then self.phase = "idle" return end
    if self.flow.activeTeam == "blue" then
        self.phase = self.effects:isBusy() and "settling" or "idle"
        return
    end
    if self.phase == "idle" or self.phase == "settling" then self:startThinking() end
    self.elapsed = self.elapsed + dt
    if self.phase == "thinking" then
        -- One coroutine slice per frame guarantees the renderer gets a turn
        -- before the AI continues its search.
        self.search:step()
        local action, info = self.search:result()
        if action and self.elapsed >= self.profile.thinkDelay and not self.effects:isBusy() then
            self:showAction(action, info)
        end
    elseif self.phase == "show_selection" and self.elapsed >= 0.25 then
        local prepared, column, row = Executor.prepare(self.board, self.flow, self.action)
        if not prepared then return self:recover() end
        self.targetColumn, self.targetRow = column, row
        self.phase, self.elapsed = "show_target", 0
    elseif self.phase == "show_target" and self.elapsed >= 0.25 then
        local acted = Executor.execute(self.flow, self.action, self.targetColumn, self.targetRow)
        if not acted then return self:recover() end
        self.memory:record(self.action)
        self.logger:record(self.flow.turnNumber - 1, self.difficulty, self.action, self.searchInfo)
        self.retries, self.phase, self.elapsed = 0, "settling", 0
    end
end

function Controller:canHumanAct()
    return self.flow:isPlaying() and self.flow.activeTeam == "blue"
        and self.phase == "idle" and not self.effects:isBusy()
end

function Controller:status()
    local labels = {
        thinking = "RED AI THINKING", show_selection = "RED AI SELECTING",
        show_target = "RED AI TARGETING", settling = "RESOLVING ACTION",
    }
    return labels[self.phase]
end

return Controller
