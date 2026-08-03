local tests = {
    (require("tests.test_piece_skills")),
    (require("tests.test_skill_effects")),
    (require("tests.test_tile_batch_renderer")),
    (require("tests.test_combat_effect")),
    (require("tests.test_skill_attack")),
    (require("tests.test_targeting_safety")),
    (require("tests.test_game_flow")),
    (require("tests.test_credits_overlay")),
    (require("tests.test_ai_actions")),
    (require("tests.test_ai_search")),
    (require("tests.test_ai_controller")),
    (require("tests.test_difficulty_menu")),
    (require("tests.test_camera")),
    (require("tests.test_touch_input")),
}

for _, test in ipairs(tests) do test() end

print("All tests passed (" .. #tests .. " suites).")
