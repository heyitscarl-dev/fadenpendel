final float STEP = 1.0 / 240.0;
final float FORCE_SCALE = 0.075;
float accumulator = 0.0;

Environment env = new Environment();
Camera cam = new Camera();
Display display = new Display();

UIOverlay defaultOverlay = new UIOverlay();
UIContainer controls = new UIContainer(new PVector(50, 50));
Toggle btnDrawVelocities = new Toggle("\\text{Velocities}");
Toggle btnDrawForces = new Toggle("\\text{Forces}");

UIOverlay velocityOverlay = new UIOverlay();
UIOverlay forceOverlay = new UIOverlay();

float last;

boolean running = true;
boolean doStep = false;
static boolean luft = true;

void setup() {
  // Initialisiert die UI
  controls.elements.add(btnDrawVelocities);
  controls.elements.add(btnDrawForces);
  defaultOverlay.elements.add(controls);

  size(1280, 800);
  pixelDensity(2);

  // Der "Anker". An ihm ist der "Faden" und somit das
  // Pendel befestigt. `fixed == true`, daher bewegt sich
  // dieser Körper nicht.
  Body body = new Body(1.0, 0.25, true);
  body.setPosition(new PVector(0, 2.5));
  env.addBody(body);

  // Der Schwingkörper. Er ist auch an dem "Faden" befestigt
  // und teil des Pendels. `fixed == false`
  Body dragged = new Body(5.0, 0.25, false);
  dragged.setPosition(new PVector(-2.5, 2.5));
  env.addBody(dragged);

  /* Einen Fanden zu simulieren hat sich als relativ schwierig
   * herausgestellt. Daher wird ein Faden hier als Feder, mit enorm
   * hoher Federkonstante simuliert. Nierdrige Federkonstanten ergeben
   * auch interessante ergebnisse.
  */
  
  float stiffness = 20.0;
  Spring spring = new Spring(stiffness, body, dragged);
  env.addSpring(spring);
  
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
  accumulator += dt;
  while (accumulator >= STEP) {
    tick(STEP); // (siehe Sketch/Simulation.pde)
    accumulator -= STEP;
  }
  
  display.draw(cam);
  cam.enter();
  if (btnDrawForces.state) {
    forceOverlay.drawToScreen(cam);
  }
  if (btnDrawVelocities.state) {
    velocityOverlay.drawToScreen(cam);
  }
  cam.leave();

  defaultOverlay.drawToScreen(cam);
}

void mousePressed() {
  defaultOverlay.handleClick(new PVector(mouseX, mouseY));
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

  if (!running && keyCode == ENTER) {
    doStep = true;
  }
}