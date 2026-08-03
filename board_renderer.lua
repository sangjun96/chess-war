local Renderer = {}
local PieceOverlayRenderer = require("piece_overlay_renderer")

function Renderer.getVisibleCells(board, camera)
    local width, height = love.graphics.getDimensions()
    local corners = {
        { camera:screenToBoard(0, 0) },
        { camera:screenToBoard(width, 0) },
        { camera:screenToBoard(0, height) },
        { camera:screenToBoard(width, height) },
    }
    local minX, minY, maxX, maxY = board.pixels, board.pixels, 0, 0
    for _, point in ipairs(corners) do
        minX = math.min(minX, point[1])
        minY = math.min(minY, point[2])
        maxX = math.max(maxX, point[1])
        maxY = math.max(maxY, point[2])
    end
    local function cell(value)
        return math.max(0, math.min(board.size - 1, value))
    end
    return cell(math.floor(minX / board.cellSize) - 1),
        cell(math.floor(minY / board.cellSize) - 1),
        cell(math.floor(maxX / board.cellSize) + 1),
        cell(math.floor(maxY / board.cellSize) + 1)
end

function Renderer.drawTiles(board, camera, firstColumn, firstRow, lastColumn, lastRow)
    board.tileBatch:draw()
    for row = firstRow, lastRow do
        for column = firstColumn, lastColumn do
            if board:isTileSelected(column, row) then
                local x, y = camera:worldToIso(column * board.cellSize, row * board.cellSize)
                board.tiles:drawSelection(x, y, board.cellSize)
            end
            if board:isMoveTarget(column, row) then
                local x, y = camera:worldToIso(column * board.cellSize, row * board.cellSize)
                board.tiles:drawMoveTarget(x, y, board.cellSize)
            end
            if board:isSkillPreviewTarget(column, row) then
                local x, y = camera:worldToIso(column * board.cellSize, row * board.cellSize)
                board.tiles:drawSkillArea(x, y, board.cellSize)
            end
            if board:isSkillTarget(column, row) then
                local x, y = camera:worldToIso(column * board.cellSize, row * board.cellSize)
                board.tiles:drawSkillTarget(x, y, board.cellSize)
            end
        end
    end
end

function Renderer.screenPosition(board, camera, piece)
    local width, height = love.graphics.getDimensions()
    local centerX, centerY = camera:worldToIso(
        (piece.column + 0.5) * board.cellSize,
        (piece.row + 0.5) * board.cellSize
    )
    local cameraX, cameraY = camera:worldToIso(camera.x, camera.y)
    return width / 2 + (centerX - cameraX) * camera.zoom,
        height / 2 + (centerY - cameraY) * camera.zoom
end

function Renderer.pieceAtScreen(board, camera, screenX, screenY)
    board:sortPieces()
    local spriteSize = 32 * board.pieceScale * camera.zoom
    local spriteBaseX = 16 * board.pieceScale * camera.zoom
    local spriteBaseY = 30 * board.pieceScale * camera.zoom
    for index = #board.pieces, 1, -1 do
        local piece = board.pieces[index]
        local x, y = Renderer.screenPosition(board, camera, piece)
        if screenX >= x - spriteBaseX and screenX <= x - spriteBaseX + spriteSize
            and screenY >= y - spriteBaseY and screenY <= y - spriteBaseY + spriteSize then
            return piece
        end
    end
end

function Renderer.drawPieces(board, camera)
    board:sortPieces()
    love.graphics.setColor(1, 1, 1, 1)
    for _, piece in ipairs(board.pieces) do
        local centerX, centerY = camera:worldToIso(
            (piece.column + 0.5) * board.cellSize,
            (piece.row + 0.5) * board.cellSize
        )
        board.pieceRenderer:draw(piece, centerX, centerY)
    end
    if board.skillEffects then board.skillEffects:draw(board, camera) end
    for _, piece in ipairs(board.pieces) do
        local centerX, centerY = camera:worldToIso(
            (piece.column + 0.5) * board.cellSize,
            (piece.row + 0.5) * board.cellSize
        )
        PieceOverlayRenderer.drawHealth(piece, centerX, centerY, board.pieceScale)
    end
    for _, piece in ipairs(board.pieces) do
        if board:isSelected(piece) then PieceOverlayRenderer.drawSelection(board, camera, piece) end
    end
end

function Renderer.draw(board, camera)
    local width, height = love.graphics.getDimensions()
    local firstColumn, firstRow, lastColumn, lastRow = Renderer.getVisibleCells(board, camera)
    local cameraIsoX, cameraIsoY = camera:worldToIso(camera.x, camera.y)
    love.graphics.push()
    love.graphics.translate(width / 2, height / 2)
    love.graphics.scale(camera.zoom)
    love.graphics.translate(-cameraIsoX, -cameraIsoY)
    love.graphics.setColor(1, 1, 1)
    Renderer.drawTiles(board, camera, firstColumn, firstRow, lastColumn, lastRow)
    Renderer.drawPieces(board, camera)
    love.graphics.pop()
end

return Renderer
