Background bg;
Character character;
Platform ground;
ArrayList<Enemy> enemies = new ArrayList<Enemy>();
ArrayList<Spring> springs = new ArrayList<Spring>();
ArrayList<PlatformObject> platforms = new ArrayList<PlatformObject>();
boolean attackLanded = false;
boolean gameOver = false;
boolean gameStarted = false;
PhysicsEngine physicsEngine;

// Create a PlatformObject class for individual platforms
class PlatformObject extends PhysicsObject {
  PImage platformImage;
  
  PlatformObject(float x, float y) {
    super(new PVector(x, y), 0.0f); // Static object with infinite mass
    this.isStatic = true;
    this.radius = 25.0f;
    
    // Load the platform image
    platformImage = loadImage("CharacterPack/GPE/platforms/platform_through.png");
  }
  
  void draw() {
    image(platformImage, position.x, position.y);
  }
}

void setup() {
  size(1024, 768);
  noSmooth();
  imageMode(CENTER);
  textMode(CENTER);

  // Initialize physics engine
  physicsEngine = new PhysicsEngine();

  // Load background and ground
  bg = new Background("CharacterPack/Enviro/BG/trees_bg.png");
  ground = new Platform("CharacterPack/GPE/platforms/platform_through.png");
  
  // Create character in the middle
  character = new Character(new PVector(width / 2, height - 30));
  
  // Create enemies on both sides
  Enemy enemy1 = new Enemy(new PVector(width / 4, height - 30), character);
  Enemy enemy2 = new Enemy(new PVector(width * 3 / 4, height - 30), character);
  enemies.add(enemy1);
  enemies.add(enemy2);
  
  // Create platforms for vertical traversal (from bottom to top)
  // First layer - low platforms
  platforms.add(new PlatformObject(width * 0.25f, height - 150));
  platforms.add(new PlatformObject(width * 0.75f, height - 150));
  
  // Second layer - middle platforms
  platforms.add(new PlatformObject(width * 0.5f, height - 270));
  
  // Third layer - higher platforms
  platforms.add(new PlatformObject(width * 0.25f, height - 390));
  platforms.add(new PlatformObject(width * 0.75f, height - 390));
  
  // Fourth layer - high platforms
  platforms.add(new PlatformObject(width * 0.5f, height - 510));
  
  // Top layer - highest platform (goal)
  platforms.add(new PlatformObject(width * 0.5f, height - 630));
  
  // Add springs at strategic locations
  springs.add(new Spring(new PVector(width * 0.15f, height - 20))); // Left lower spring
  springs.add(new Spring(new PVector(width * 0.85f, height - 20))); // Right lower spring
  springs.add(new Spring(new PVector(width * 0.5f, height - 150))); // Middle spring on first platform
  
  // Add objects to physics engine
  physicsEngine.addObject(character);
  for (Enemy enemy : enemies) {
    physicsEngine.addObject(enemy);
  }
  
  for (Spring spring : springs) {
    physicsEngine.addObject(spring);
  }
  
  for (PlatformObject platform : platforms) {
    physicsEngine.addObject(platform);
  }
  
  // Add force generators
  GravityForce gravity = new GravityForce(1.5f);
  DragForce drag = new DragForce(0.01f);
  
  // Apply forces to character
  physicsEngine.addForceGenerator(character, gravity);
  physicsEngine.addForceGenerator(character, drag);
  
  // Apply forces to enemies
  for (Enemy enemy : enemies) {
    physicsEngine.addForceGenerator(enemy, gravity);
    physicsEngine.addForceGenerator(enemy, drag);
  }
}

void keyPressed() {
  if (!gameStarted) {
    if (key == ENTER || key == RETURN) {
      gameStarted = true;
    }
  } else if (!gameOver) { // Only process inputs when game is active
    character.handleKeyPressed(key);
  } else if (key == 'r' || key == 'R') { // Allow restart with 'R' key
    resetGame();
  }
}

void keyReleased() {
  if (gameStarted && !gameOver) { // Only process inputs when game is active
    character.handleKeyReleased(key);
  }
}

void mousePressed() {
  if (gameStarted && !gameOver && mouseButton == LEFT) { // Only process inputs when game is active
    character.shoot();
  }
}

void draw() {
  background(0);
  bg.display();
  ground.display();
  
  if (!gameStarted) {
    displayStartScreen();
    return;
  }
  
  if (!gameOver) {
    // Update physics engine
    physicsEngine.update();
    
    // Update character and enemies
    character.update();
    for (Enemy enemy : enemies) {
      enemy.update();
    }
    
    // Handle bullet collisions with all enemies
    handleBulletCollisions();
    
    // Handle attack collisions with all enemies
    handleAttackCollisions();
    
    // Check if any enemy is attacking the player
    handleEnemyAttacks();
    
    // Check if player is dead
    if (character.isDead) {
      gameOver = true;
    }
    
    // Check for platform collisions
    handlePlatformCollisions();
  }
  
  // Check for spring collisions
  checkSprings();
  
  // Draw all game objects
  drawGameObjects();
  displayHUD();
}

