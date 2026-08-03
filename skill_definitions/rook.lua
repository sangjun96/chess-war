return {
    name = "Siege Breaker",
    audio = "rook",
    range = 6,
    effectRadius = 1,
    fps = 18,
    frameCount = 14,
    layers = {
        {
            image = "assets/skill-effects/royal-calamity/crown-firebomb.png",
            frameWidth = 64, frameHeight = 64, frameCount = 14, fps = 20,
            scale = 1.45, offsetY = -24,
        },
        {
            image = "assets/skill-effects/combo/siege-explosion.png",
            frameWidth = 96, frameHeight = 96, frameCount = 12, fps = 18,
            scale = 1.45, offsetY = -32, delay = 0.08,
        },
        {
            image = "assets/skill-effects/royal-calamity/impact-burst.png",
            frameWidth = 160, frameHeight = 160, frameCount = 8, fps = 24,
            scale = 1.15, offsetY = -36, delay = 0.12,
        },
    },
}
