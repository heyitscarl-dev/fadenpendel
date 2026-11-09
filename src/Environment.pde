class Environment {
  float gravity;       // e.g. 9,81 m/s^2
  ArrayList<Body> bodies;
  
  Environment(float gravity) {
    this.gravity = gravity;
    this.bodies = new ArrayList();
  }
  
  Environment() {  // overload standard constructur with defaults.
    this(9.81);
  }
  
  int addBody(Body body) {
    this.bodies.add(body);
    return this.bodies.size() - 1; 
  }
  
  Body getBody(int index) {
    return this.bodies.get(index);
  }
  
  ArrayList<Body> getBodies() {
    return this.bodies;
  }
}
