Background bg;
Character character;
Platform platform;
Enemy enemy;

void setup() {
  size(1024, 768);
  noSmooth();

  imageMode(CENTER);
  textMode(CENTER);

  bg = new Background("CharacterPack/Enviro/BG/trees_bg.png");
  character = new Character(new PVector(width / 2, height - 20)); // Spawn at the bottom middle
  platform = new Platform("CharacterPack/GPE/platforms/platform_through.png");
  enemy = new Enemy(new PVector(width / 2 + 100, height - 20), character); // Spawn enemy to the right of the player
}

void keyPressed() {
  character.handleKeyPressed(key);
}

void keyReleased() {
  character.handleKeyReleased(key);
}

void draw() {
  background(0);

  bg.display();
  platform.display();
  character.update();
  character.draw();
  enemy.update();
  enemy.draw();

  // display health of the player in the left top corner
  fill(255);
  textSize(20);
  text("Health: " + character.getHealth(), 50, 50);

  // display health of the enemy in the right top corner
  fill(255);
  textSize(20);
  text("Health: " + enemy.getHealth(), width - 150, 50);


  // Check for collision and resolve (player attacks enemy)
  if (character.isAttacking() && character.isInAttackRange(enemy) && character.isAttackCollisionFrame() && !enemy.isDead) {
    PVector force = PVector.sub(enemy.position, character.position).normalize().mult(10); // Adjust force as necessary
    force.y = -10; // Add upward force
    enemy.applyForce(force);
    enemy.takeHit(); // Make the enemy take a hit
  }

  // enemy attacks player
  if (enemy.isAttacking() && enemy.isInAttackRange(character) && enemy.isInAttackCollisionFrame() && !character.isDead) {
    PVector force = PVector.sub(character.position, enemy.position).normalize().mult(10); // Adjust force as necessary
    force.y = -10; // Add upward force
    character.applyForce(force);
    character.takeDamage(10); // Make the player take damage
  }
}
