Environment env = new Environment();
Camera cam = new Camera();

float last;

void setup() {
  size(1280, 800);
  
  Body body = new Body(1.0, 2);
  body.setPosition(new PVector(0, 0));
  env.addBody(body);
  
  last = millis();
}

void draw() {
  cam.enter();
  background(255, 255, 255);

  for (Body body : env.getBodies()) {
    float now = millis();
    float dt = (now - last) / 1000.0;  // vergangene Zeit in s
    
    // Kraefte
    body.forces.add(new PVector(0.0, -env.gravity * body.mass)); // Gewichtskraft
    
    // Resultierende Kraft berechnen 
    PVector res = new PVector(0.0, 0.0);
    for (PVector f : body.forces) {
      res = res.add(f);
    }
    
    // Beschleunigung
    PVector a = res.div(body.mass);
    
    // Geschwindigkeits aenderung
    PVector dv = a.mult(dt);

    //Geschwindigkeits aenderung auf Geschwindigkeit addieren
    body.velocity = body.velocity.add(dv);
    
    // Zurueckgelegte Strecke
    PVector dp = body.velocity.mult(dt);

    // Neue Position
    body.position = body.position.add(dp);
    
    draw_body(body);
    
    last = now;
  }
  
  cam.leave();
}

void draw_body(Body body) {
  color(255, 0, 0);
  cam.strokeWeight(1);
  circle(body.position.x, body.position.y, body.radius);
  
}
