class BuoyancyForce implements ForceGenerator {
  private Water water;
  private float liquidDensity;
  private float maxBuoyantForce = 2.5f; // Cap the maximum force to prevent flying away
  
  BuoyancyForce(Water water, float liquidDensity) {
    this.water = water;
    this.liquidDensity = liquidDensity;
  }
  
  void updateForce(PhysicsObject obj) {
    // Skip static objects
    if (obj.isStatic) return;
    
    // Calculate submersion depth
    float depth = water.getSubmersionDepth(obj);
    
    // If object isn't submerged, no buoyancy force
    if (depth <= 0) return;
    
    // Calculate the percentage of the object that is submerged
    float submersionRatio = min(1.0f, depth / (obj.radius * 2));
    
    // Calculate buoyancy force - much gentler than before
    float buoyantForce = liquidDensity * submersionRatio * 0.8f;
    
    // Cap the maximum force to prevent objects from flying away
    buoyantForce = min(buoyantForce, maxBuoyantForce);
    
    // Apply an upward force
    obj.applyForce(new PVector(0, -buoyantForce));
    
    // Apply water resistance (higher drag in water)
    if (obj.velocity.mag() > 0) {
      float waterDragCoeff = 0.2f * submersionRatio; // Increased drag
      PVector dragDirection = obj.velocity.copy().normalize();
      float dragMagnitude = waterDragCoeff * obj.velocity.magSq();
      PVector dragForce = PVector.mult(dragDirection, -dragMagnitude);
      
      obj.applyForce(dragForce);
    }
    
    // Visual effect: create ripples when objects move in water
    if (obj.velocity.mag() > 1.0f && frameCount % 5 == 0) { // Reduced frequency
      float rippleSize = map(obj.velocity.mag(), 0, 5, 3, 12); // Smaller ripples
      water.addRipple(obj.position.x, water.y, rippleSize);
    }
    
    // Visual indicator of buoyancy (small bubbles)
    if (random(1) < 0.05 && frameCount % 3 == 0) { // Reduced frequency
      float bubbleX = obj.position.x + random(-obj.radius/2, obj.radius/2);
      float bubbleY = obj.position.y + random(-obj.radius/2, obj.radius/2);
      
      pushStyle();
      fill(255, 255, 255, 100);
      noStroke();
      ellipse(bubbleX, bubbleY, random(1, 3), random(1, 3));
      popStyle();
    }
  }
}