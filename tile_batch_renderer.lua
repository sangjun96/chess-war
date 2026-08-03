local TileBatchRenderer = {}
TileBatchRenderer.__index = TileBatchRenderer

local function makeAtlas(tiles)
    local width, height = tiles.lightTile:getDimensions()
    local atlas = love.graphics.newCanvas(width * 2, height)
    love.graphics.push("all")
    love.graphics.setCanvas(atlas)
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(tiles.lightTile, 0, 0)
    love.graphics.draw(tiles.darkTile, width, 0)
    love.graphics.pop()
    atlas:setFilter("nearest", "nearest")
    return atlas, width, height
end

function TileBatchRenderer.new(tiles, boardSize, cellSize)
    local atlas, width, height = makeAtlas(tiles)
    local batch = love.graphics.newSpriteBatch(atlas, boardSize * boardSize, "static")
    local light = love.graphics.newQuad(0, 0, width, height, atlas:getDimensions())
    local dark = love.graphics.newQuad(width, 0, width, height, atlas:getDimensions())
    local scaleX, scaleY = cellSize / width, (cellSize / 2) / height

    for row = 0, boardSize - 1 do
        for column = 0, boardSize - 1 do
            local x = (column - row) * cellSize * 0.5
            local y = (column + row) * cellSize * 0.25
            local quad = (column + row) % 2 == 0 and light or dark
            batch:add(quad, x - cellSize / 2, y, 0, scaleX, scaleY)
        end
    end
    batch:flush()
    return setmetatable({ atlas = atlas, batch = batch }, TileBatchRenderer)
end

function TileBatchRenderer:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.batch)
end

return TileBatchRenderer
