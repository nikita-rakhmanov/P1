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

  // Check for collision and resolve
  if (character.isAttacking() && character.isInAttackRange(enemy) && character.isAttackCollisionFrame()) {
    PVector force = PVector.sub(enemy.position, character.position).normalize().mult(10); // Adjust force as necessary
    force.y = -10; // Add upward force
    enemy.applyForce(force);
    enemy.takeHit(); // Make the enemy take a hit
  }
}
