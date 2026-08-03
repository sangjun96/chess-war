local Camera = {}
Camera.__index = Camera

function Camera.new(boardPixels)
    return setmetatable({
        boardPixels = boardPixels,
        x = boardPixels / 2,
        y = boardPixels / 2,
        zoom = 1,
        homeZoom = 1,
        minZoom = 0.2,
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
    self.zoom = self.homeZoom
end

function Camera:fitToViewport(width, height)
    local padding = width < 700 and 20 or 72
    local isoWidth, isoHeight = self.boardPixels, self.boardPixels / 2
    local fit = math.min((width - padding * 2) / isoWidth, (height - padding * 2) / isoHeight)
    if width < 700 then fit = math.max(fit, 0.55) end
    self.homeZoom = math.max(self.minZoom, math.min(1.15, fit))
    self:reset()
end

function Camera:pan(dx, dy)
    local worldDX, worldDY = self:isoToWorld(dx / self.zoom, dy / self.zoom)
    self.x = self.x - worldDX
    self.y = self.y - worldDY
    self:clamp()
end

function Camera:zoomScaleAt(screenX, screenY, scale)
    if scale <= 0 or scale == 1 then return end
    local boardX, boardY = self:screenToBoard(screenX, screenY)
    self.zoom = math.max(self.minZoom, math.min(self.maxZoom, self.zoom * scale))

    local width, height = love.graphics.getDimensions()
    local targetIsoX, targetIsoY = self:worldToIso(boardX, boardY)
    local screenIsoX = (screenX - width / 2) / self.zoom
    local screenIsoY = (screenY - height / 2) / self.zoom
    self.x, self.y = self:isoToWorld(targetIsoX - screenIsoX, targetIsoY - screenIsoY)
    self:clamp()
end

function Camera:zoomAt(screenX, screenY, wheelY)
    if wheelY == 0 then return end
    self:zoomScaleAt(screenX, screenY, wheelY > 0 and 1.16 or 1 / 1.16)
end

return Camera
