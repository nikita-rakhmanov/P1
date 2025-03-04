class Enemy extends PhysicsObject {
    private PImage[] idleFrames;
    private PImage[] hitFrames;
    private PImage[] attackFrames;
    private PImage[] deathFrames;
    private PImage[] runFrames;
    private float currentFrame = 0.0f;
    private boolean hFlip = false;
    private int health = 100; 
    private boolean isDead = false;
    private boolean isHit = false;
    private boolean isAttacking = false;
    private boolean isRunning = false;
    private float timer = 0.0f;
    private Character player; 
    private float radius = 20.0f; 
    private final static int ATTACK_COLLISION_START_FRAME = 4; 
    private final static int ATTACK_COLLISION_END_FRAME = 12; 
    private float patrolStartX; 
    private float patrolDistance = 50.0f; 
    private boolean patrollingRight = false; 


    public Enemy(PVector start, Character player) {
        super(start, 1.0f); 
        this.player = player;
        this.patrolStartX = start.x; 
                
        loadIdleFrames("PixelArt_Samurai/Enemies/Assassin/PNG/WithoutOutline/Assassin_Idle.png");
        loadHitFrames("PixelArt_Samurai/Enemies/Assassin/PNG/WithoutOutline/Assassin_Hit.png");
        loadAttackFrames("PixelArt_Samurai/Enemies/Assassin/PNG/WithoutOutline/Assassin_Attack.png");
        loadDeathFrames("PixelArt_Samurai/Enemies/Assassin/PNG/WithoutOutline/Assassin_Death.png");
        loadRunFrames("PixelArt_Samurai/Enemies/Assassin/PNG/WithoutOutline/Assassin_Run.png");
    }

    public void setPatrolDirection(boolean patrolRight) {
        this.patrollingRight = patrolRight;
        this.hFlip = !patrolRight; // Face the direction we're moving
    }

    // set patrol distance
    public void setPatrolDistance(float distance) {
        this.patrolDistance = distance;
    }

    public void setStatic(boolean isStatic) {
        this.isStatic = isStatic;
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
        int frameCount = 9; 
        int frameWidth = spriteSheet.width / frameCount; 
        hitFrames = new PImage[frameCount];

        for (int i = 0; i < frameCount; i++) {
            hitFrames[i] = spriteSheet.get(i * frameWidth, 0, frameWidth, spriteSheet.height);
        }
    }

    void loadDeathFrames(String imgPath) {
        PImage spriteSheet = loadImage(imgPath);
        int frameCount = 19; 
        int frameWidth = spriteSheet.width / frameCount; 
        deathFrames = new PImage[frameCount];

        for (int i = 0; i < frameCount; i++) {
            deathFrames[i] = spriteSheet.get(i * frameWidth, 0, frameWidth, spriteSheet.height);
        }
    }

    void loadAttackFrames(String imgPath) {
        PImage spriteSheet = loadImage(imgPath);
        int frameCount = 19; 
        int frameWidth = spriteSheet.width / frameCount; 
        attackFrames = new PImage[frameCount];

        for (int i = 0; i < frameCount; i++) {
            attackFrames[i] = spriteSheet.get(i * frameWidth, 0, frameWidth, spriteSheet.height);
        }
    }
    
    void loadRunFrames(String imgPath) {
        PImage spriteSheet = loadImage(imgPath);
        int frameCount = 8; 
        int frameWidth = spriteSheet.width / frameCount;
        runFrames = new PImage[frameCount];

        for (int i = 0; i < frameCount; i++) {
            runFrames[i] = spriteSheet.get(i * frameWidth, 0, frameWidth, spriteSheet.height);
        }
    }

    void takeDamage(int damage) {
        // Apply damage but ensure health doesn't go below 0
        health = max(0, health - damage);
        
        isHit = true;
        currentFrame = 0;
        
        if (health <= 0) {
            isDead = true;
            currentFrame = 0;
        }
    }

    void update() {
        // Process behavior and calculate forces
        updateBehavior();
        
        // handle physics
        super.update();
    }
    
    void updateBehavior() {
        if (isDead) {
            // Dead enemies don't move
            currentFrame += 0.2; 
            if (currentFrame >= deathFrames.length) {
                currentFrame = deathFrames.length - 1; // Stop at the last frame of the death animation
            }
            return;
        } 
        
        if (isHit) {
            // Hit enemies pause their current behavior
            isAttacking = false;
            currentFrame += 0.2; 
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
            
            currentFrame += 0.2; 
            
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
            currentFrame += 0.1; 
            
            if (currentFrame >= runFrames.length) {
                currentFrame = 0;
            }

            // ----- PATROL BEHAVIOR -----
            // Check if we've reached the patrol boundary
            if (patrollingRight && position.x >= patrolStartX + patrolDistance) {
                // Change direction to left
                patrollingRight = false;
                hFlip = true; // Face left
            } else if (!patrollingRight && position.x <= patrolStartX - patrolDistance) {
                // Change direction to right
                patrollingRight = true;
                hFlip = false; // Face right
            }
            
            // For static enemies, directly modify position instead of using forces
            if (isStatic) {
                float moveSpeed = 0.5;
                if (patrollingRight) {
                    position.x += moveSpeed; // Move right 
                } else {
                    position.x -= moveSpeed; // Move left 
                }
            } else {
                // Normal movements
                if (patrollingRight) {
                    applyForce(new PVector(0.5, 0)); // Move right
                } else {
                    applyForce(new PVector(-0.5, 0)); // Move left
                }
            }
            // ----- end of PATROL BEHAVIOR -----

            // Check if player is within attack range
            if (PVector.dist(position, player.position) < 25.0f) {
                isAttacking = true;
                isRunning = false;
                currentFrame = 0;
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
            currentFrame += 0.1;
            if (currentFrame >= idleFrames.length) {
                currentFrame = 0;
            }
            
            // Check if player is within attack range
            if (PVector.dist(position, player.position) < 25.0f) {
                isAttacking = true;
                isRunning = false;
                currentFrame = 0;
            } else {
                // Occasionally move 
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

    // Add this getter if it doesn't exist
    public boolean isDead() {
        return isDead;
    }
}