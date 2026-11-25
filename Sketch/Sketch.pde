final float STEP = 1.0 / (1000.0);
final float FORCE_SCALE = 0.075 / 2.0;
float accumulator = 0.0;
float speed = 1.0;

Environment initial = new Environment();
Environment env = new Environment();
Camera cam = new Camera();
Display display = new Display();

UIOverlay defaultOverlay = new UIOverlay();
UIContainer controls = new UIContainer(new PVector(50, 50));
Toggle btnDrawVelocities = new Toggle(false, "\\text{Velocities}");
Toggle btnDrawForces = new Toggle(false, "\\text{Forces}");
Toggle btnDrawQuantities = new Toggle(true, "\\text{Quantities}");

UIOverlay velocityOverlay = new UIOverlay();
UIOverlay forceOverlay = new UIOverlay();
UIOverlay quantityOverlay = new UIOverlay();

float last;

boolean running = false;
boolean doStep = false;
static boolean luft = false;

void setup() {
  // Initialisiert die UI
  controls.elements.add(btnDrawVelocities);
  controls.elements.add(btnDrawForces);
  controls.elements.add(btnDrawQuantities);
  defaultOverlay.elements.add(controls);

  size(1280, 800);
  pixelDensity(2);

  // Der "Anker". An ihm ist der "Faden" und somit das
  // Pendel befestigt. `fixed == true`, daher bewegt sich
  // dieser Körper nicht.
  Body anchor1 = new Body("m_{f1}", 1.0, 0.25, true);
  anchor1.setPosition(new PVector(-0.25, 2.5));
  env.addBody(anchor1);

  Body anchor2 = new Body("m_{f2}", 1.0, 0.25, true);
  anchor2.setPosition(new PVector(0.25, 2.5));
  env.addBody(anchor2);

  // Der Schwingkörper. Er ist auch an dem "Faden" befestigt
  // und teil des Pendels. `fixed == false`
  Body body1 = new Body("m_1", 5.0, 0.25, false);
  body1.setPosition(new PVector(-2.5-0.25, 2.5));
  env.addBody(body1);

  Body body2 = new Body("m_2", 5.0, 0.25, false);
  body2.setPosition(new PVector(2.5+0.25, 2.5));
  env.addBody(body2);

  Body body3 = new Body("m_3", 5.0, 0.25, false);
  body3.setPosition(new PVector(-5-0.25, 2.5));
  // env.addBody(body3);

  Body body4 = new Body("m_4", 5.0, 0.25, false);
  body4.setPosition(new PVector(5+0.25, 2.5));
  // env.addBody(body4);

  /* Einen Fanden zu simulieren hat sich als relativ schwierig
   * herausgestellt. Daher wird ein Faden hier als Feder, mit enorm
   * hoher Federkonstante simuliert. Nierdrige Federkonstanten ergeben
   * auch interessante ergebnisse.
  */
  
  float stiffness = THREAD_STIFFNESS;
  Spring spring1 = new Spring(stiffness, anchor1, body1);
  env.addSpring(spring1);
  Spring spring2 = new Spring(stiffness, anchor2, body2);
  env.addSpring(spring2);
  Spring spring3 = new Spring(stiffness, body1, body3);
  // env.addSpring(spring3);
  Spring spring4 = new Spring(stiffness, body2, body4);
  // env.addSpring(spring4);
  
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
  }

  if (!running && keyCode == ENTER) {
    doStep = true;
  }
}