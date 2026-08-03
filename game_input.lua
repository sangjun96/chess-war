local Pointer = require("pointer_input")
local TouchInput = require("touch_input")

local Input = {}
Input.__index = Input

function Input.new(board, camera, menu, flow, theme, credits, canControl)
    local input = setmetatable({
        board = board,
        camera = camera,
        menu = menu,
        flow = flow,
        theme = theme,
        credits = credits,
        canControl = canControl or function() return true end,
        pointerDown = false,
        pressX = 0,
        pressY = 0,
        dragX = 0,
        dragY = 0,
        pressPiece = nil,
        panning = false,
        selectingPawns = false,
        dragThreshold = 6,
        cameraSpeed = 800,
    }, Input)
    input.touch = TouchInput.new(input)
    return input
end

function Input:update(dt)
    local horizontal = (love.keyboard.isDown("d") and 1 or 0) - (love.keyboard.isDown("a") and 1 or 0)
    local vertical = (love.keyboard.isDown("s") and 1 or 0) - (love.keyboard.isDown("w") and 1 or 0)
    if horizontal == 0 and vertical == 0 then return end

    local distance = self.cameraSpeed * dt / math.sqrt(horizontal * horizontal + vertical * vertical)
    self.camera:pan(-horizontal * distance, -vertical * distance)
end

function Input:drawSelectionBox()
    if not self.selectingPawns then return end
    local x = math.min(self.pressX, self.dragX)
    local y = math.min(self.pressY, self.dragY)
    local width = math.abs(self.dragX - self.pressX)
    local height = math.abs(self.dragY - self.pressY)
    love.graphics.setColor(self.theme.selectionFill)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(self.theme.selectionEdge)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, width, height)
end

function Input:mousepressed(x, y, button)
    Pointer.pressed(self, x, y, button)
end

function Input:mousereleased(x, y, button)
    Pointer.released(self, x, y, button)
end

function Input:cancelPointer()
    self.pointerDown = false
    self.pressPiece = nil
    self.pressWasSelected = false
    self.deferPointerAction = false
    self.panning = false
    self.selectingPawns = false
end

function Input:touchPointerPressed(x, y) Pointer.pressed(self, x, y, 1, true) end
function Input:touchPointerReleased(x, y) Pointer.released(self, x, y, 1) end

function Input:mousemoved(x, y, dx, dy)
    Pointer.moved(self, x, y, dx, dy)
end

function Input:wheelmoved(_, y)
    local mouseX, mouseY = love.mouse.getPosition()
    self.camera:zoomAt(mouseX, mouseY, y)
end

function Input:keypressed(key)
    if self.credits:keypressed(key) then
        return
    elseif key == "home" then
        self.camera:reset()
    elseif key == "=" or key == "+" or key == "kp+" then
        local width, height = love.graphics.getDimensions()
        self.camera:zoomAt(width / 2, height / 2, 1)
    elseif key == "-" or key == "kp-" then
        local width, height = love.graphics.getDimensions()
        self.camera:zoomAt(width / 2, height / 2, -1)
    elseif (not self.canControl() or not self.menu:keypressed(key)) and key == "escape" then
        love.event.quit()
    end
end

function Input:touchpressed(id, x, y) self.touch:pressed(id, x, y) end
function Input:touchmoved(id, x, y, dx, dy) self.touch:moved(id, x, y, dx, dy) end
function Input:touchreleased(id, x, y) self.touch:released(id, x, y) end

return Input
