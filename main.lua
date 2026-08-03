local ActionMenu = require("action_menu")
local AIController = require("ai_controller")
local Board = require("board")
local Camera = require("camera")
local CreditsOverlay = require("credits_overlay")
local DifficultyMenu = require("difficulty_menu")
local GameFlow = require("game_flow")
local HUD = require("hud")
local Input = require("game_input")
local PieceSkills = require("piece_skills")
local SkillEffects = require("skill_effects")
local theme = require("theme")

local skillEffects = SkillEffects.new()
local difficultyMenu = DifficultyMenu.new(theme)
local credits = CreditsOverlay.new(theme)
local fonts = {}
local board, camera, flow, actionMenu, input, ai
local currentDifficulty = "medium"

local function startGame(difficulty)
    currentDifficulty = difficulty or currentDifficulty
    skillEffects:clear()
    credits:close()
    board = Board.new(16, 68, 1.44, skillEffects)
    board:loadAssets("assets/isocubic-chess")
    camera = Camera.new(board.pixels)
    flow = GameFlow.new(board, "red")
    actionMenu = ActionMenu.new(board, flow, theme)
    local seed = os.time() + math.floor(love.timer.getTime() * 1000)
    ai = AIController.new(board, flow, skillEffects, currentDifficulty, seed, false)
    input = Input.new(board, camera, actionMenu, flow, theme, credits,
        function() return ai:canHumanAct() and not credits.open end)
end

function love.load()
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
    skillEffects:update(dt)
    if difficultyMenu.active or not board then return end
    input:update(dt)
    if not credits.open then ai:update(dt) end
end

function love.draw()
    if board then
        board:draw(camera)
        input:drawSelectionBox()
        HUD.draw(theme, fonts, board, camera, flow, actionMenu.status, ai:status())
        actionMenu:draw(fonts)
        credits:draw(fonts)
    end
    difficultyMenu:draw(fonts)
end

function love.mousepressed(x, y, button)
    if difficultyMenu.active then
        local difficulty = difficultyMenu:mousepressed(x, y, button)
        if difficulty then startGame(difficulty) end
    elseif input then input:mousepressed(x, y, button) end
end

function love.mousereleased(x, y, button)
    if input and not difficultyMenu.active then input:mousereleased(x, y, button) end
end

function love.mousemoved(x, y, dx, dy)
    if input and not difficultyMenu.active then input:mousemoved(x, y, dx, dy) end
end

function love.wheelmoved(x, y)
    if input and not difficultyMenu.active then input:wheelmoved(x, y) end
end

function love.keypressed(key)
    if difficultyMenu.active then
        local difficulty = difficultyMenu:keypressed(key)
        if difficulty then startGame(difficulty)
        elseif key == "escape" then love.event.quit() end
        return
    end
    if flow and flow.finished then
        if credits:keypressed(key) then return
        elseif key == "r" then startGame(currentDifficulty)
        elseif key == "m" then credits:close() difficultyMenu:show()
        elseif key == "escape" then love.event.quit() end
        return
    end
    if input then input:keypressed(key) end
end
