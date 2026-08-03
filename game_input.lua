local Targeting = require("input_targeting")

local Input = {}
Input.__index = Input

function Input.new(board, camera, menu, flow, theme, credits, canControl)
    return setmetatable({
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
    if button ~= 1 then return end
    if self.credits:mousepressed(x, y) then return end
    local controls = self.canControl()
    if controls and self.menu:mousepressed(x, y) then return end
    if controls and Targeting.handle(self.board, self.camera, self.menu, self.flow, x, y) then return end
    if not self.flow:isPlaying() then return end

    self.pointerDown = true
    self.pressX, self.pressY = x, y
    self.dragX, self.dragY = x, y
    local piece = self.board:pieceAtScreen(self.camera, x, y)
    self.pressPiece = controls and self.flow:canSelect(piece) and piece or nil
    self.controlAtPress = controls
    self.panning = false
    self.selectingPawns = false
end

function Input:mousereleased(x, y, button)
    if button ~= 1 then return end
    if self.pointerDown and self.controlAtPress and self.selectingPawns then
        self.board:selectPawnsInScreenRect(self.camera, self.pressX, self.pressY, x, y,
            self.pressPiece, self.flow.activeTeam)
    elseif self.pointerDown and self.controlAtPress and not self.panning then
        local piece = self.pressPiece or self.board:pieceAtScreen(self.camera, x, y)
        if self.flow:canSelect(piece) then self.board:selectOnly(piece) else self.board:clearSelection() end
    end
    self.pointerDown = false
    self.pressPiece = nil
    self.panning = false
    self.selectingPawns = false
end

function Input:mousemoved(x, y, dx, dy)
    if self.canControl() and self.board:isAttacking() then
        local column, row = self.board:cellAtScreen(self.camera, x, y)
        self.board:previewSkillAt(column, row)
    end
    if not self.pointerDown then return end
    self.dragX, self.dragY = x, y
    if not self.panning and not self.selectingPawns
        and (math.abs(x - self.pressX) > self.dragThreshold or math.abs(y - self.pressY) > self.dragThreshold) then
        self.selectingPawns = self.pressPiece and self.pressPiece.kind == "pawn"
        self.panning = not self.selectingPawns
    end
    if self.selectingPawns then
        self.board:selectPawnsInScreenRect(self.camera, self.pressX, self.pressY, x, y,
            self.pressPiece, self.flow.activeTeam)
    elseif self.panning then
        self.camera:pan(dx, dy)
    end
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
    elseif (not self.canControl() or not self.menu:keypressed(key)) and key == "escape" then
        love.event.quit()
    end
end

return Input
