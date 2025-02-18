class PhysicsObject {
    PVector position;
    PVector velocity;
    PVector acceleration;
    float mass;
    float radius; // For collision detection

    PhysicsObject(PVector position, float mass) {
        this.position = position.copy();
        this.velocity = new PVector(0, 0);
        this.acceleration = new PVector(0, 0);
        this.mass = mass;
        this.radius = 20; // Default radius, adjust as necessary
    }

    void applyForce(PVector force) {
        PVector f = force.copy();
        f.div(mass);
        acceleration.add(f);
    }

    void update() {
        velocity.add(acceleration);
        position.add(velocity);
        acceleration.mult(0); // Reset acceleration after each update

        // Boundary checks to keep the object within the screen
        if (position.x < radius) {
            position.x = radius;
            velocity.x *= -0.5; // Bounce back with some energy loss
        } else if (position.x > width - radius) {
            position.x = width - radius;
            velocity.x *= -0.5; // Bounce back with some energy loss
        }

        if (position.y < radius) {
            position.y = radius;
            velocity.y *= -0.5; // Bounce back with some energy loss
        } else if (position.y > height - radius) {
            position.y = height - radius;
            velocity.y *= -0.5; // Bounce back with some energy loss
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
}