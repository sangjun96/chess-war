local Input = {}
Input.__index = Input

function Input.new(board, camera, menu, theme)
    return setmetatable({
        board = board,
        camera = camera,
        menu = menu,
        theme = theme,
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
    if self.menu:mousepressed(x, y) then return end
    if self.board:isMoving() then
        local column, row = self.board:cellAtScreen(self.camera, x, y)
        local moved, destroyed, damaged = self.board:moveTo(column, row)
        local status = "Choose one of the cyan destination tiles."
        if moved then
            if destroyed then
                status = "Enemy destroyed. Press Q for another action."
            elseif damaged then
                status = "Enemy damaged. Press Q for another action."
            else
                status = "Piece moved. Press Q for another action."
            end
        end
        self.menu:setStatus(status)
        return
    end

    self.pointerDown = true
    self.pressX, self.pressY = x, y
    self.dragX, self.dragY = x, y
    self.pressPiece = self.board:pieceAtScreen(self.camera, x, y)
    self.panning = false
    self.selectingPawns = false
end

function Input:mousereleased(x, y, button)
    if button ~= 1 then return end
    if self.pointerDown and self.selectingPawns then
        self.board:selectPawnsInScreenRect(self.camera, self.pressX, self.pressY, x, y, self.pressPiece)
    elseif self.pointerDown and not self.panning then
        local piece = self.pressPiece or self.board:pieceAtScreen(self.camera, x, y)
        if piece then self.board:selectOnly(piece) else self.board:clearSelection() end
    end
    self.pointerDown = false
    self.pressPiece = nil
    self.panning = false
    self.selectingPawns = false
end

function Input:mousemoved(x, y, dx, dy)
    if not self.pointerDown then return end
    self.dragX, self.dragY = x, y
    if not self.panning and not self.selectingPawns
        and (math.abs(x - self.pressX) > self.dragThreshold or math.abs(y - self.pressY) > self.dragThreshold) then
        self.selectingPawns = self.pressPiece and self.pressPiece.kind == "pawn"
        self.panning = not self.selectingPawns
    end
    if self.selectingPawns then
        self.board:selectPawnsInScreenRect(self.camera, self.pressX, self.pressY, x, y, self.pressPiece)
    elseif self.panning then
        self.camera:pan(dx, dy)
    end
end

function Input:wheelmoved(_, y)
    local mouseX, mouseY = love.mouse.getPosition()
    self.camera:zoomAt(mouseX, mouseY, y)
end

function Input:keypressed(key)
    if key == "home" then
        self.camera:reset()
    elseif not self.menu:keypressed(key) and key == "escape" then
        love.event.quit()
    end
end

return Input
