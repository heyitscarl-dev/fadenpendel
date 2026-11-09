Environment env = new Environment();
Camera cam = new Camera();

void setup() {
  size(1280, 800);
  
  Body body = new Body(1.0, 0.5);
  body.setPosition(new PVector(0, 0));
  env.addBody(body);
}

void draw() {
  cam.enter();
  background(255, 255, 255);

  for (Body body : env.getBodies()) {
    draw_body(body);
  }
  
  cam.leave();
}

void draw_body(Body body) {
  color(255, 0, 0);
  circle(body.position.x, body.position.y, body.radius);
}
