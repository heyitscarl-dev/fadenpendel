final float STEP = 1.0 / (1000.0);
final float FORCE_SCALE = 0.075;
float accumulator = 0.0;
float speed = 1.0;

Environment initial = new Environment();
Environment env = new NewtonPendulum();
Camera cam = new Camera();
Display display = new Display();

UIOverlay defaultOverlay = new UIOverlay();
UIContainer controls = new UIContainer(new PVector(50, 50));
UIContainer values = new UIContainer(new PVector(50, 50));
Toggle btnDrawVelocities = new Toggle(false, "\\text{Velocities}");
Toggle btnDrawForces = new Toggle(false, "\\text{Forces}");
Toggle btnDrawQuantities = new Toggle(true, "\\text{Quantities}");
Toggle btnDrawContacts = new Toggle(true, "\\text{Contacts}");
Toggle btnAirResistance = new Toggle(true, "\\text{Drag}");

UIOverlay velocityOverlay = new UIOverlay();
UIOverlay forceOverlay = new UIOverlay();
UIOverlay quantityOverlay = new UIOverlay();
UIOverlay contactOverlay = new UIOverlay();

float simTime = 0.0;                  // vergangene Simulationszeit (s)
final float CONTACT_LIFETIME = 0.3;   // Sichtbarkeit eines Kontakts nach der letzten Berührung (s)

float last;

boolean running = false;
boolean doStep = false;

void setup() {
  // Initialisiert die UI
  controls.elements.add(btnDrawVelocities);
  controls.elements.add(btnDrawForces);
  controls.elements.add(btnDrawQuantities);
  controls.elements.add(btnDrawContacts);
  defaultOverlay.elements.add(controls);
  
  values.position.x += 50 + controls.dimensions(cam).x;
  values.elements.add(btnAirResistance);
  defaultOverlay.elements.add(values);

  size(1280, 800);
  pixelDensity(2);
  
  initial = env.copy();

  // Um dt (Δd; delta time), also die Zeitdifferenz der letzten Frames
  // zu berrechnen (wodurch die Simulation konstant und unabhängig von 
  // der Bildrate/FPS sein kann), muss der Zeitpunkt des letzten Frames 
  // gespeichert werden. `setup()` wird als "erster Frame" gewertet, damit
  // `last` nicht 0 ist, also `dt` nicht unrealistisch groß.
  last = millis();
}

void draw() {
  float now = millis();
  float dt = (now - last) / 1000.0;  // Δd/Zeitdifferenz der letzten Frames
  last = now;

  // Δd wird auf maximal 100 ms beschränkt, damit sehr großes "Stottern" der Bildrate
  // oder eine extrem niedrige Bildrate nicht zu einem unaufholbaren Vorsprung kommt.
  dt = min(dt, 0.1); 
  
  // 240 Steps pro Sekunde. Pro Frame werden alle Steps "aufgeholt", die während Δd hätten
  // passieren müssen.
  accumulator += speed * dt;
  while (accumulator >= STEP) {
    tick(STEP / speed); // (siehe Sketch/Simulation.pde)
    accumulator -= STEP / speed;
  }
  
  display.draw(cam);
  cam.enter();
  if (btnDrawForces.state) {
    forceOverlay.drawToScreen(cam);
  }
  if (btnDrawVelocities.state) {
    velocityOverlay.drawToScreen(cam);
  }
  if (btnDrawQuantities.state) {
    quantityOverlay.drawToScreen(cam);
  }
  if (btnDrawContacts.state) {
    contactOverlay.drawToScreen(cam);
  }
  cam.leave();

  defaultOverlay.drawToScreen(cam);
}

void mousePressed() {
  defaultOverlay.handleClick(cam, new PVector(mouseX, mouseY));
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

  if (key == 'r') {
    env = initial.copy();
    running = false;
    contactOverlay.elements.clear();
    simTime = 0;
  }

  // Szenario wechseln (siehe Sketch/Scenarios.pde)
  if (key >= '1' && key <= '9') {
    Environment scenario = createScenario(key - '0');
    if (scenario != null) {
      env = scenario;
      initial = env.copy();
      running = false;
      contactOverlay.elements.clear();
      simTime = 0;
    }
  }

  if (!running && keyCode == ENTER) {
    doStep = true;
  }
}