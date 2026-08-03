return {
    name = "Royal Calamity",
    audio = {
        asset = "king", delay = 0.18, duration = 0.98,
        fade = 0.12, volume = 0.82, pitch = 0.98,
    },
    range = 6,
    effectRadius = 2,
    fps = 15,
    frameCount = 15,
    feedback = {
        impactAt = 0.28, duration = 0.55, radius = 2.15, offsetY = -36,
        color = { 1, 0.72, 0.18 },
    },
    layers = {
        {
            image = "assets/skill-effects/defense.png",
            frameWidth = 64, frameHeight = 64, frameCount = 18, fps = 15,
            scale = 1.2, offsetY = -32, anchor = "source", fadeOut = 0.25,
        },
        {
            image = "assets/skill-effects/royal-calamity/crown-lightning.png",
            frameWidth = 128, frameHeight = 128, frameCount = 5, fps = 15,
            scale = 1.65, offsetY = -50, delay = 0.12, directional = true,
        },
        {
            image = "assets/skill-effects/royal-calamity/crown-firebomb.png",
            frameWidth = 64, frameHeight = 64, frameCount = 14, fps = 15,
            scale = 2.2, offsetY = -32, delay = 0.18,
        },
        {
            image = "assets/skill-effects/royal-calamity/epic-explosion.png",
            frameWidth = 192, frameHeight = 192, frameCount = 15, fps = 15,
            scaleFrom = 0.9, scaleTo = 1.28, offsetY = -42, delay = 0.24,
        },
        {
            image = "assets/skill-effects/royal-calamity/impact-burst.png",
            frameWidth = 160, frameHeight = 160, frameCount = 8, fps = 15,
            scale = 1.85, offsetY = -42, delay = 0.30,
        },
        {
            image = "assets/skill-effects/sparkle.png",
            frameWidth = 32, frameHeight = 32, frameCount = 14, fps = 15,
            scale = 2.0, offsetY = -42, delay = 0.36, fadeOut = 0.4,
        },
    },
}
