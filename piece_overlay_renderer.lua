local HealthBarRenderer = require("health_bar_renderer")
local theme = require("theme")

local PieceOverlayRenderer = {}

function PieceOverlayRenderer.drawHealth(piece, x, y, scale)
    HealthBarRenderer.draw(theme, piece, x, y, scale)
end

function PieceOverlayRenderer.drawSelection(board, camera, piece)
    local x, y = camera:worldToIso(
        (piece.column + 0.5) * board.cellSize,
        (piece.row + 0.5) * board.cellSize
    )
    local pointerY = y - 46 * board.pieceScale
    local pointerSize = 7
    love.graphics.setColor(1, 0.88, 0.32, 1)
    love.graphics.polygon("fill", x, pointerY + pointerSize, x - pointerSize, pointerY - pointerSize, x + pointerSize, pointerY - pointerSize)
    love.graphics.setColor(0.18, 0.12, 0.03, 0.95)
    love.graphics.setLineWidth(1)
    love.graphics.polygon("line", x, pointerY + pointerSize, x - pointerSize, pointerY - pointerSize, x + pointerSize, pointerY - pointerSize)
end

return PieceOverlayRenderer
