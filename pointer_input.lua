local Targeting = require("input_targeting")

local Pointer = {}

function Pointer.pressed(input, x, y, button, deferAction)
    if button ~= 1 then return end
    local controls = input.canControl()
    if not deferAction and input.credits:mousepressed(x, y) then return end
    if not deferAction and controls and input.menu:mousepressed(x, y) then return end
    if not deferAction and controls
        and Targeting.handle(input.board, input.camera, input.menu, input.flow, x, y) then return end
    if not input.flow:isPlaying() then return end

    input.pointerDown = true
    input.pressX, input.pressY = x, y
    input.dragX, input.dragY = x, y
    local piece = input.board:pieceAtScreen(input.camera, x, y)
    input.pressPiece = controls and input.flow:canSelect(piece) and piece or nil
    input.pressWasSelected = input.pressPiece and input.board:isSelected(input.pressPiece) or false
    input.deferPointerAction = deferAction
    input.controlAtPress = controls
    input.panning = false
    input.selectingPawns = false
end

function Pointer.released(input, x, y, button)
    if button ~= 1 then return end
    if input.pointerDown and input.deferPointerAction and not input.panning and not input.selectingPawns then
        local controls = input.canControl()
        if input.credits:mousepressed(x, y)
            or controls and input.menu:mousepressed(x, y)
            or controls and Targeting.handle(input.board, input.camera, input.menu, input.flow, x, y) then
            input:cancelPointer()
            return
        end
    end
    if input.pointerDown and input.controlAtPress and input.selectingPawns then
        input.board:selectPawnsInScreenRect(input.camera, input.pressX, input.pressY, x, y,
            input.pressPiece, input.flow.activeTeam)
    elseif input.pointerDown and input.controlAtPress and not input.panning then
        local piece = input.pressPiece or input.board:pieceAtScreen(input.camera, x, y)
        if input.pressWasSelected and piece == input.pressPiece then
            input.menu:openAt(x, y)
        elseif input.flow:canSelect(piece) then
            input.board:selectOnly(piece)
        else
            input.board:clearSelection()
        end
    end
    input:cancelPointer()
end

function Pointer.moved(input, x, y, dx, dy)
    if input.canControl() and input.board:isAttacking() then
        local column, row = input.board:cellAtScreen(input.camera, x, y)
        input.board:previewSkillAt(column, row)
    end
    if not input.pointerDown then return end
    input.dragX, input.dragY = x, y
    local dragged = math.abs(x - input.pressX) > input.dragThreshold
        or math.abs(y - input.pressY) > input.dragThreshold
    if not input.panning and not input.selectingPawns and dragged then
        input.selectingPawns = input.pressPiece and input.pressPiece.kind == "pawn"
        input.panning = not input.selectingPawns
    end
    if input.selectingPawns then
        input.board:selectPawnsInScreenRect(input.camera, input.pressX, input.pressY, x, y,
            input.pressPiece, input.flow.activeTeam)
    elseif input.panning then
        input.camera:pan(dx, dy)
    end
end

return Pointer
