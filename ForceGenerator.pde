// Interface for force generators
interface ForceGenerator {
  void updateForce(PhysicsObject object);
}

// Gravity force generator
class GravityForce implements ForceGenerator {
  private PVector gravity;
  
  GravityForce(float gravityValue) {
    this.gravity = new PVector(0, gravityValue);
  }
  
  GravityForce(PVector gravity) {
    this.gravity = gravity.copy();
  }
  
  void updateForce(PhysicsObject object) {
    // F = m * g
    PVector force = PVector.mult(gravity, object.mass);
    object.applyForce(force);
  }
}

// Drag force (air resistance) generator
class DragForce implements ForceGenerator {
  private float k; // Drag coefficient
  
  DragForce(float k) {
    this.k = k;
  }
  
  void updateForce(PhysicsObject object) {
    // Get velocity magnitude
    float speed = object.velocity.mag();
    if (speed == 0) return; // No velocity, no drag
    
    // Calculate drag magnitude: fd = -k * |v|²
    float dragMagnitude = k * speed * speed;
    
    // Create normalized drag force in opposite direction of velocity
    PVector dragForce = object.velocity.copy();
    dragForce.normalize();
    dragForce.mult(-dragMagnitude);
    
    // Apply the force
    object.applyForce(dragForce);
  }
}

// Constant force (e.g., thrust) generator
class ConstantForce implements ForceGenerator {
  private PVector force;
  
  ConstantForce(PVector force) {
    this.force = force.copy();
  }
  
  void updateForce(PhysicsObject object) {
    object.applyForce(force);
  }
  
  void setForce(PVector newForce) {
    this.force = newForce.copy();
  }
}

// Spring force generator (simple version)
class SpringForce implements ForceGenerator {
  private PVector anchor; // Fixed anchor point
  private float springConstant; // Spring stiffness
  private float restLength; // Natural spring length
  
  SpringForce(PVector anchor, float springConstant, float restLength) {
    this.anchor = anchor.copy();
    this.springConstant = springConstant;
    this.restLength = restLength;
  }
  
  void updateForce(PhysicsObject object) {
    // Vector from object to anchor
    PVector force = PVector.sub(object.position, anchor);
    float magnitude = force.mag();
    
    // No force if we're at the anchor
    if (magnitude == 0) return;
    
    // Calculate spring force: F = -k * (|d| - restLength) * (d / |d|)
    float displacement = magnitude - restLength;
    force.normalize();
    force.mult(-springConstant * displacement);
    
    // Apply force
    object.applyForce(force);
  }
}

// Force Registry to manage all force generators
class ForceRegistry {
  private ArrayList<ForceRegistration> registrations;
  
  ForceRegistry() {
    registrations = new ArrayList<ForceRegistration>();
  }
  
  // Add a force generator to an object
  void add(PhysicsObject object, ForceGenerator fg) {
    ForceRegistration registration = new ForceRegistration(object, fg);
    registrations.add(registration);
  }
  
  // Remove a registration
  void remove(PhysicsObject object, ForceGenerator fg) {
    for (int i = registrations.size() - 1; i >= 0; i--) {
      ForceRegistration fr = registrations.get(i);
      if (fr.object == object && fr.fg == fg) {
        registrations.remove(i);
      }
    }
  }
  
  // Remove all registrations for an object
  void removeAll(PhysicsObject object) {
    for (int i = registrations.size() - 1; i >= 0; i--) {
      if (registrations.get(i).object == object) {
        registrations.remove(i);
      }
    }
  }
  
  // Update all forces
  void updateForces() {
    for (ForceRegistration fr : registrations) {
      fr.fg.updateForce(fr.object);
    }
  }
  
  // Helper class for registrations
  private class ForceRegistration {
    PhysicsObject object;
    ForceGenerator fg;
    
    ForceRegistration(PhysicsObject object, ForceGenerator fg) {
      this.object = object;
      this.fg = fg;
    }
  }
}