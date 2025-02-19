class Enemy extends PhysicsObject {
    private PImage[] idleFrames;
    private PImage[] hitFrames;
    private PImage[] attackFrames;
    private PImage[] deathFrames;
    private PImage[] runFrames;
    private PImage[] stunFrames;
    private float currentFrame = 0.0f;
    private boolean hFlip = false;
    private int health = 100; // Initial health
    private boolean isDead = false;
    private boolean isHit = false;
    private boolean isAttacking = false;
    private boolean isRunning = true; // Start with running
    private Character player; // Reference to the player character

    public Enemy(PVector start, Character player) {
        super(start, 1.0f); // Initialize PhysicsObject with position and mass
        this.player = player;
        loadIdleFrames("PixelArt_Samurai/Enemies/Assassin/PNG/WithoutOutline/Assassin_Idle.png");
        loadHitFrames("PixelArt_Samurai/Enemies/Assassin/PNG/WithoutOutline/Assassin_Hit.png");
        loadAttackFrames("PixelArt_Samurai/Enemies/Assassin/PNG/WithoutOutline/Assassin_Attack.png");
        loadDeathFrames("PixelArt_Samurai/Enemies/Assassin/PNG/WithoutOutline/Assassin_Death.png");
        loadRunFrames("PixelArt_Samurai/Enemies/Assassin/PNG/WithoutOutline/Assassin_Run.png");
        loadStunFrames("PixelArt_Samurai/Enemies/Assassin/PNG/WithoutOutline/Assassin_Stun.png");
    }

    void loadIdleFrames(String imgPath) {
        PImage spriteSheet = loadImage(imgPath);
        int frameCount = 8; // Number of frames in the sprite sheet
        int frameWidth = spriteSheet.width / frameCount; // Width of each frame
        idleFrames = new PImage[frameCount];

        for (int i = 0; i < frameCount; i++) {
            idleFrames[i] = spriteSheet.get(i * frameWidth, 0, frameWidth, spriteSheet.height);
        }
    }

    void loadHitFrames(String imgPath) {
        PImage spriteSheet = loadImage(imgPath);
        int frameCount = 9; // Number of frames in the sprite sheet
        int frameWidth = spriteSheet.width / frameCount; // Width of each frame
        hitFrames = new PImage[frameCount];

        for (int i = 0; i < frameCount; i++) {
            hitFrames[i] = spriteSheet.get(i * frameWidth, 0, frameWidth, spriteSheet.height);
        }
    }

    void loadDeathFrames(String imgPath) {
        PImage spriteSheet = loadImage(imgPath);
        int frameCount = 19; // Number of frames in the sprite sheet
        int frameWidth = spriteSheet.width / frameCount; // Width of each frame
        deathFrames = new PImage[frameCount];

        for (int i = 0; i < frameCount; i++) {
            deathFrames[i] = spriteSheet.get(i * frameWidth, 0, frameWidth, spriteSheet.height);
        }
    }

    void loadAttackFrames(String imgPath) {
        PImage spriteSheet = loadImage(imgPath);
        int frameCount = 19; // Number of frames in the sprite sheet
        int frameWidth = spriteSheet.width / frameCount; // Width of each frame
        attackFrames = new PImage[frameCount];

        for (int i = 0; i < frameCount; i++) {
            attackFrames[i] = spriteSheet.get(i * frameWidth, 0, frameWidth, spriteSheet.height);
        }
    }
    
    void loadRunFrames(String imgPath) {
        PImage spriteSheet = loadImage(imgPath);
        int frameCount = 8; // Number of frames in the sprite sheet
        int frameWidth = spriteSheet.width / frameCount; // Width of each frame
        runFrames = new PImage[frameCount];

        for (int i = 0; i < frameCount; i++) {
            runFrames[i] = spriteSheet.get(i * frameWidth, 0, frameWidth, spriteSheet.height);
        }
    }

    void loadStunFrames(String imgPath) {
        PImage spriteSheet = loadImage(imgPath);
        int frameCount = 22; // Number of frames in the sprite sheet
        int frameWidth = spriteSheet.width / frameCount; // Width of each frame
        stunFrames = new PImage[frameCount];

        for (int i = 0; i < frameCount; i++) {
            stunFrames[i] = spriteSheet.get(i * frameWidth, 0, frameWidth, spriteSheet.height);
        }
    }

    void takeHit() {
        health -= 10; // Reduce health by 10 on each hit
        isHit = true;
        currentFrame = 0;
        if (health <= 0) {
            isDead = true;
            currentFrame = 0;
        }
    }

    void update() {
        // Apply gravity
        applyForce(new PVector(0, 1.5f)); // Adjust gravity as necessary

        if (isDead) {
            currentFrame += 0.2; // Adjust speed as necessary
            if (currentFrame >= deathFrames.length) {
                currentFrame = deathFrames.length - 1; // Stop at the last frame of the death animation
            }
        } else if (isHit) {
            currentFrame += 0.2; // Adjust speed as necessary
            if (currentFrame >= hitFrames.length) {
                isHit = false;
                currentFrame = 0;
            }
        } else if (isAttacking) {
            currentFrame += 0.2; // Adjust speed as necessary
            if (currentFrame >= attackFrames.length) {
                isAttacking = false;
                currentFrame = 0;
            }
        } else if (isRunning) {
            currentFrame += 0.1; // Adjust speed as necessary
            if (currentFrame >= runFrames.length) {
                currentFrame = 0;
            }

            // Move enemy from edge to edge
            if (position.x <= radius || position.x >= width - radius) {
                velocity.x *= -1; // Reverse direction when hitting the boundary
                hFlip = !hFlip; // Flip the sprite horizontally
            }

            // Check if player is within attack range
            if (PVector.dist(position, player.position) < 35.0f) {
                isAttacking = true;
                isRunning = false;
                currentFrame = 0;
            } else {
                applyForce(new PVector(velocity.x > 0 ? 1 : -1, 0)); // Move left or right
            }
        } else {
            currentFrame += 0.1; // Adjust speed as necessary
            if (currentFrame >= idleFrames.length) {
                currentFrame = 0;
            }
        }

        // Update physics
        super.update();

        // Boundary checks to keep the object within the screen and bounce off edges
        if (position.x < radius) {
            position.x = radius;
            velocity.x *= -1; // Reverse horizontal velocity when hitting the boundary
        } else if (position.x > width - radius) {
            position.x = width - radius;
            velocity.x *= -1; // Reverse horizontal velocity when hitting the boundary
        }

        if (position.y < radius) {
            position.y = radius;
            velocity.y *= -1; // Reverse vertical velocity when hitting the boundary
        } else if (position.y > height - radius) {
            position.y = height - radius;
            velocity.y *= -1; // Reverse vertical velocity when hitting the boundary
        }
    }

    void draw() {
        PImage frame;
        if (isDead) {
            frame = deathFrames[(int)currentFrame];
        } else if (isHit) {
            frame = hitFrames[(int)currentFrame];
        } else if (isAttacking) {
            frame = attackFrames[(int)currentFrame];
        } else if (isRunning) {
            frame = runFrames[(int)currentFrame];
        } else {
            frame = idleFrames[(int)currentFrame];
        }

        if (hFlip) {
            pushMatrix();
            scale(-1.0, 1.0);
            image(frame, -this.position.x, this.position.y);
            popMatrix();
        } else {
            image(frame, this.position.x, this.position.y);
        }
    }
}