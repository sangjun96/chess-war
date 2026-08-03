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
        selectedPieces = {},
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

    -- Highlights are drawn after the full tile layer so neighboring tiles never
    -- cover the selected tile's border.
    for row = firstRow, lastRow do
        for column = firstColumn, lastColumn do
            if self:isTileSelected(column, row) then
                local x, y = camera:worldToIso(column * self.cellSize, row * self.cellSize)
                self.tiles:drawSelection(x, y, self.cellSize)
            end
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

function Board:isSelected(piece)
    return self.selectedPieces[piece] == true
end

function Board:isTileSelected(column, row)
    for piece in pairs(self.selectedPieces) do
        if piece.column == column and piece.row == row then return true end
    end
    return false
end

function Board:clearSelection()
    self.selectedPieces = {}
end

function Board:selectOnly(piece)
    self.selectedPieces = { [piece] = true }
end

function Board:selectPawnsInScreenRect(camera, firstX, firstY, lastX, lastY, anchorPawn)
    local minX, maxX = math.min(firstX, lastX), math.max(firstX, lastX)
    local minY, maxY = math.min(firstY, lastY), math.max(firstY, lastY)
    local spriteSize = 32 * self.pieceScale * camera.zoom
    local spriteBaseX = 16 * self.pieceScale * camera.zoom
    local spriteBaseY = 30 * self.pieceScale * camera.zoom

    self:clearSelection()
    for _, piece in ipairs(self.pieces) do
        if piece.kind == "pawn" then
            local x, y = self:screenPosition(camera, piece)
            local spriteX, spriteY = x - spriteBaseX, y - spriteBaseY
            local overlapsSelection = spriteX <= maxX and spriteX + spriteSize >= minX
                and spriteY <= maxY and spriteY + spriteSize >= minY
            if overlapsSelection or piece == anchorPawn then
                self.selectedPieces[piece] = true
            end
        end
    end
end

function Board:selectedCount()
    local count = 0
    for _ in pairs(self.selectedPieces) do count = count + 1 end
    return count
end

function Board:screenPosition(camera, piece)
    local width, height = love.graphics.getDimensions()
    local centerX, centerY = camera:worldToIso(
        (piece.column + 0.5) * self.cellSize,
        (piece.row + 0.5) * self.cellSize
    )
    local cameraX, cameraY = camera:worldToIso(camera.x, camera.y)
    return width / 2 + (centerX - cameraX) * camera.zoom,
        height / 2 + (centerY - cameraY) * camera.zoom
end

function Board:pieceAtScreen(camera, screenX, screenY)
    -- Test the rendered sprite bounds from front to back, so overlapping pieces
    -- select the same one the player sees on top.
    self:sortPieces()
    local spriteSize = 32 * self.pieceScale * camera.zoom
    local spriteBaseX = 16 * self.pieceScale * camera.zoom
    local spriteBaseY = 30 * self.pieceScale * camera.zoom

    for index = #self.pieces, 1, -1 do
        local piece = self.pieces[index]
        local x, y = self:screenPosition(camera, piece)
        if screenX >= x - spriteBaseX and screenX <= x - spriteBaseX + spriteSize
            and screenY >= y - spriteBaseY and screenY <= y - spriteBaseY + spriteSize then
            return piece
        end
    end
end

function Board:drawSelectionPointer(camera, piece)
    local x, y = camera:worldToIso(
        (piece.column + 0.5) * self.cellSize,
        (piece.row + 0.5) * self.cellSize
    )
    -- The pointer floats immediately above the piece's head.
    local pointerY = y - 37 * self.pieceScale
    -- Keep the marker proportional to its piece as the board zooms.
    local pointerSize = 7
    love.graphics.setColor(1, 0.88, 0.32, 1)
    love.graphics.polygon("fill", x, pointerY + pointerSize, x - pointerSize, pointerY - pointerSize, x + pointerSize, pointerY - pointerSize)
    love.graphics.setColor(0.18, 0.12, 0.03, 0.95)
    love.graphics.setLineWidth(1)
    love.graphics.polygon("line", x, pointerY + pointerSize, x - pointerSize, pointerY - pointerSize, x + pointerSize, pointerY - pointerSize)
end

function Board:sortPieces()
    table.sort(self.pieces, function(a, b)
        return a.column + a.row < b.column + b.row
    end)
end

function Board:drawPieces(camera)
    self:sortPieces()

    -- Images inherit LÖVE's current draw color, so reset it before every sprite pass.
    love.graphics.setColor(1, 1, 1, 1)
    for _, piece in ipairs(self.pieces) do
        self:drawPiece(camera, piece)
    end
    -- Draw pointers last so selected pieces remain clearly marked when sprites overlap.
    for _, piece in ipairs(self.pieces) do
        if self:isSelected(piece) then self:drawSelectionPointer(camera, piece) end
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
