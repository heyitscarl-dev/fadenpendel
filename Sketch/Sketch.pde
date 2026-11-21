final float STEP = 1.0 / 240.0;
final float FORCE_SCALE = 0.075;
float accumulator = 0.0;

Environment env = new Environment();
Camera cam = new Camera();
Display display = new Display();

float last;

boolean running = true;
boolean doStep = false;

void setup() {
  size(1280, 800);
  pixelDensity(2);

  Body body = new Body(1.0, 0.25, true);
  body.setPosition(new PVector(0, 2.5));
  env.addBody(body);

  Body dragged = new Body(1.0, 0.25, false);
  dragged.setPosition(new PVector(-2.5, 2.5));
  env.addBody(dragged);

  Spring spring = new Spring(500.0, body, dragged);
  env.addSpring(spring);
  
  last = millis();
}

void draw() {
  float now = millis();
  float dt = (now - last) / 1000.0;  // vergangene Zeit in s
  last = now;
  dt = min(dt, 0.1);  // verhindert, dass riesige Lücken "nachgeholt" werden
        
  accumulator += dt;
  while (accumulator >= STEP) {
    tick(STEP);
    accumulator -= STEP;
  }

  display.draw(cam);
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