local CreditsOverlay = require("credits_overlay")

return function()
    local overlay = CreditsOverlay.new({})
    assert(not overlay.open)
    assert(overlay:keypressed("c") and overlay.open)
    assert(overlay:keypressed("escape") and not overlay.open)

    local left, top, width, height = overlay:buttonBounds()
    assert(overlay:mousepressed(left + width / 2, top + height / 2) and overlay.open)
    assert(overlay:mousepressed(0, 0) and not overlay.open)
    assert(not overlay:mousepressed(left + width + 1, top + height + 1))
end
