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

function TileRenderer:drawSelection(x, y, cellSize)
    local halfWidth = cellSize / 2
    local halfHeight = cellSize / 4
    local bottomY = y + cellSize / 2

    -- Draw the selection over the tile, before pieces are rendered, so the
    -- marker stays visible without obscuring the selected unit.
    love.graphics.setColor(1, 0.82, 0.16, 0.20)
    love.graphics.polygon("fill",
        x, y + 2,
        x + halfWidth - 3, y + halfHeight,
        x, bottomY - 2,
        x - halfWidth + 3, y + halfHeight
    )

    love.graphics.setColor(1, 0.9, 0.36, 0.95)
    love.graphics.setLineWidth(2)
    love.graphics.line(
        x, y + 1,
        x + halfWidth - 1, y + halfHeight,
        x, bottomY - 1,
        x - halfWidth + 1, y + halfHeight,
        x, y + 1
    )
end

function TileRenderer:drawMoveTarget(x, y, cellSize)
    local halfWidth = cellSize / 2
    local halfHeight = cellSize / 4

    -- A small cyan diamond keeps legal destinations readable without covering
    -- the tile artwork or the piece that may be captured there.
    love.graphics.setColor(0.24, 0.84, 1, 0.24)
    love.graphics.polygon("fill",
        x, y + 7,
        x + halfWidth - 8, y + halfHeight,
        x, y + cellSize / 2 - 7,
        x - halfWidth + 8, y + halfHeight
    )
    love.graphics.setColor(0.5, 0.92, 1, 0.95)
    love.graphics.setLineWidth(2)
    love.graphics.polygon("line",
        x, y + 7,
        x + halfWidth - 8, y + halfHeight,
        x, y + cellSize / 2 - 7,
        x - halfWidth + 8, y + halfHeight
    )
end

function TileRenderer:drawSkillTarget(x, y, cellSize)
    local halfWidth = cellSize / 2
    local halfHeight = cellSize / 4

    love.graphics.setColor(1, 0.3, 0.12, 0.20)
    love.graphics.polygon("fill",
        x, y + 7,
        x + halfWidth - 8, y + halfHeight,
        x, y + cellSize / 2 - 7,
        x - halfWidth + 8, y + halfHeight
    )
    love.graphics.setColor(1, 0.56, 0.2, 0.95)
    love.graphics.setLineWidth(2)
    love.graphics.polygon("line",
        x, y + 7,
        x + halfWidth - 8, y + halfHeight,
        x, y + cellSize / 2 - 7,
        x - halfWidth + 8, y + halfHeight
    )
end

function TileRenderer:drawSkillArea(x, y, cellSize)
    local halfWidth = cellSize / 2
    local halfHeight = cellSize / 4

    -- The red preview marks every tile that will be hit by the area skill.
    -- The selected target is drawn over this in orange afterwards.
    love.graphics.setColor(1, 0.18, 0.18, 0.18)
    love.graphics.polygon("fill",
        x, y + 9,
        x + halfWidth - 10, y + halfHeight,
        x, y + cellSize / 2 - 9,
        x - halfWidth + 10, y + halfHeight
    )
    love.graphics.setColor(1, 0.34, 0.34, 0.85)
    love.graphics.setLineWidth(2)
    love.graphics.polygon("line",
        x, y + 9,
        x + halfWidth - 10, y + halfHeight,
        x, y + cellSize / 2 - 9,
        x - halfWidth + 10, y + halfHeight
    )
end

return TileRenderer
