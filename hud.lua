local StatusRenderer = require("turn_status_renderer")

local HUD = {}

function HUD.draw(theme, fonts, board, camera, flow, statusMessage, aiStatus)
    StatusRenderer.draw(theme, fonts, board, flow, statusMessage, aiStatus)
    if flow.finished then return end

    local width, height = love.graphics.getDimensions()
    if width < 700 or height < 520 then return end
    love.graphics.setColor(theme.panel)
    love.graphics.rectangle("fill", width - 92, 68, 68, 30, 10, 10)
    love.graphics.setColor(theme.panelEdge)
    love.graphics.rectangle("line", width - 92, 68, 68, 30, 10, 10)
    love.graphics.setColor(theme.muted)
    love.graphics.setFont(fonts.body)
    love.graphics.printf(string.format("%.0f%%", camera.zoom * 100), width - 92, 77, 68, "center")
end

return HUD
