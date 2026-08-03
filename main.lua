local ActionMenu = require("action_menu")
local Board = require("board")
local Camera = require("camera")
local HUD = require("hud")
local Input = require("game_input")
local theme = require("theme")

local board = Board.new(16, 68, 1.44)
local camera = Camera.new(board.pixels)
local fonts = {}
local menu = ActionMenu.new(board, theme)
local input = Input.new(board, camera, menu, theme)

function love.load()
    love.graphics.setBackgroundColor(theme.background)
    love.graphics.setDefaultFilter("nearest", "nearest")
    board:loadAssets("assets/isocubic-chess")
    fonts.title = love.graphics.newFont(18)
    fonts.body = love.graphics.newFont(12)
end

function love.update(dt)
    input:update(dt)
end

function love.draw()
    board:draw(camera)
    input:drawSelectionBox()
    HUD.draw(theme, fonts, board, camera, menu.status)
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
