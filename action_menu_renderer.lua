local Renderer = {}

function Renderer.draw(menu, fonts, actions)
    if not menu.open then return end

    local radius = 104
    for _, action in ipairs(actions) do
        local color = action.enabled and menu.theme.actionFill or menu.theme.actionDisabled
        if action.name == "MOVE" then color = menu.theme.actionMove end
        love.graphics.setColor(color)
        love.graphics.arc("fill", "pie", menu.x, menu.y, radius,
            action.angle - math.pi / 4 + 0.025, action.angle + math.pi / 4 - 0.025, 18)
        love.graphics.setColor(menu.theme.actionEdge)
        love.graphics.setLineWidth(1)
        love.graphics.arc("line", "pie", menu.x, menu.y, radius,
            action.angle - math.pi / 4 + 0.025, action.angle + math.pi / 4 - 0.025, 18)

        local textX = menu.x + math.cos(action.angle) * 66
        local textY = menu.y + math.sin(action.angle) * 66
        love.graphics.setFont(fonts.body)
        love.graphics.setColor(action.enabled and menu.theme.text or menu.theme.muted)
        love.graphics.print(action.name, textX - fonts.body:getWidth(action.name) / 2, textY - 6)
    end

    love.graphics.setColor(menu.theme.panel)
    love.graphics.circle("fill", menu.x, menu.y, 32)
    love.graphics.setColor(menu.theme.actionEdge)
    love.graphics.setLineWidth(1)
    love.graphics.circle("line", menu.x, menu.y, 32)
    love.graphics.setColor(menu.theme.text)
    love.graphics.setFont(fonts.body)
    love.graphics.print("ACTION", menu.x - fonts.body:getWidth("ACTION") / 2, menu.y - 6)
end

return Renderer