void handleBulletCollisions() {
  ArrayList<Bullet> bullets = character.getBullets();
  for (int i = bullets.size() - 1; i >= 0; i--) {
    Bullet bullet = bullets.get(i);
    boolean hitDetected = false;
    
    for (Enemy enemy : enemies) {
      if (!hitDetected && bullet.isActive() && !enemy.isDead && 
          PVector.dist(bullet.position, enemy.position) < enemy.radius + bullet.radius) {
        // Hit detected
        PVector force = PVector.sub(enemy.position, bullet.position).normalize().mult(5);
        force.y = -5; // Add upward force
        enemy.applyForce(force);
        enemy.takeDamage(10);
        bullet.deactivate();
        bullets.remove(i);
        hitDetected = true;
      }
    }
  }
}

void handleAttackCollisions() {
  if (character.isAttacking() && character.isAttackCollisionFrame()) {
    for (Enemy enemy : enemies) {
      if (!enemy.isDead && character.isInAttackRange(enemy)) {
        if (!attackLanded) {
          PVector force = PVector.sub(enemy.position, character.position).normalize().mult(10);
          force.y = -10; // Add upward force
          enemy.applyForce(force);
          enemy.takeDamage(20);
          attackLanded = true;
        }
      }
    }
  } else {
    attackLanded = false;
  }
}

void handleEnemyAttacks() {
  for (Enemy enemy : enemies) {
    if (enemy.isAttacking() && enemy.isInAttackRange(character) && 
        enemy.isInAttackCollisionFrame() && !character.isDead) {
      PVector force = PVector.sub(character.position, enemy.position).normalize().mult(10);
      force.y = -10;
      character.applyForce(force);
      character.takeDamage(10);
    }
  }
}

void handlePlatformCollisions() {
  float characterFeetY = character.position.y + character.radius;
  float characterHeadY = character.position.y - character.radius;
  
  // Only check if character is falling down
  if (character.velocity.y > 0) {
    for (PlatformObject platform : platforms) {
      float platformTopY = platform.position.y - platform.platformImage.height/2;
      boolean isAbovePlatform = abs(character.position.x - platform.position.x) < platform.platformImage.width/2;
      
      // If character is above the platform and within a small vertical distance
      if (isAbovePlatform && characterFeetY >= platformTopY && characterFeetY <= platformTopY + 10) {
        // Stop falling and place character on the platform
        character.position.y = platformTopY - character.radius;
        character.velocity.y = 0;
        character.fallingDown = false;
        character.jumpStartY = character.position.y;
        break;
      }
    }
  }
}

void checkSprings() {
  for (Spring spring : springs) {
    // Calculate distance between character's feet and spring's top surface
    float characterFeetY = character.position.y + character.getRadius();
    float springTopY = spring.position.y - spring.platformImage.height/2;
    
    // Use simplified collision check
    boolean isAboveSpring = abs(character.position.x - spring.position.x) < spring.platformImage.width/2 * 0.7f;
    boolean isTouchingSpring = characterFeetY >= springTopY - 10 && characterFeetY <= springTopY + 10;
    boolean isFalling = character.velocity.y > 1.0;
    
    if (isAboveSpring && isTouchingSpring && isFalling) {
      character.position.y = springTopY - character.getRadius();
      
      if (spring.compress()) {
        // Clear any accumulated forces that might counteract the bounce
        character.clearForces();
        
        // Apply a powerful upward velocity
        character.velocity.y = -spring.getBounceForce();
        
        // Add a horizontal boost in the direction the character is moving
        if (character.velocity.x != 0) {
          character.velocity.x *= 1.3; // Increase horizontal momentum by 30%
        }
        
        // Set spring bounce state
        character.setSpringBounce(true);
        character.jumpingUp = true;
        character.fallingDown = false;
        character.jumpStartY = character.position.y;

        // Add a more dramatic visual effect for super jump
        pushStyle();
        fill(255, 255, 0, 150); // Brighter yellow flash
        noStroke();
        ellipse(spring.position.x, spring.position.y, 100, 50); // Larger effect
        
        // Add some particles for extra effect
        for (int i = 0; i < 10; i++) {
          float particleX = spring.position.x + random(-40, 40);
          float particleY = spring.position.y + random(-10, 10);
          fill(255, random(200, 255), 0, 200);
          ellipse(particleX, particleY, random(5, 15), random(5, 15));
        }
        popStyle();
      }
    }
  }
}

