return {
    name = "Thunder Charge",
    audio = {
        asset = "knight", delay = 0.32, duration = 0.90,
        fade = 0.15, volume = 0.72, pitch = 1.08,
    },
    range = 4,
    effectRadius = 0,
    fps = 15,
    frameCount = 10,
    feedback = {
        impactAt = 0.34, duration = 0.36, radius = 0.92, offsetY = -30,
        color = { 0.64, 0.48, 1 },
    },
    layers = {
        {
            image = "assets/skill-effects/combo/dark-bolt.png",
            frameWidth = 88, frameHeight = 88, frameCount = 8, fps = 15,
            scaleFrom = 0.72, scaleTo = 1.12, offsetY = -34,
            directional = true, anchor = "travel", travelDuration = 0.34,
        },
        {
            image = "assets/skill-effects/royal-calamity/crown-lightning.png",
            frameWidth = 128, frameHeight = 128, frameCount = 5, fps = 15,
            scale = 1.05, offsetY = -42, delay = 0.30, directional = true,
        },
        {
            image = "assets/skill-effects/combo/thunder-burst.png",
            frameWidth = 96, frameHeight = 96, frameCount = 10, fps = 15,
            scaleFrom = 0.9, scaleTo = 1.25, offsetY = -34, delay = 0.34,
        },
        {
            image = "assets/skill-effects/lightning.png",
            frameWidth = 32, frameHeight = 32, frameCount = 8, fps = 15,
            scale = 2.45, offsetY = -30, delay = 0.40,
        },
        {
            image = "assets/skill-effects/sparkle.png",
            frameWidth = 32, frameHeight = 32, frameCount = 14, fps = 15,
            scale = 1.55, offsetY = -34, delay = 0.44, fadeOut = 0.4,
        },
    },
}
