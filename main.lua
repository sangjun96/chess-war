local ActionMenu = require("action_menu")
local AIRoster = require("ai_roster")
local Board = require("board")
local Camera = require("camera")
local CreditsOverlay = require("credits_overlay")
local DifficultyMenu = require("difficulty_menu")
local GameFlow = require("game_flow")
local GameMode = require("game_mode")
local HUD = require("hud")
local Input = require("game_input")
local InputRouter = require("game_event_router")
local PieceSkills = require("piece_skills")
local SkillEffects = require("skill_effects")
local WebViewport = require("web_viewport")
local theme = require("theme")

local skillEffects = SkillEffects.new()
local difficultyMenu = DifficultyMenu.new(theme)
local credits = CreditsOverlay.new(theme)
local fonts = {}
local board, camera, flow, actionMenu, input, ai
local currentModeId = "medium"
local viewport = WebViewport.new()

local function startGame(modeId)
    currentModeId = modeId or currentModeId
    local mode = GameMode.resolve(currentModeId)
    skillEffects:clear()
    credits:close()
    board = Board.new(16, 68, 1.44, skillEffects)
    board:loadAssets("assets/isocubic-chess")
    camera = Camera.new(board.pixels)
    camera:fitToViewport(love.graphics.getDimensions())
    flow = GameFlow.new(board, "red")
    actionMenu = ActionMenu.new(board, flow, theme)
    local seed = os.time() + math.floor(love.timer.getTime() * 1000)
    ai = AIRoster.new(board, flow, skillEffects, mode, seed)
    input = Input.new(board, camera, actionMenu, flow, theme, credits,
        function() return ai:canHumanAct() and not credits.open end)
end

function love.load()
    viewport:apply()
    PieceSkills.validate()
    love.graphics.setBackgroundColor(theme.background)
    love.graphics.setDefaultFilter("nearest", "nearest")
    skillEffects:load()
    fonts.title = love.graphics.newFont(18)
    fonts.body = love.graphics.newFont(12)
    fonts.statusTitle = love.graphics.newFont(26)
    fonts.statusBody = love.graphics.newFont(13)
    fonts.resultTitle = love.graphics.newFont(34)
end

function love.update(dt)
    viewport:update(dt, camera)
    skillEffects:update(dt)
    if difficultyMenu.active or not board then return end
    input:update(dt)
    if not credits.open then ai:update(dt) end
end

function love.draw()
    if board then
        board:draw(camera)
        input:drawSelectionBox()
        HUD.draw(theme, fonts, board, camera, flow, actionMenu.status, ai:status(), ai.automated)
        actionMenu:draw(fonts)
        credits:draw(fonts)
    end
    difficultyMenu:draw(fonts)
end

InputRouter.install({
    difficulty = difficultyMenu,
    credits = credits,
    flow = function() return flow end,
    input = function() return input end,
    startGame = startGame,
    rematch = function() startGame(currentModeId) end,
    showDifficulty = function() credits:close() difficultyMenu:show() end,
})

function love.keypressed(key)
    if difficultyMenu.active then
        local modeId = difficultyMenu:keypressed(key)
        if modeId then startGame(modeId)
        elseif key == "escape" then love.event.quit() end
        return
    end
    if flow and flow.finished then
        if credits:keypressed(key) then return
        elseif key == "r" then startGame(currentModeId)
        elseif key == "m" then credits:close() difficultyMenu:show()
        elseif key == "escape" then love.event.quit() end
        return
    end
    if input then input:keypressed(key) end
end