void drawGameObjects() {
  // Draw platforms
  for (PlatformObject platform : platforms) {
    platform.draw();
  }
  
  // Draw springs
  for (Spring spring : springs) {
    spring.draw();
  }
  
  // Draw character
  character.draw();
  
  // Draw enemies
  for (Enemy enemy : enemies) {
    enemy.draw();
  }
}

void displayHUD() {
  // Health display
  fill(255);
  textSize(20);
  text("Health: " + character.getHealth(), 50, 50);
  for (int i = 0; i < enemies.size(); i++) {
    text("Health: " + enemies.get(i).getHealth(), width - 150, 50 + i * 30);
  }
  
  // Game over message if applicable
  if (gameOver) {
    displayGameOver();
  }
}

void displayStartScreen() {
  // Semi-transparent overlay for better text visibility
  fill(0, 0, 0, 150);
  rect(0, 0, width, height);
  
  // Game title
  fill(255);
  textSize(80);
  textAlign(CENTER, CENTER);
  text("OVER S∞∞N", width/2, height/3 - 40);
  
  // Controls section
  textSize(30);
  text("CONTROLS", width/2, height/2 - 60);
  
  textSize(24);
  int yPos = height/2;
  text("A / D - Move left / right", width/2, yPos);
  text("W - Jump", width/2, yPos + 35);
  text("S - Fast fall", width/2, yPos + 70);
  text("SPACE - Attack", width/2, yPos + 105);
  text("SHIFT - Glide", width/2, yPos + 140);
  
  // Start prompt
  textSize(30);
  fill(255, 255, 0);
  text("Press ENTER to start", width/2, height - 100);
  
  // Reset text alignment
  textAlign(LEFT, BASELINE);
}

void displayGameOver() {
  // Semi-transparent overlay
  fill(0, 0, 0, 150);
  rect(0, 0, width, height);
  
  // Game over text
  fill(255, 0, 0);
  textSize(80);
  textAlign(CENTER, CENTER);
  text("GAME OVER", width/2, height/2 - 40);
  
  // Instructions to restart
  fill(255);
  textSize(30);
  text("Press 'R' to restart", width/2, height/2 + 40);
  
  // Reset text alignment
  textAlign(LEFT, BASELINE);
}

void resetGame() {
  // Reset game state
  gameOver = false;
  attackLanded = false;
  
  // Clear all collections
  physicsEngine = new PhysicsEngine();
  enemies.clear();
  springs.clear();
  platforms.clear();
  
  // Recreate character, enemies, platforms and springs
  character = new Character(new PVector(width / 2, height - 30));
  
  // Recreate enemies
  Enemy enemy1 = new Enemy(new PVector(width / 4, height - 30), character);
  Enemy enemy2 = new Enemy(new PVector(width * 3 / 4, height - 30), character);
  enemies.add(enemy1);
  enemies.add(enemy2);
  
  // Recreate platforms (same layout as setup)
  platforms.add(new PlatformObject(width * 0.25f, height - 150));
  platforms.add(new PlatformObject(width * 0.75f, height - 150));
  platforms.add(new PlatformObject(width * 0.5f, height - 270));
  platforms.add(new PlatformObject(width * 0.25f, height - 390));
  platforms.add(new PlatformObject(width * 0.75f, height - 390));
  platforms.add(new PlatformObject(width * 0.5f, height - 510));
  platforms.add(new PlatformObject(width * 0.5f, height - 630));
  
  // Recreate springs
  springs.add(new Spring(new PVector(width * 0.15f, height - 20)));
  springs.add(new Spring(new PVector(width * 0.85f, height - 20)));
  springs.add(new Spring(new PVector(width * 0.5f, height - 150)));
  
  // Add objects to physics engine
  physicsEngine.addObject(character);
  for (Enemy enemy : enemies) {
    physicsEngine.addObject(enemy);
  }
  
  for (Spring spring : springs) {
    physicsEngine.addObject(spring);
  }
  
  for (PlatformObject platform : platforms) {
    physicsEngine.addObject(platform);
  }
  
  // Add force generators
  GravityForce gravity = new GravityForce(1.5f);
  DragForce drag = new DragForce(0.01f);
  
  physicsEngine.addForceGenerator(character, gravity);
  physicsEngine.addForceGenerator(character, drag);
  
  for (Enemy enemy : enemies) {
    physicsEngine.addForceGenerator(enemy, gravity);
    physicsEngine.addForceGenerator(enemy, drag);
  }
}