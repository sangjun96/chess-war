local Camera = {}
Camera.__index = Camera

function Camera.new(boardPixels)
    return setmetatable({
        boardPixels = boardPixels,
        x = boardPixels / 2,
        y = boardPixels / 2,
        zoom = 1,
        minZoom = 0.25,
        maxZoom = 4,
    }, Camera)
end

function Camera:worldToIso(x, y)
    return (x - y) * 0.5, (x + y) * 0.25
end

function Camera:isoToWorld(x, y)
    return x + 2 * y, 2 * y - x
end

function Camera:screenToBoard(x, y)
    local width, height = love.graphics.getDimensions()
    local isoX = (x - width / 2) / self.zoom
    local isoY = (y - height / 2) / self.zoom
    local cameraIsoX, cameraIsoY = self:worldToIso(self.x, self.y)
    return self:isoToWorld(isoX + cameraIsoX, isoY + cameraIsoY)
end

function Camera:clamp()
    self.x = math.max(0, math.min(self.boardPixels, self.x))
    self.y = math.max(0, math.min(self.boardPixels, self.y))
end

function Camera:reset()
    self.x = self.boardPixels / 2
    self.y = self.boardPixels / 2
    self.zoom = 1
end

function Camera:pan(dx, dy)
    local worldDX, worldDY = self:isoToWorld(dx / self.zoom, dy / self.zoom)
    self.x = self.x - worldDX
    self.y = self.y - worldDY
    self:clamp()
end

function Camera:zoomAt(mouseX, mouseY, wheelY)
    if wheelY == 0 then return end

    local boardX, boardY = self:screenToBoard(mouseX, mouseY)
    local zoomFactor = wheelY > 0 and 1.16 or 1 / 1.16
    self.zoom = math.max(self.minZoom, math.min(self.maxZoom, self.zoom * zoomFactor))

    local width, height = love.graphics.getDimensions()
    local targetIsoX, targetIsoY = self:worldToIso(boardX, boardY)
    local mouseIsoX = (mouseX - width / 2) / self.zoom
    local mouseIsoY = (mouseY - height / 2) / self.zoom
    self.x, self.y = self:isoToWorld(targetIsoX - mouseIsoX, targetIsoY - mouseIsoY)
    self:clamp()
end

return Camera
