local HUD = {}

function HUD.draw(theme, fonts, board, camera, statusMessage)
    local width = love.graphics.getWidth()
    local panelX, panelY = 24, 24

    love.graphics.setColor(theme.panel)
    love.graphics.rectangle("fill", panelX, panelY, 362, 186, 12, 12)
    love.graphics.setColor(theme.panelEdge)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", panelX, panelY, 362, 186, 12, 12)
    love.graphics.setColor(theme.text)
    love.graphics.setFont(fonts.title)
    love.graphics.print("CHESS WAR", panelX + 16, panelY + 14)
    love.graphics.setColor(theme.muted)
    love.graphics.setFont(fonts.body)
    love.graphics.print("16 by 16 isometric chessboard", panelX + 16, panelY + 42)
    love.graphics.print("Click a piece to select", panelX + 16, panelY + 65)
    love.graphics.print("Press Q to open the action menu", panelX + 16, panelY + 86)
    love.graphics.print("WASD moves the camera  |  Scroll zooms", panelX + 16, panelY + 107)
    love.graphics.print("Drag pawns to multi-select  |  " .. board:selectedCount() .. " selected", panelX + 16, panelY + 128)
    love.graphics.setColor(board:isMoving() and theme.actionMove or theme.muted)
    love.graphics.print(statusMessage, panelX + 16, panelY + 153)
    love.graphics.print(string.format("%.0f%%", camera.zoom * 100), width - 76, 26)
end

return HUD
