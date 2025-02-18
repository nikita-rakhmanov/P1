class Enemy extends PhysicsObject {
    private PImage[] idleFrames;
    private float currentFrame = 0.0f;
    private boolean hFlip = false;

    public Enemy(PVector start) {
        super(start, 1.0f); // Initialize PhysicsObject with position and mass
        loadIdleFrames("PixelArt_Samurai/Enemies/Assassin/PNG/WithoutOutline/Assassin_Idle.png");
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

    void update() {
        // Apply gravity
        applyForce(new PVector(0, 0.5f)); // Adjust gravity as necessary

        currentFrame += 0.1; // Adjust speed as necessary
        if (currentFrame >= idleFrames.length) {
            currentFrame = 0;
        }

        // Update physics
        super.update();
    }

    void draw() {
        PImage frame = idleFrames[(int)currentFrame];
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