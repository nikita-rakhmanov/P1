class Background {
  PImage img;

  Background(String imgPath) {
    img = loadImage(imgPath);
  }

  void display() {
    boolean flip = false;
    for (int x = 0; x < width; x += img.width) {
      pushMatrix();
      if (flip) {
        scale(-1, 1);
        image(img, -x - img.width / 2, height - img.height / 2);
      } else {
        image(img, x + img.width / 2, height - img.height / 2);
      }
      popMatrix();
      flip = !flip;
    }
  }
}