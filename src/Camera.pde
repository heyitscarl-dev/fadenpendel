class Camera {
  float x, y;
  float zoom;
  
  Camera() {
    this.x = 0;
    this.y = 0;
    this.zoom = 1;
  }
  
  void enter() {
    pushMatrix();
    translate(this.x, this.y);
  }
  
  void leave() {
    popMatrix();
  }
}
