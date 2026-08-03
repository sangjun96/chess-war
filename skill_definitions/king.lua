return {
    name = "Royal Calamity",
    audio = "king",
    range = 6,
    effectRadius = 2,
    fps = 15,
    frameCount = 15,
    layers = {
        {
            image = "assets/skill-effects/royal-calamity/crown-lightning.png",
            frameWidth = 128, frameHeight = 128, frameCount = 5, fps = 18,
            scale = 1.65, offsetY = -50, directional = true,
        },
        {
            image = "assets/skill-effects/royal-calamity/crown-firebomb.png",
            frameWidth = 64, frameHeight = 64, frameCount = 14, fps = 20,
            scale = 2.2, offsetY = -32, delay = 0.08,
        },
        {
            image = "assets/skill-effects/royal-calamity/epic-explosion.png",
            frameWidth = 192, frameHeight = 192, frameCount = 15, fps = 15,
            scale = 1.25, offsetY = -42, delay = 0.13,
        },
        {
            image = "assets/skill-effects/royal-calamity/impact-burst.png",
            frameWidth = 160, frameHeight = 160, frameCount = 8, fps = 24,
            scale = 1.85, offsetY = -42, delay = 0.15,
        },
    },
}
