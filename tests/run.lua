local tests = {
    (require("tests.test_piece_skills")),
    (require("tests.test_skill_effects")),
    (require("tests.test_combat_effect")),
    (require("tests.test_skill_attack")),
    (require("tests.test_targeting_safety")),
    (require("tests.test_game_flow")),
}

for _, test in ipairs(tests) do test() end

print("All tests passed (" .. #tests .. " suites).")
