Background bg;
Character character;
Platform platform;
Enemy enemy;
Water water;
boolean attackLanded = false;
boolean gameOver = false; // Track game over state
boolean gameStarted = false; // Track if game has started
ArrayList<Spring> springs = new ArrayList<Spring>();

// Our new physics engine
PhysicsEngine physicsEngine;

void setup() {
  size(1024, 768);
  noSmooth();

  imageMode(CENTER);
  textMode(CENTER);

  // Initialize physics engine
  physicsEngine = new PhysicsEngine();

  bg = new Background("CharacterPack/Enviro/BG/trees_bg.png");
  character = new Character(new PVector(width / 2, height - 20)); // Spawn at the bottom middle
  platform = new Platform("CharacterPack/GPE/platforms/platform_through.png");
  enemy = new Enemy(new PVector(width / 2 + 100, height - 20), character); // Spawn enemy to the right of the player

  // Create springs and add them to the list
  springs.add(new Spring(new PVector(width / 4, height - 20)));
  springs.add(new Spring(new PVector(width * 3 / 4, height - 20)));

  // Create water at the bottom portion of the screen
  water = new Water(0, height - 150, width, 150);
  
  // Add objects to physics engine
  physicsEngine.addObject(character);
  physicsEngine.addObject(enemy);

  // Add springs to physics engine
  for (Spring spring : springs) {
    physicsEngine.addObject(spring);
  }
  
  // Add force generators
  
  // Gravity force for character and enemy
  physicsEngine.addForceGenerator(character, new GravityForce(1.5f));
  physicsEngine.addForceGenerator(enemy, new GravityForce(1.5f));
  
  // Add drag force for a bit of air resistance
  physicsEngine.addForceGenerator(character, new DragForce(0.01f));
  physicsEngine.addForceGenerator(enemy, new DragForce(0.01f));
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
  platform.display();
  
  if (!gameStarted) {
    displayStartScreen();
    return; // Skip the rest of the draw loop if game hasn't started
  }
  
  if (!gameOver) {
    // Update physics 
    physicsEngine.update();

    // Update water
    water.update();
    
    // The character and enemy still need their own update methods for animation
    // but we've modified their physics to use the force accumulator
    character.update();
    enemy.update();

    // Check for bullet collisions with enemy
    ArrayList<Bullet> bullets = character.getBullets();
    for (int i = bullets.size() - 1; i >= 0; i--) {
      Bullet bullet = bullets.get(i);
      if (bullet.isActive() && !enemy.isDead && PVector.dist(bullet.position, enemy.position) < enemy.radius + bullet.radius) {
        // Hit detected
        PVector force = PVector.sub(enemy.position, bullet.position).normalize().mult(5);
        force.y = -5; // Add some upward force
        enemy.applyForce(force);
        enemy.takeDamage(10); // Less damage than melee attack
        bullet.deactivate();
        bullets.remove(i);
      }
    }
    
    // Check for collision and resolve (player attacks enemy)
    if (character.isAttacking() && character.isInAttackRange(enemy) && character.isAttackCollisionFrame() && !enemy.isDead) {
      if (!attackLanded) { // Only apply damage if this attack hasn't already landed
        PVector force = PVector.sub(enemy.position, character.position).normalize().mult(10); // Adjust force as necessary
        force.y = -10; // Add upward force
        enemy.applyForce(force);
        enemy.takeDamage(20); // Fixed damage value
        attackLanded = true; // Mark that this attack has landed
      }
    }
    
    // Reset attackLanded when character is not attacking or not in collision frames
    if (!character.isAttacking() || !character.isAttackCollisionFrame()) {
      attackLanded = false;
    }

    // enemy attacks player (similar logic)
    boolean enemyAttackLanded = false; // Track enemy attacks similarly
    if (enemy.isAttacking() && enemy.isInAttackRange(character) && enemy.isInAttackCollisionFrame() && !character.isDead) {
      if (!enemyAttackLanded) {
        PVector force = PVector.sub(character.position, enemy.position).normalize().mult(10);
        force.y = -10; 
        character.applyForce(force);
        character.takeDamage(10);
        enemyAttackLanded = true;
      }
    }
    
    if (!enemy.isAttacking() || !enemy.isInAttackCollisionFrame()) {
      enemyAttackLanded = false;
    }
    
    // Check if player is dead and set game over state
    if (character.isDead) {
      gameOver = true;
    }
  }

  // check for spring collisions
  checkSprings();

  // Draw game objects
  drawGameObjects();
  
  // Display HUD
  displayHUD();
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
  // Draw water
  water.draw();

  // Draw springs
  for (Spring spring : springs) {
    spring.draw();
  }
  
  // Draw characters
  character.draw();
  enemy.draw();
}

void displayHUD() {
  // Health display
  fill(255);
  textSize(20);
  text("Health: " + character.getHealth(), 50, 50);
  text("Health: " + enemy.getHealth(), width - 150, 50);
  
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
  
  // Clear the entire physics engine instead of removing objects individually
  physicsEngine = new PhysicsEngine();
  springs.clear();
  
  // Recreate game objects
  character = new Character(new PVector(width / 2, height - 20));
  enemy = new Enemy(new PVector(width / 2 + 100, height - 20), character);

  // Re-create springs
  springs.add(new Spring(new PVector(width / 4, height - 20)));
  springs.add(new Spring(new PVector(width * 3 / 4, height - 20)));
  
  // Add objects to physics engine
  physicsEngine.addObject(character);
  physicsEngine.addObject(enemy);
  
  for (Spring spring : springs) {
    physicsEngine.addObject(spring);
  }
  
  // Add force generators (using a single generator for each type rather than duplicates)
  GravityForce gravity = new GravityForce(1.5f);
  DragForce drag = new DragForce(0.01f);
  
  physicsEngine.addForceGenerator(character, gravity);
  physicsEngine.addForceGenerator(enemy, gravity);
  physicsEngine.addForceGenerator(character, drag);
  physicsEngine.addForceGenerator(enemy, drag);
}