class VelocityArrow implements UIArrow {
  final int stroke = color(151, 66, 135);
  PVector origin;
  PVector vector;

  PVector origin() { return origin; }
  PVector vector() { return vector; }
  int strokeColor() { return stroke; }
  TeXIcon label() { return latexIcon("\\vec{v}=" + round(vector().mag() * 10) / 10.0 + "\\frac{\\mathrm m}{\\mathrm s}", LABEL_SIZE); }

  VelocityArrow(PVector origin, PVector vector) {
    this.origin = origin;
    this.vector = vector;
  }
}

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
  }

  VelocityArrow toVelocityArrow() {
    return new VelocityArrow(position, velocity);
  }
}
