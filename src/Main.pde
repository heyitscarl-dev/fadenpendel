/* Durch die LaTeX labels (in Spring.pde) verändert sich die
   Framerate erheblich. Dadurch wird die Physik Simulation
   instabil und die Feder (auch bei sehr hoher Federkonstante)
   fängt an sichtbar zu Schwingen.

   Um das zu verhindern führt man einen festen "timestep" ein, 
   sodass die Simulation unabhängig von der Framerate ist.
 */
final float STEP = 1.0 / 240.0;
float accumulator = 0.0;

Environment env = new Environment();
Camera cam = new Camera();

float last;

void setup() {
  size(1280, 800);
  
  Body body = new Body(1.0, 0.25, true);
  body.setPosition(new PVector(0, 2.5));
  env.addBody(body);

  Body dragged = new Body(1.0, 0.25, false);
  dragged.setPosition(new PVector(7, -2.5));
  env.addBody(dragged);

  Spring spring = new Spring(5.0, body, dragged);
  env.addSpring(spring);
  
  last = millis();
}


void draw() {
  cam.enter();
  background(255, 255, 255);

  float now = millis();
  float dt = (now - last) / 1000.0;  // vergangene Zeit in s
  last = now;
  dt = min(dt, 0.1);  // verhindert, dass riesige Lücken "nachgeholt" werden
  
  accumulator += dt;
  while (accumulator >= STEP) {
    tick(STEP);
    accumulator -= STEP;
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

void tick(float dt) {
  for (Spring spring : env.getSprings()) {
    PVector force = spring.force(); // von a -> b;
    spring.b.applyForce(force);
    spring.a.applyForce(PVector.mult(force, -1));
  }

  for (Body body : env.getBodies()) {    
    if (body.fixed) {
      draw_body(body);
      body.forces.clear();
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
}

void draw_body(Body body) {
  color(255, 0, 0);
  cam.strokeWeight(1);
  circle(body.position.x, body.position.y, body.radius * 2);
}
