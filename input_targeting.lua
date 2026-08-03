local Targeting = {}

function Targeting.handle(board, camera, menu, flow, x, y)
    if not board:isMoving() and not board:isAttacking() then return false end

    local column, row = board:cellAtScreen(camera, x, y)
    if column == nil or row == nil then
        menu:setStatus(board:isAttacking()
            and "Choose one of the orange skill target tiles."
            or "Choose one of the cyan destination tiles.")
        return true
    end
    if board:isAttacking() then
        local fired = flow:attackAt(column, row)
        local status = "Choose one of the orange skill target tiles."
        if fired then status = flow.status end
        menu:setStatus(status)
        return true
    end

    local moved = flow:moveTo(column, row)
    local status = "Choose one of the cyan destination tiles."
    if moved then status = flow.status end
    menu:setStatus(status)
    return true
end

return Targeting
