local TileRenderer = require("tile_renderer")
local PieceRenderer = require("piece_renderer")

local Board = {}
Board.__index = Board

-- A single 16-piece army per side. The unique queen and king occupy the
-- center two files, with the heavier supporting pieces arranged around them.
local armyRank = {
    "rook", "rook",
    "knight", "knight",
    "bishop", "bishop",
    "knight",
    "queen", "king",
    "knight",
    "bishop", "bishop",
    "knight", "knight",
    "rook", "rook",
}

function Board.new(size, cellSize, pieceScale)
    return setmetatable({
        size = size,
        cellSize = cellSize,
        pieceScale = pieceScale,
        pixels = size * cellSize,
        pieces = Board:createStartingPieces(size),
    }, Board)
end

function Board:createStartingPieces(size)
    local pieces = {}

    for column, kind in ipairs(armyRank) do
        local boardColumn = column - 1
        table.insert(pieces, { column = boardColumn, row = 0, kind = kind, team = "red" })
        table.insert(pieces, { column = boardColumn, row = 1, kind = "pawn", team = "red" })
        table.insert(pieces, { column = boardColumn, row = size - 2, kind = "pawn", team = "blue" })
        table.insert(pieces, { column = boardColumn, row = size - 1, kind = kind, team = "blue" })
    end

    return pieces
end

function Board:loadAssets(assetPath)
    self.tiles = TileRenderer.new(assetPath)
    self.pieceRenderer = PieceRenderer.new(assetPath, self.pieceScale)
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

function Board:drawTiles(camera, firstColumn, firstRow, lastColumn, lastRow)
    for row = firstRow, lastRow do
        for column = firstColumn, lastColumn do
            local x, y = camera:worldToIso(column * self.cellSize, row * self.cellSize)
            self.tiles:draw(column, row, x, y, self.cellSize)
        end
    end
end

function Board:drawPiece(camera, piece)
    local centerX, centerY = camera:worldToIso(
        (piece.column + 0.5) * self.cellSize,
        (piece.row + 0.5) * self.cellSize
    )
    self.pieceRenderer:draw(piece, centerX, centerY)
end

function Board:drawPieces(camera)
    table.sort(self.pieces, function(a, b)
        return a.column + a.row < b.column + b.row
    end)

    for _, piece in ipairs(self.pieces) do
        self:drawPiece(camera, piece)
    end
end

function Board:draw(camera)
    local width, height = love.graphics.getDimensions()
    local firstColumn, firstRow, lastColumn, lastRow = self:getVisibleCells(camera)
    local cameraIsoX, cameraIsoY = camera:worldToIso(camera.x, camera.y)

    love.graphics.push()
    love.graphics.translate(width / 2, height / 2)
    love.graphics.scale(camera.zoom)
    love.graphics.translate(-cameraIsoX, -cameraIsoY)
    love.graphics.setColor(1, 1, 1)
    self:drawTiles(camera, firstColumn, firstRow, lastColumn, lastRow)
    self:drawPieces(camera)
    love.graphics.pop()
end

return Board
