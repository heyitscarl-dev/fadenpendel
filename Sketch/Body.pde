class VelocityArrow implements UIArrow {
  final int stroke = color(151, 66, 135);
  PVector origin;
  PVector vector;

  PVector origin() { return origin; }
  PVector vector() { return vector; }
  int strokeColor() { return stroke; }
  TeXIcon label(Camera camera) { return latexIcon("\\vec{v}=" + round(vector().mag() * 10) / 10.0 + "\\frac{\\mathrm m}{\\mathrm s}", LABEL_SIZE); }

  VelocityArrow(PVector origin, PVector vector) {
    this.origin = origin;
    this.vector = vector;
  }
}

class Body implements UILabel, Selectable {
  String identifier;
  float mass;
  float radius;
  PVector position;
  PVector velocity;
  ArrayList<Force> forces;
  ArrayList<Force> lastForces;
  public boolean fixed;

  TeXIcon label(Camera camera) {
    return latexIcon(identifier /* + "=" + round(mass * 10)/10.0 + "\\,\\mathrm kg" */, LABEL_SIZE * 0.825 / 50 * camera.zoom);
  }

  PVector anchor(Camera camera) {
      TeXIcon label = label(camera);
      float w = label.getIconWidth()  / camera.zoom;
      float h = label.getIconHeight() / camera.zoom;
      return new PVector(position.x - w / 2, position.y - h / 2);
  }

  Body(String identifier, float mass, float radius, boolean fixed) {
    this.identifier = identifier;

    this.mass = mass; //Masse Definieren
    this.radius = radius; //Groesse Definieren
    
    this.forces = new ArrayList();
    this.lastForces = new ArrayList();
    this.velocity = new PVector(0, 0);
    this.position = new PVector(0, 0);

    this.fixed = fixed;
  }
  
  // Tiefe Kopie: Position und Geschwindigkeit werden als neue PVectors
  // angelegt, damit Original und Kopie sich nicht gegenseitig verändern.
  // Kräfte starten leer, sie werden in jedem Tick neu berechnet.
  Body copy() {
    Body copy = new Body(identifier, mass, radius, fixed);
    copy.position = position.copy();
    copy.velocity = velocity.copy();
    return copy;
  }

  void drawBounding(Camera camera, float gap) {
    fill(color(THEME_SELECTION, 100));
    stroke(color(THEME_SELECTION));
    camera.strokeWeight(1.5);
    rect(position.x - (radius + gap), position.y - (radius + gap), 2 * (radius + gap), 2 * (radius + gap));
  }

  void setPosition(PVector updated) {
    this.position = updated;
  }

  void setVelocity(PVector updated) {
    this.velocity = updated;
  }
  
  void move(PVector delta) {
    this.position = this.position.add(delta);
  }
  
  void applyForce(Force force) {
    this.forces.add(force);
  }

  PVector position() {
    return position;
  }

  void clearForces() {
    lastForces = new ArrayList<Force>(forces);
    forces.clear();
  }

  void draw(Camera camera) {
    if (fixed) drawFixed(camera);
    else circle(position.x, position.y, radius * 2);
  }
  
  void drawFixed(Camera camera) {
    float width = 2 * radius;
    float h = 0.1;                 // Höhe der Schraffur und ungefährer Abstand
    int n = max(1, round(width / h));
    float gap = (width - h) / max(1, n - 1);

    camera.strokeWeight(1.5);
    line(position.x - radius, position.y, position.x + radius, position.y);
    
    camera.strokeWeight(0.75);
    for (int i = 0; i < n; i++) {
      float x = position.x - radius + i * gap;
      line(x, position.y, x + h, position.y + h);
    }
  }

  VelocityArrow toVelocityArrow() {
    return new VelocityArrow(position, velocity);
  }
}
