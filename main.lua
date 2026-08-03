local ActionMenu = require("action_menu")
local Board = require("board")
local Camera = require("camera")
local GameFlow = require("game_flow")
local HUD = require("hud")
local Input = require("game_input")
local PieceSkills = require("piece_skills")
local SkillEffects = require("skill_effects")
local theme = require("theme")

local skillEffects = SkillEffects.new()
local board = Board.new(16, 68, 1.44, skillEffects)
local camera = Camera.new(board.pixels)
local fonts = {}
local flow = GameFlow.new(board)
local menu = ActionMenu.new(board, flow, theme)
local input = Input.new(board, camera, menu, flow, theme)

function love.load()
    PieceSkills.validate()
    love.graphics.setBackgroundColor(theme.background)
    love.graphics.setDefaultFilter("nearest", "nearest")
    board:loadAssets("assets/isocubic-chess")
    skillEffects:load()
    fonts.title = love.graphics.newFont(18)
    fonts.body = love.graphics.newFont(12)
    fonts.statusTitle = love.graphics.newFont(26)
    fonts.statusBody = love.graphics.newFont(13)
    fonts.resultTitle = love.graphics.newFont(34)
end

function love.update(dt)
    input:update(dt)
    skillEffects:update(dt)
end

function love.draw()
    board:draw(camera)
    input:drawSelectionBox()
    HUD.draw(theme, fonts, board, camera, flow, menu.status)
    menu:draw(fonts)
end

function love.mousepressed(x, y, button)
    input:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    input:mousereleased(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
    input:mousemoved(x, y, dx, dy)
end

function love.wheelmoved(x, y)
    input:wheelmoved(x, y)
end

function love.keypressed(key)
    input:keypressed(key)
end
