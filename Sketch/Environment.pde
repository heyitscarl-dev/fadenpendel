class Environment {
  float gravity;       // e.g. 9,81 m/s^2
  ArrayList<Body> bodies;
  ArrayList<Spring> springs;
  
  Environment(float gravity) {
    this.gravity = gravity;
    this.bodies = new ArrayList();
    this.springs = new ArrayList();
  }
  
  Environment() {  // overload standard constructur with defaults.
    this(9.81);
  }
  
  int addBody(Body body) {
    this.bodies.add(body);
    return this.bodies.size() - 1; 
  }

  int addSpring(Spring spring) {
    this.springs.add(spring);
    return this.springs.size() - 1;
  }
  
  Body getBody(int index) {
    return this.bodies.get(index);
  }
  
  ArrayList<Body> getBodies() {
    return this.bodies;
  }

  ArrayList<Spring> getSprings() {
    return this.springs;
  }

  // Tiefe Kopie des gesamten Environments. Die Federn der Kopie hängen an
  // den *kopierten* Körpern; die Zuordnung läuft über den Index in `bodies`.
  Environment copy() {
    Environment copy = new Environment(gravity);

    for (Body body : bodies) {
      copy.addBody(body.copy());
    }

    for (Spring spring : springs) {
      Body a = copy.getBody(bodies.indexOf(spring.a));
      Body b = copy.getBody(bodies.indexOf(spring.b));
      copy.addSpring(spring.copy(a, b));
    }

    return copy;
  }
}
