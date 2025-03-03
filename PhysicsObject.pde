class PhysicsObject {
    PVector position;
    PVector velocity;
    PVector acceleration;
    PVector forceAccum;  // Force accumulator
    float mass;
    float radius; // For collision detection
    float friction = 0.7; // Friction coefficient to reduce sliding

    PhysicsObject(PVector position, float mass) {
        this.position = position.copy();
        this.velocity = new PVector(0, 0);
        this.acceleration = new PVector(0, 0);
        this.forceAccum = new PVector(0, 0);  // Initialize force accumulator
        this.mass = mass;
        this.radius = 20; // Default radius, adjust as necessary
    }

    void applyForce(PVector force) {
        // Add force to accumulator instead of directly affecting acceleration
        PVector f = force.copy();
        forceAccum.add(f);
    }
    
    // Clear accumulated forces
    void clearForces() {
        forceAccum.set(0, 0);
    }

    void update() {
        // Calculate acceleration from accumulated forces
        acceleration = PVector.div(forceAccum, mass);
        
        // Update velocity with acceleration
        velocity.add(acceleration);
        
        // Apply friction to reduce sliding
        velocity.mult(friction);
        
        // Update position with velocity
        position.add(velocity);
        
        // Clear forces for the next update
        clearForces();

        // Boundary checks to keep the object within the screen
        if (position.x < radius) {
            position.x = radius;
            velocity.x = 0; // Stop horizontal velocity when hitting the boundary
        } else if (position.x > width - radius) {
            position.x = width - radius;
            velocity.x = 0; // Stop horizontal velocity when hitting the boundary
        }

        if (position.y < radius) {
            position.y = radius;
            velocity.y = 0; // Stop vertical velocity when hitting the boundary
        } else if (position.y > height - radius) {
            position.y = height - radius;
            velocity.y = 0; // Stop vertical velocity when hitting the boundary
        }
    }

    void display() {
        // Override this method in subclasses to display the object
    }

    boolean isColliding(PhysicsObject other) {
        float distance = PVector.dist(this.position, other.position);
        return distance < this.radius + other.radius;
    }

    void resolveCollision(PhysicsObject other) {
        PVector collisionNormal = PVector.sub(other.position, this.position).normalize();
        PVector relativeVelocity = PVector.sub(other.velocity, this.velocity);
        float separatingVelocity = PVector.dot(relativeVelocity, collisionNormal);

        if (separatingVelocity > 0) return;

        float newSeparatingVelocity = -separatingVelocity;
        PVector separatingVelocityVec = PVector.mult(collisionNormal, newSeparatingVelocity);

        this.velocity.add(separatingVelocityVec);
        other.velocity.sub(separatingVelocityVec);
    }

    public float getRadius() {
        return radius;
    }
}