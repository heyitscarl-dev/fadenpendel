class Body {
  String identifier;
  float mass;
  float radius;
  PVector position;
  PVector velocity;
  ArrayList<PVector> forces;
  public boolean fixed;

  Body(float mass, float radius, boolean fixed) {
    this.mass = mass; //Masse Definieren
    this.radius = radius; //Groesse Definieren
    
    this.forces = new ArrayList();
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
  
  void applyForce(PVector force) {
    this.forces.add(force);
  }

  PVector position() {
    return position;
  }
}
