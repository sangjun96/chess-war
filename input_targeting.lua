local Targeting = {}

function Targeting.handle(board, camera, menu, x, y)
    if not board:isMoving() and not board:isAttacking() then return false end

    local column, row = board:cellAtScreen(camera, x, y)
    if board:isAttacking() then
        local fired, destroyed, damaged, targets = board:attackAt(column, row)
        local status = "Choose one of the orange skill target tiles."
        if fired and destroyed then
            status = "Skill hit " .. targets .. " target(s); an enemy was destroyed. Press Q for another action."
        elseif fired and damaged then
            status = "Skill hit " .. targets .. " target(s). Press Q for another action."
        elseif fired then
            status = "Skill fired. No enemies were in its effect area."
        end
        menu:setStatus(status)
        return true
    end

    local moved, destroyed, damaged = board:moveTo(column, row)
    local status = "Choose one of the cyan destination tiles."
    if moved then
        if destroyed then
            status = "Enemy destroyed. Press Q for another action."
        elseif damaged then
            status = "Enemy damaged. Press Q for another action."
        else
            status = "Piece moved. Press Q for another action."
        end
    end
    menu:setStatus(status)
    return true
end

return Targeting
