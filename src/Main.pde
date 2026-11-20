Environment env = new Environment();
Camera cam = new Camera();

float last;

void setup() {
  size(1280, 800);
  
  Body body = new Body(1.0, 0.25, true);
  body.setPosition(new PVector(0, 2.5));
  env.addBody(body);

  Body dragged = new Body(1.0, 0.25, false);
  dragged.setPosition(new PVector(-5, 2.5));
  env.addBody(dragged);

  Spring spring = new Spring(5.0, 5.0, body, dragged);
  env.addSpring(spring);
  
  last = millis();
}

void draw() {
  cam.enter();
  background(255, 255, 255);

  float now = millis();
  float dt = (now - last) / 1000.0;  // vergangene Zeit in s
  
  for (Spring spring : env.getSprings()) {
    PVector force = spring.force(); // von a -> b;
    spring.b.applyForce(force);
    spring.a.applyForce(PVector.mult(force, -1));
  }

  for (Body body : env.getBodies()) {    
    if (body.fixed) {
      draw_body(body);
      continue;
    }

    // Kräfte
    body.forces.add(new PVector(0.0, -env.gravity * body.mass)); // Gewichtskraft

    // Resultierende Kraft berechnen 
    PVector res = new PVector(0.0, 0.0);
    for (PVector f : body.forces) {
      res = res.add(f);
    }
    
    body.forces.clear();

    // Beschleunigung
    PVector a = res.div(body.mass);
    
    // Geschwindigkeits aenderung
    PVector dv = a.mult(dt);

    //Geschwindigkeits aenderung auf Geschwindigkeit addieren
    body.velocity = body.velocity.add(dv);
    
    // Zurueckgelegte Strecke
    PVector dp = PVector.mult(body.velocity, dt);
    
    // Neue Position
    body.position = body.position.add(dp);
  }

  for (Spring s : env.getSprings()) {
    s.draw(cam);
  }

  for (Body b : env.getBodies()) {
    draw_body(b);
  }

  last = now;
  cam.leave();
}

void draw_body(Body body) {
  color(255, 0, 0);
  cam.strokeWeight(1);
  circle(body.position.x, body.position.y, body.radius * 2);
}
