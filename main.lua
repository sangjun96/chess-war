local Camera = require("camera")
local Board = require("board")

local palette = {
    background = { 12 / 255, 16 / 255, 23 / 255 },
    panel = { 21 / 255, 27 / 255, 37 / 255, 0.96 },
    panelEdge = { 111 / 255, 132 / 255, 158 / 255, 0.44 },
    text = { 238 / 255, 243 / 255, 250 / 255 },
    muted = { 160 / 255, 177 / 255, 196 / 255 },
    selectionFill = { 1, 0.88, 0.32, 0.12 },
    selectionEdge = { 1, 0.88, 0.32, 0.9 },
}

-- Keep the pieces a little inside the footprint of each tile.
local board = Board.new(16, 68, 1.44)
local camera = Camera.new(board.pixels)
local fonts = {}
local pointerDown = false
local pressX, pressY = 0, 0
local pressPiece = nil
local panning = false
local selectingPawns = false
local dragX, dragY = 0, 0
local dragThreshold = 6

local function drawHUD()
    local width = love.graphics.getWidth()
    local panelX, panelY = 24, 24

    love.graphics.setColor(palette.panel)
    love.graphics.rectangle("fill", panelX, panelY, 330, 144, 12, 12)
    love.graphics.setColor(palette.panelEdge)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", panelX, panelY, 330, 144, 12, 12)
    love.graphics.setColor(palette.text)
    love.graphics.setFont(fonts.title)
    love.graphics.print("CHESS WAR", panelX + 16, panelY + 14)
    love.graphics.setColor(palette.muted)
    love.graphics.setFont(fonts.body)
    love.graphics.print("16 by 16 isometric chessboard", panelX + 16, panelY + 42)
    love.graphics.print("Click a piece to select", panelX + 16, panelY + 65)
    love.graphics.print("Drag from a pawn to select pawns", panelX + 16, panelY + 86)
    love.graphics.print("Drag elsewhere to pan  |  " .. board:selectedCount() .. " selected", panelX + 16, panelY + 107)

    love.graphics.print(string.format("%.0f%%", camera.zoom * 100), width - 76, 26)
end

function love.load()
    love.graphics.setBackgroundColor(palette.background)
    love.graphics.setDefaultFilter("nearest", "nearest")
    board:loadAssets("assets/isocubic-chess")
    fonts.title = love.graphics.newFont(18)
    fonts.body = love.graphics.newFont(12)
end

local function drawPawnSelectionBox()
    if not selectingPawns then return end

    local x = math.min(pressX, dragX)
    local y = math.min(pressY, dragY)
    local width = math.abs(dragX - pressX)
    local height = math.abs(dragY - pressY)
    love.graphics.setColor(palette.selectionFill)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(palette.selectionEdge)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, width, height)
end

function love.draw()
    board:draw(camera)
    drawPawnSelectionBox()
    drawHUD()
end

function love.mousepressed(x, y, button)
    if button == 1 then
        pointerDown = true
        pressX, pressY = x, y
        dragX, dragY = x, y
        pressPiece = board:pieceAtScreen(camera, x, y)
        panning = false
        selectingPawns = false
    end
end

function love.mousereleased(x, y, button)
    if button == 1 then
        if pointerDown and selectingPawns then
            board:selectPawnsInScreenRect(camera, pressX, pressY, x, y, pressPiece)
        elseif pointerDown and not panning then
            local piece = pressPiece or board:pieceAtScreen(camera, x, y)
            if piece then
                board:selectOnly(piece)
            else
                board:clearSelection()
            end
        end
        pointerDown = false
        pressPiece = nil
        panning = false
        selectingPawns = false
    end
end

function love.mousemoved(x, y, dx, dy)
    if pointerDown then
        dragX, dragY = x, y
        if not panning and not selectingPawns
            and (math.abs(x - pressX) > dragThreshold or math.abs(y - pressY) > dragThreshold) then
            selectingPawns = pressPiece and pressPiece.kind == "pawn"
            panning = not selectingPawns
        end
        if selectingPawns then
            board:selectPawnsInScreenRect(camera, pressX, pressY, x, y, pressPiece)
        elseif panning then
            camera:pan(dx, dy)
        end
    end
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
