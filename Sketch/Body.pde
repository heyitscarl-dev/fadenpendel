final int COLOR_VELOCITY = color(151, 66, 135);

class Body {
  String identifier;
  float mass;
  float radius;
  PVector position;
  PVector velocity;
  ArrayList<Force> forces;
  ArrayList<Force> lastForces;
  public boolean fixed;

  Body(float mass, float radius, boolean fixed) {
    this.mass = mass; //Masse Definieren
    this.radius = radius; //Groesse Definieren
    
    this.forces = new ArrayList();
    this.lastForces = new ArrayList();
    this.velocity = new PVector(0, 0);
    this.position = new PVector(0, 0);

    this.fixed = fixed;
  }
  
  void setPosition(PVector updated) {
    this.position = updated;
  }

  void setVelocity(PVector updated) {
    this.velocity = updated;
  }
  
  void move(PVector delta) {
    this.position = this.position.add(delta);
  }
  
  void applyForce(Force force) {
    this.forces.add(force);
  }

  PVector position() {
    return position;
  }

  void clearForces() {
    lastForces = new ArrayList<Force>(forces);
    forces.clear();
  }

  void draw(Camera cam) {
    circle(position.x, position.y, radius * 2);
    
    if (velocityArrows.state() == false) return;
    if (velocity.mag() == 0) return;

    PVector midpoint = PVector.add(position, PVector.mult(velocity, 0.5));
    PVector perp = velocity.copy();
    perp.normalize();
    perp = new PVector(-perp.y, perp.x);

    midpoint = PVector.add(midpoint, PVector.mult(perp, 0.35));

    cam.drawArrow(position, velocity, COLOR_VELOCITY);
    cam.drawLabel("\\vec{v} = " + round(velocity.mag() * 10) / 10.0 + "\\,\\frac ms", midpoint);
  }
}
