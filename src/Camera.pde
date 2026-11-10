class Camera {
  static final float SCALE = 50;
  
  float x, y;
  float zoom;

  Camera() {
    this.x = 0;
    this.y = 0;
    this.zoom = 50;
  }

  void enter() {
    pushMatrix();
    translate(width / 2, height / 2);  // den Ursprung auf die Bildmitte setzen
    scale(zoom, -zoom);
    translate(-x, -y);
  }
  
  void strokeWeight(float w) {
    g.strokeWeight(w / zoom);
  }

  void leave() {
    popMatrix();
  }
}
