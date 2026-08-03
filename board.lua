local TileRenderer = require("tile_renderer")
local PieceRenderer = require("piece_renderer")
local Rules = require("board_rules")
local Renderer = require("board_renderer")
local StartingPieces = require("starting_pieces")

local Board = {}
Board.__index = Board

function Board.new(size, cellSize, pieceScale)
    return setmetatable({
        size = size,
        cellSize = cellSize,
        pieceScale = pieceScale,
        pixels = size * cellSize,
        pieces = StartingPieces.create(size),
        selectedPieces = {},
        moveTargets = {},
        moveCommands = {},
        movingPieces = nil,
    }, Board)
end

function Board:loadAssets(assetPath)
    self.tiles = TileRenderer.new(assetPath)
    self.pieceRenderer = PieceRenderer.new(assetPath, self.pieceScale)
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
    self:cancelMove()
end

function Board:selectOnly(piece)
    self.selectedPieces = { [piece] = true }
    self:cancelMove()
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
            local x, y = Renderer.screenPosition(self, camera, piece)
            local spriteX, spriteY = x - spriteBaseX, y - spriteBaseY
            if spriteX <= maxX and spriteX + spriteSize >= minX
                and spriteY <= maxY and spriteY + spriteSize >= minY or piece == anchorPawn then
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

function Board:sortPieces()
    table.sort(self.pieces, function(a, b)
        return a.column + a.row < b.column + b.row
    end)
end

function Board:cellAtScreen(camera, screenX, screenY)
    local boardX, boardY = camera:screenToBoard(screenX, screenY)
    local column = math.floor(boardX / self.cellSize)
    local row = math.floor(boardY / self.cellSize)
    if self:isInside(column, row) then return column, row end
end

function Board:targetKey(column, row) return Rules.targetKey(column, row) end
function Board:pieceAt(column, row) return Rules.pieceAt(self, column, row) end
function Board:isInside(column, row) return Rules.isInside(self, column, row) end
function Board:isMoveTarget(column, row) return Rules.isMoveTarget(self, column, row) end
function Board:selectedPiece() return Rules.selectedPiece(self) end
function Board:beginMove() return Rules.beginMove(self) end
function Board:isMoving() return Rules.isMoving(self) end
function Board:cancelMove() return Rules.cancelMove(self) end
function Board:moveTo(column, row) return Rules.moveTo(self, column, row) end

function Board:getVisibleCells(camera) return Renderer.getVisibleCells(self, camera) end
function Board:drawTiles(camera, firstColumn, firstRow, lastColumn, lastRow)
    return Renderer.drawTiles(self, camera, firstColumn, firstRow, lastColumn, lastRow)
end
function Board:screenPosition(camera, piece) return Renderer.screenPosition(self, camera, piece) end
function Board:pieceAtScreen(camera, screenX, screenY)
    return Renderer.pieceAtScreen(self, camera, screenX, screenY)
end
function Board:drawPieces(camera) return Renderer.drawPieces(self, camera) end
function Board:draw(camera) return Renderer.draw(self, camera) end

return Board
