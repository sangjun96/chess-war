local TouchInput = require("touch_input")

return function()
    local calls = { pressed = 0, released = 0, moved = 0, cancelled = 0, zoomed = 0, panned = 0 }
    local input = {
        camera = {
            zoomScaleAt = function(_, _, _, scale)
                assert(scale > 1)
                calls.zoomed = calls.zoomed + 1
            end,
            pan = function(_, dx, _)
                assert(dx > 0)
                calls.panned = calls.panned + 1
            end,
        },
        touchPointerPressed = function() calls.pressed = calls.pressed + 1 end,
        touchPointerReleased = function() calls.released = calls.released + 1 end,
        mousemoved = function() calls.moved = calls.moved + 1 end,
        cancelPointer = function() calls.cancelled = calls.cancelled + 1 end,
    }
    local touch = TouchInput.new(input)

    touch:pressed("one", 10, 10)
    touch:moved("one", 15, 12, 5, 2)
    touch:released("one", 15, 12)
    assert(calls.pressed == 1 and calls.moved == 1 and calls.released == 1)

    touch:pressed("left", 0, 0)
    touch:pressed("right", 20, 0)
    touch:moved("right", 40, 0, 20, 0)
    assert(calls.cancelled == 1 and calls.zoomed == 1 and calls.panned == 1)
    touch:released("right", 40, 0)
    touch:released("left", 0, 0)
end
