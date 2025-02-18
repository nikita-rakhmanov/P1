Background bg;
Character character;
Platform platform;

void setup() {
  size(1024, 768);
  noSmooth();

  imageMode(CENTER);
  textMode(CENTER);

  bg = new Background("CharacterPack/Enviro/BG/trees_bg.png");
  character = new Character(new PVector(width / 2, height - 20)); // Spawn at the bottom middle
  platform = new Platform("CharacterPack/GPE/platforms/platform_through.png");
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
}
