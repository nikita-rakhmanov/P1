class Pond {
  private Water water;
  private ArrayList<PlatformEdge> edges;
  
  Pond(float x, float y, float width, float height) {
    // Create water feature
    water = new Water(x, y, width, height);
    
    // Create platform edges around the water
    edges = new ArrayList<PlatformEdge>();
    
    // Create the four edges (top, right, bottom, left)
    edges.add(new PlatformEdge(x, y, width, 20, "top"));          // Top edge
    edges.add(new PlatformEdge(x + width, y, 20, height, "right"));   // Right edge
    edges.add(new PlatformEdge(x, y + height, width, 20, "bottom"));  // Bottom edge
    edges.add(new PlatformEdge(x, y, 20, height, "left"));         // Left edge
  }
  
  void update() {
    // Update water
    water.update();
    
    // Update platform edges if needed
    for (PlatformEdge edge : edges) {
      edge.update();
    }
  }
  
  void draw() {
    // Draw water first (so platforms appear on top)
    water.draw();
    
    // Draw platform edges
    for (PlatformEdge edge : edges) {
      edge.draw();
    }
  }
  
  // Get all physics objects for adding to physics engine
  ArrayList<PhysicsObject> getPhysicsObjects() {
    ArrayList<PhysicsObject> objects = new ArrayList<PhysicsObject>();
    for (PlatformEdge edge : edges) {
      objects.add(edge);
    }
    return objects;
  }
}

// Platform edge class that extends PhysicsObject to create solid boundaries
class PlatformEdge extends PhysicsObject {
  private PImage img;
  private float edgeWidth, edgeHeight;
  private String edgeType;
  
  PlatformEdge(float x, float y, float w, float h, String type) {
    super(new PVector(x + w/2, y + h/2), 0); // Position at center of edge, infinite mass (0)
    this.edgeWidth = w;
    this.edgeHeight = h;
    this.edgeType = type;
    this.radius = max(w, h) / 2; // Set appropriate collision radius
    this.setStatic(true); // Platforms don't move
    
    // Load the same platform image used for the ground
    img = loadImage("CharacterPack/GPE/platforms/platform_through.png");
  }
  
  void update() {
    // Static objects don't need updates, but we could add animations here
  }
  
  void draw() {
    // Draw the platform with appropriate sizing and orientation
    pushMatrix();
    translate(position.x, position.y);
    
    // Different drawing logic based on edge type
    if (edgeType.equals("top") || edgeType.equals("bottom")) {
      // Horizontal platforms - repeat image along width
      for (float x = -edgeWidth/2; x < edgeWidth/2; x += img.width) {
        image(img, x, -edgeHeight/2);
      }
    } else {
      // Vertical platforms - rotate image and repeat along height
      pushMatrix();
      rotate(HALF_PI); // Rotate 90 degrees
      for (float y = -edgeHeight/2; y < edgeHeight/2; y += img.width) {
        image(img, y, -edgeWidth/2);
      }
      popMatrix();
    }
    
    popMatrix();
  }
}