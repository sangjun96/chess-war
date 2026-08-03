local Camera = require("camera")
local Board = require("board")

local palette = {
    background = { 12 / 255, 16 / 255, 23 / 255 },
    panel = { 21 / 255, 27 / 255, 37 / 255, 0.96 },
    panelEdge = { 111 / 255, 132 / 255, 158 / 255, 0.44 },
    text = { 238 / 255, 243 / 255, 250 / 255 },
    muted = { 160 / 255, 177 / 255, 196 / 255 },
}

-- Keep the pieces a little inside the footprint of each tile.
local board = Board.new(16, 68, 1.44)
local camera = Camera.new(board.pixels)
local fonts = {}
local dragging = false

local function drawHUD()
    local width = love.graphics.getWidth()
    local panelX, panelY = 24, 24

    love.graphics.setColor(palette.panel)
    love.graphics.rectangle("fill", panelX, panelY, 280, 100, 12, 12)
    love.graphics.setColor(palette.panelEdge)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", panelX, panelY, 280, 100, 12, 12)
    love.graphics.setColor(palette.text)
    love.graphics.setFont(fonts.title)
    love.graphics.print("CHESS WAR", panelX + 16, panelY + 14)
    love.graphics.setColor(palette.muted)
    love.graphics.setFont(fonts.body)
    love.graphics.print("16 by 16 isometric chessboard", panelX + 16, panelY + 42)
    love.graphics.print("Drag to move  |  Scroll to zoom  |  Home to reset", panelX + 16, panelY + 65)

    love.graphics.print(string.format("%.0f%%", camera.zoom * 100), width - 76, 26)
end

function love.load()
    love.graphics.setBackgroundColor(palette.background)
    love.graphics.setDefaultFilter("nearest", "nearest")
    board:loadAssets("assets/isocubic-chess")
    fonts.title = love.graphics.newFont(18)
    fonts.body = love.graphics.newFont(12)
end

function love.draw()
    board:draw(camera)
    drawHUD()
end

function love.mousepressed(_, _, button)
    if button == 1 then dragging = true end
end

function love.mousereleased(_, _, button)
    if button == 1 then dragging = false end
end

function love.mousemoved(_, _, dx, dy)
    if dragging then camera:pan(dx, dy) end
end

function love.wheelmoved(_, y)
    local mouseX, mouseY = love.mouse.getPosition()
    camera:zoomAt(mouseX, mouseY, y)
end

function love.keypressed(key)
    if key == "home" then
        camera:reset()
    elseif key == "escape" then
        love.event.quit()
    end
end
