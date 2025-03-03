class Enemy extends PhysicsObject {
    private PImage[] idleFrames;
    private PImage[] hitFrames;
    private PImage[] attackFrames;
    private PImage[] deathFrames;
    private PImage[] runFrames;
    private float currentFrame = 0.0f;
    private boolean hFlip = false;
    private int health = 100; // Initial health
    private boolean isDead = false;
    private boolean isHit = false;
    private boolean isAttacking = false;
    private boolean isRunning = false;
    private float timer = 0.0f;
    private Character player; // Reference to the player character
    private float radius = 20.0f; // Radius of the enemy
    private final static int ATTACK_COLLISION_START_FRAME = 4; // Start frame for collision detection
    private final static int ATTACK_COLLISION_END_FRAME = 12; // End frame for collision detection


    public Enemy(PVector start, Character player) {
        super(start, 1.0f); // Initialize PhysicsObject with position and mass
        this.player = player;
        loadIdleFrames("PixelArt_Samurai/Enemies/Assassin/PNG/WithoutOutline/Assassin_Idle.png");
        loadHitFrames("PixelArt_Samurai/Enemies/Assassin/PNG/WithoutOutline/Assassin_Hit.png");
        loadAttackFrames("PixelArt_Samurai/Enemies/Assassin/PNG/WithoutOutline/Assassin_Attack.png");
        loadDeathFrames("PixelArt_Samurai/Enemies/Assassin/PNG/WithoutOutline/Assassin_Death.png");
        loadRunFrames("PixelArt_Samurai/Enemies/Assassin/PNG/WithoutOutline/Assassin_Run.png");
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

    void takeDamage(int damage) {
        health -= damage; // Reduce health by 10 on each hit
        isHit = true;
        currentFrame = 0;
        if (health <= 0) {
            isDead = true;
            currentFrame = 0;
        }
    }

    void update() {
        // Process AI behavior and calculate forces
        updateBehavior();
        
        // Call the parent update method to handle physics
        super.update();
    }
    
    void updateBehavior() {
        if (isDead) {
            // Dead enemies don't move
            currentFrame += 0.2; // Adjust speed as necessary
            if (currentFrame >= deathFrames.length) {
                currentFrame = deathFrames.length - 1; // Stop at the last frame of the death animation
            }
            return;
        } 
        
        if (isHit) {
            // Hit enemies pause their current behavior
            isAttacking = false;
            currentFrame += 0.2; // Adjust speed as necessary
            if (currentFrame >= hitFrames.length) {
                isHit = false;
                currentFrame = 0;
            }
            return;
        }
        
        if (isAttacking) {
            // Check which direction the player is in
            if (player.position.x < position.x) {
                hFlip = true;
            } else {
                hFlip = false;
            }
            
            currentFrame += 0.2; // Adjust speed as necessary
            
            // Check if the player is in attack range during the attack frames
            isInAttackCollisionFrame();
            isInAttackRange(player);
            
            // End attack animation
            if (currentFrame >= attackFrames.length) {
                isAttacking = false;
                isRunning = true;
                currentFrame = 0;
            }
        } 
        else if (isRunning) {
            currentFrame += 0.1; // Adjust speed as necessary
            
            if (currentFrame >= runFrames.length) {
                currentFrame = 0;
            }

            // Move enemy from edge to edge
            if (position.x <= radius) {
                position.x = radius + 1; // Move away from the boundary
                velocity.x = abs(velocity.x); // Ensure velocity is positive to move right
                hFlip = false; // Face right
            } else if (position.x >= width - radius) {
                position.x = width - radius - 1; // Move away from the boundary
                velocity.x = -abs(velocity.x); // Ensure velocity is negative to move left
                hFlip = true; // Face left
            }

            // Check if player is within attack range
            if (PVector.dist(position, player.position) < 25.0f) {
                isAttacking = true;
                isRunning = false;
                currentFrame = 0;
            } else {
                // Apply movement force based on facing direction
                if (hFlip) {
                    applyForce(new PVector(-0.5, 0)); // Move left
                } else {
                    applyForce(new PVector(0.5, 0)); // Move right
                }
            }

            // Run for a bit and then stop
            timer += 0.1;
            if (timer >= 15.0) { 
                isRunning = false;
                currentFrame = 0;
                timer = 0.0;
            }
        } 
        else {
            // Idle state
            currentFrame += 0.1; // Adjust speed as necessary
            if (currentFrame >= idleFrames.length) {
                currentFrame = 0;
            }
            
            // Check if player is within attack range
            if (PVector.dist(position, player.position) < 25.0f) {
                isAttacking = true;
                isRunning = false;
                currentFrame = 0;
            } else {
                // Occasionally move even while idle
                if (hFlip) {
                    applyForce(new PVector(-0.5, 0)); // Move left
                } else {
                    applyForce(new PVector(0.5, 0)); // Move right
                }
            }

            // Wait for a bit before starting to run
            timer += 0.1;
            if (timer >= 10.0) { 
                isRunning = true;
                currentFrame = 0;
                timer = 0.0;
            }
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

    public boolean isInAttackRange(Character player) {
        if (player.position.x >= position.x - 30 && player.position.x <= position.x + 30) {
                return true;
            } else {
                return false;
            }
    }

    public boolean isInAttackCollisionFrame() {
        if (currentFrame >= ATTACK_COLLISION_START_FRAME && currentFrame <= ATTACK_COLLISION_END_FRAME) {
            return true;
        } else {
            return false;
        }
    }

    public boolean isAttacking() {
        return isAttacking;
    }

    // get health
    public int getHealth() {
        return health;
    }
}