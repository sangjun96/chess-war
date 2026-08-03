local Board = {}
Board.__index = Board

function Board.new(size, cellSize, palette)
    return setmetatable({
        size = size,
        cellSize = cellSize,
        pixels = size * cellSize,
        depth = 38,
        palette = palette,
    }, Board)
end

function Board:drawDiamond(camera, x, y)
    local size = self.cellSize
    local topX, topY = camera:worldToIso(x, y)
    local rightX, rightY = camera:worldToIso(x + size, y)
    local bottomX, bottomY = camera:worldToIso(x + size, y + size)
    local leftX, leftY = camera:worldToIso(x, y + size)
    love.graphics.polygon("fill", topX, topY, rightX, rightY, bottomX, bottomY, leftX, leftY)
end

function Board:getVisibleCells(camera)
    local width, height = love.graphics.getDimensions()
    local corners = {
        { camera:screenToBoard(0, 0) },
        { camera:screenToBoard(width, 0) },
        { camera:screenToBoard(0, height) },
        { camera:screenToBoard(width, height) },
    }
    local minX, minY, maxX, maxY = self.pixels, self.pixels, 0, 0
    for _, point in ipairs(corners) do
        minX = math.min(minX, point[1])
        minY = math.min(minY, point[2])
        maxX = math.max(maxX, point[1])
        maxY = math.max(maxY, point[2])
    end

    local function cell(value)
        return math.max(0, math.min(self.size - 1, value))
    end

    return cell(math.floor(minX / self.cellSize) - 1),
        cell(math.floor(minY / self.cellSize) - 1),
        cell(math.floor(maxX / self.cellSize) + 1),
        cell(math.floor(maxY / self.cellSize) + 1)
end

function Board:draw(camera)
    local width, height = love.graphics.getDimensions()
    local firstColumn, firstRow, lastColumn, lastRow = self:getVisibleCells(camera)
    local cameraIsoX, cameraIsoY = camera:worldToIso(camera.x, camera.y)
    local topX, topY = camera:worldToIso(0, 0)
    local rightX, rightY = camera:worldToIso(self.pixels, 0)
    local bottomX, bottomY = camera:worldToIso(self.pixels, self.pixels)
    local leftX, leftY = camera:worldToIso(0, self.pixels)

    love.graphics.push()
    love.graphics.translate(width / 2, height / 2)
    love.graphics.scale(camera.zoom)
    love.graphics.translate(-cameraIsoX, -cameraIsoY)

    love.graphics.setColor(self.palette.boardSide)
    love.graphics.polygon("fill", leftX, leftY, bottomX, bottomY, bottomX, bottomY + self.depth, leftX, leftY + self.depth)
    love.graphics.setColor(self.palette.boardFront)
    love.graphics.polygon("fill", bottomX, bottomY, rightX, rightY, rightX, rightY + self.depth, bottomX, bottomY + self.depth)

    for row = firstRow, lastRow do
        for column = firstColumn, lastColumn do
            love.graphics.setColor((row + column) % 2 == 0 and self.palette.lightSquare or self.palette.darkSquare)
            self:drawDiamond(camera, column * self.cellSize, row * self.cellSize)
        end
    end

    love.graphics.setColor(self.palette.accent[1], self.palette.accent[2], self.palette.accent[3], 0.7)
    love.graphics.setLineWidth(math.max(1 / camera.zoom, 2 / camera.zoom))
    love.graphics.line(topX, topY, rightX, rightY, bottomX, bottomY, leftX, leftY, topX, topY)
    love.graphics.pop()
end

return Board
