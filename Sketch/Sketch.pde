/* Durch die LaTeX labels (in Spring.pde) verändert sich die
   Framerate erheblich. Dadurch wird die Physik Simulation
   instabil und die Feder (auch bei sehr hoher Federkonstante)
   fängt an sichtbar zu Schwingen.

   Um das zu verhindern führt man einen festen "timestep" ein, 
   sodass die Simulation unabhängig von der Framerate ist.
 */
final float STEP = 1.0 / 240.0;
final float FORCE_SCALE = 0.075;
float accumulator = 0.0;

Environment env = new Environment();
Camera cam = new Camera();

float last;

boolean running = true;

void setup() {
  size(1280, 800);
  pixelDensity(2);

  Body body = new Body(1.0, 0.25, true);
  body.setPosition(new PVector(0, 2.5));
  env.addBody(body);

  Body dragged = new Body(1.0, 0.25, false);
  dragged.setPosition(new PVector(-2.5, 2.5));
  env.addBody(dragged);

  Spring spring = new Spring(5000.0, body, dragged);
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

  for (Body b : env.getBodies()) {
    for (Force f : b.lastForces) {
      f.scaled(FORCE_SCALE).draw(cam);
    }
  }

  last = now;
  cam.leave();

  fill(0, 0, 0);
  textSize(12.5);
  textAlign(LEFT, BASELINE);
  text("[Space] to pause", 30, height - 30);
}

void tick(float dt) {
  if (!running) return;

  for (Spring spring : env.getSprings()) {
    Force[] forces = spring.forces(new String[]{
      "|F_D|=%v\\,\\mathrm{N}",
      "|F_D|=%v\\,\\mathrm{N}"
    });

    spring.b.applyForce(forces[0]);
    spring.a.applyForce(forces[1]);
  }

  for (Body body : env.getBodies()) {    
    if (body.fixed) {
      body.clearForces();
      continue;
    }

    // Kräfte
    body.forces.add(new Force(
      body.position,
      new PVector(0.0, -env.gravity * body.mass),
      "|F_g|=" + env.gravity * body.mass + "\\,\\mathrm{N}"
    )); // Gewichtskraft

    // Resultierende Kraft berechnen 
    PVector res = new PVector(0.0, 0.0);
    for (Force f : body.forces) {
      res = res.add(f.getVector());
    }
    
    body.clearForces();

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
  fill(0.9 * 255);
  stroke(0, 0, 0);
  cam.strokeWeight(1);
  circle(body.position.x, body.position.y, body.radius * 2);
}

void mouseDragged() {
  cam.handleDrag();
}

void mouseWheel(MouseEvent e) {
  float c = e.getCount();
  cam.zoom *= pow(1.05, -c);
}

void keyPressed() {
  if (key == ' ') {
    running = !running;
  }
}