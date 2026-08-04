local DifficultyMenu = require("difficulty_menu")

return function()
    local menu = DifficultyMenu.new({})
    assert(menu.active and menu:keypressed("1") == nil)
    assert(menu:keypressed("return") == "easy" and not menu.active)
    menu:show()
    menu:keypressed("3")
    assert(menu:keypressed("kpenter") == "hard")
    menu:show()
    menu:keypressed("4")
    assert(menu:keypressed("return") == "hard_vs_hard")
end
