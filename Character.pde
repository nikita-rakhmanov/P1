class Character extends PhysicsObject {
    // animation variables
    private final static float ANIMATION_SPEED = 0.1f;
    private final static float ATTACK_ANIMATION_SPEED = 0.3f; // Faster attack animation speed
    private final static float MOVEMENT_SPEED = 1.5f;
    private final static float JUMP_FORCE = 8.0f; // Reduced force applied when jumping
    private final static float GRAVITY = 2.5f; // Gravitational force
    private final static float JUMP_HEIGHT = 8.0f;
    private final static int JUMP_PAUSE_DURATION = 1; // Number of frames to pause at the peak of the jump

    private PImage[] idleFrames;
    private PImage[] runFrames;
    private PImage[] jumpFrames;
    private PImage[] fallFrames;
    private PImage[][] attackFrames;
    private int[] attackFrameCounts = {12, 13, 9}; // Number of frames in each attack animation
    private float currentFrame = 0.0f;
    private boolean hFlip = false;

    private boolean movingLeft, movingRight, jumpingUp, fallingDown, attacking, attackingFlag;
    private float jumpStartY;
    private int jumpPauseCounter = 0;
    private int currentAttackIndex = 0;

    public Character(PVector start) {
        super(start, 1.0f); // Initialize PhysicsObject with position and mass
        // load idleImages into idleFrames
        this.idleFrames = new PImage[16];
        for (int i = 0; i < 16; i++) {
            String framePath = "CharacterPack/Player/Idle/player_idle_" + nf(i + 1, 2) + ".png";
            this.idleFrames[i] = loadImage(framePath);
        }
        // load runImages into runFrames
        this.runFrames = new PImage[10];
        for (int i = 0; i < 10; i++) {
            String framePath = "CharacterPack/Player/Run/player_run_" + nf(i + 1, 2) + ".png";
            this.runFrames[i] = loadImage(framePath);
        }
        // load jumpImages into jumpFrames
        this.jumpFrames = new PImage[6];
        for (int i = 0; i < 6; i++) {
            String framePath = "CharacterPack/Player/JumpUp/player_jumpup_" + nf(i + 1, 2) + ".png";
            this.jumpFrames[i] = loadImage(framePath);
        }
        // load fallImages into fallFrames
        this.fallFrames = new PImage[6];
        for (int i = 0; i < 6; i++) {
            String framePath = "CharacterPack/Player/JumpDown/player_jumpdown_" + nf(i + 1, 2) + ".png";
            this.fallFrames[i] = loadImage(framePath);
        }
        // load attackImages into attackFrames
        this.attackFrames = new PImage[3][];
        for (int j = 0; j < 3; j++) {
            this.attackFrames[j] = new PImage[attackFrameCounts[j]];
            for (int i = 0; i < attackFrameCounts[j]; i++) {
                String framePath = "CharacterPack/Player/Attack/Attack0" + (j + 1) + "/player_attack0" + (j + 1) + "_" + nf(i + 1, 2) + ".png";
                this.attackFrames[j][i] = loadImage(framePath);
            }
        }
    }

    public void update() {
        // Apply gravity
        applyForce(new PVector(0, GRAVITY));

        // update animation
        if (attacking) {
            currentFrame += ATTACK_ANIMATION_SPEED;
            if (currentFrame >= attackFrames[currentAttackIndex].length) {
                attacking = false;
                currentFrame = 0;
            } else {
                currentFrame %= attackFrames[currentAttackIndex].length;
            }
        } else {
            currentFrame += ANIMATION_SPEED;
            if (jumpingUp) {
                currentFrame %= jumpFrames.length;
            } else if (fallingDown) {
                currentFrame %= fallFrames.length;
            } else if (movingLeft || movingRight) {
                currentFrame %= runFrames.length;
            } else {
                currentFrame %= idleFrames.length;
            }
        }

        // update position
        //TODO: movement should be just coords change: no physics for character
        //CONT: but add force movement for colision detection with other objects
        if (movingLeft) {
            applyForce(new PVector(-MOVEMENT_SPEED, 0));
            this.hFlip = true;
        }
        if (movingRight) {
            applyForce(new PVector(MOVEMENT_SPEED, 0));
            this.hFlip = false;
        }
        if (jumpingUp) {
            applyForce(new PVector(0, -JUMP_FORCE));
            if (this.position.y <= jumpStartY - JUMP_HEIGHT) {
                jumpingUp = false;
                jumpPauseCounter = JUMP_PAUSE_DURATION;
            }
        }
        if (jumpPauseCounter > 0) {
            jumpPauseCounter--;
            if (jumpPauseCounter == 0) {
                fallingDown = true;
            }
        }
        if (fallingDown) {
            if (this.position.y >= jumpStartY) {
                this.position.y = jumpStartY;
                fallingDown = false;
                velocity.y = 0; // Stop vertical velocity when landing
            }
        }

        // Update physics
        super.update();
    }

    public void draw() {
        PImage[] frames;
        if (attacking) {
            frames = attackFrames[currentAttackIndex];
        } else if (jumpingUp) {
            frames = jumpFrames;
        } else if (fallingDown) {
            frames = fallFrames;
        } else if (movingLeft || movingRight) {
            frames = runFrames;
        } else {
            frames = idleFrames;
        }

        PImage frame = frames[(int)currentFrame];
        if (this.hFlip) {
            pushMatrix();
            scale(-1.0, 1.0);
            image(frame, -this.position.x, this.position.y);
            popMatrix();
        } else {
            image(frame, this.position.x, this.position.y);
        }
    }

    // getters of position (for the camera)
    public float getX() {
        return this.position.x;
    }

    public float getY() {
        return this.position.y;
    }

    void handleKeyPressed(char key) {
        if (key == 'a' || key == 'A') {
            movingLeft = true;
        } else if (key == 'd' || key == 'D') {
            movingRight = true;
        } else if (key == 'w' || key == 'W') {
            if (!jumpingUp && !fallingDown) {
                jumpingUp = true;
                fallingDown = false;
                jumpStartY = this.position.y;
            }
        } else if (key == 's' || key == 'S') {
            // jump down immediately if currently jumping up
            if (jumpingUp) {
                jumpingUp = false;
                jumpPauseCounter = 0;
                fallingDown = true;
            }
        } else if (key == ' ' && !attackingFlag) {
            attacking = true;
            attackingFlag = true;
            currentFrame = 0;
            currentAttackIndex = (currentAttackIndex + 1) % attackFrames.length;
        }
    }

    void handleKeyReleased(char key) {
        if (key == 'a' || key == 'A') {
            movingLeft = false;
        } else if (key == 'd' || key == 'D') {
            movingRight = false;
        } else if (key == ' ') {
            attackingFlag = false;
        }
    }
}