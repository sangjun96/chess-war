local TileRenderer = {}
TileRenderer.__index = TileRenderer

function TileRenderer.new(assetPath)
    return setmetatable({
        darkTile = love.graphics.newImage(assetPath .. "/Tile_Black.png"),
        lightTile = love.graphics.newImage(assetPath .. "/Tile_White.png"),
    }, TileRenderer)
end

function TileRenderer:draw(column, row, x, y, cellSize)
    local tile = (column + row) % 2 == 0 and self.lightTile or self.darkTile
    local scaleX = cellSize / tile:getWidth()
    local scaleY = (cellSize / 2) / tile:getHeight()
    love.graphics.draw(tile, x - cellSize / 2, y, 0, scaleX, scaleY)
end

return TileRenderer
