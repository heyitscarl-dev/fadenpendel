import org.scilab.forge.jlatexmath.*;
import java.util.HashMap;

static HashMap<String, TeXIcon> cache = new HashMap<String, TeXIcon>();

static TeXIcon latexIcon(String tex, float size) {
  String key = size + "|" + tex;
  TeXIcon icon = cache.get(key);
  if (icon == null) {
    icon = new TeXFormula(tex).createTeXIcon(TeXConstants.STYLE_DISPLAY, size);
    icon.setForeground(java.awt.Color.BLACK);
    cache.put(key, icon);
  }
  return icon;
}

class Camera {
  static final float SCALE = 50;
  
  float x, y;
  float zoom;

  boolean active = false;

  void drawLabel(String text, PVector attachment) {
    latex(text, attachment.x, attachment.y);
  }

  void latex(String tex, float x, float y) {
    latex(tex, x, y, 16);
  }

  void latex(TeXIcon icon, float x, float y) {
    pushMatrix();
    translate(x, y);
    scale(1 / zoom, -1 / zoom);  // zurück auf Pixel und y-Spiegelung aufheben
    latexScreen(icon, 0, 0);
    popMatrix();
  }

  // Zeichnet eine Formel an einer Position in Welt-Koordinaten
  // (nur zwischen cam.enter() und cam.leave() aufrufen).
  void latex(String tex, float x, float y, float size) {
    pushMatrix();
    translate(x, y);
    scale(1 / zoom, -1 / zoom);  // zurück auf Pixel und y-Spiegelung aufheben
    latexScreen(tex, 0, 0, size);
    popMatrix();
  }

  // Zeichnet eine Formel an einer Position in Bildschirm-Pixeln
  // (außerhalb von cam.enter()/cam.leave(), z. B. für UI wie Buttons).
  // Die Formel wird links-unten an (x, y) ausgerichtet.
  void latexScreen(String tex, float x, float y, float size) {
    TeXIcon icon = latexIcon(tex, size);
    latexScreen(icon, x, y);
  }

  void latexScreen(TeXIcon icon, float x, float y) {
    int h = icon.getIconHeight();

    java.awt.Graphics2D g2 = ((processing.awt.PGraphicsJava2D) g).g2;
    pushMatrix();
    translate(x, y);
    icon.paintIcon(null, g2, 0, -h);
    popMatrix();
  }

  Camera() {
    this.x = 0;
    this.y = 0;
    this.zoom = 50;
  }

  PVector screenToWorld(PVector screen) {
    return new PVector((screen.x - width / 2) / zoom + x, -(screen.y - height / 2) / zoom + y);
  }

  PVector worldToScreen(PVector world) {
    return new PVector(((world.x - x) * zoom) + width / 2, (-(world.y - y) * zoom) + height / 2);
  }

  float screenToWorld(float length) {
    return length / zoom;
  }

  float log10 (float x) {
    return (log(x) / log(10));
  }

  // Abstand zwischen zwei Grid-Linien in Welt-Koordinaten (Zweierpotenz).
  float gridStep() {
    float target = 50 / zoom; // Grid Linien sollten ca. 50 px auseinander sein
    return pow(2, floor(log(target) / log(2)));
  }

  // Nächster Schnittpunkt des Grids zu einer Position in Welt-Koordinaten.
  PVector closestGridPoint(PVector position) {
    float step = gridStep();
    return new PVector(
      round(position.x / step) * step,
      round(position.y / step) * step
    );
  }

  void drawGrid() {
    boolean before = this.active;
    enter();

    float step = gridStep();

    int majorEvery = 10;

    // Minimal und maximal sichtbare welt koordinaten
    float minX = -(width / zoom) + this.x;
    float maxX = (width / zoom) + this.x;
    float minY = -(height / zoom) + this.y;
    float maxY = (height / zoom) + this.y;

    int firstX = floor(minX / step);
    int lastX = ceil(maxX / step);

    for (int i = firstX; i <= lastX; i++) {
      float x = i * step;
      if (i % majorEvery == 0) {
        this.strokeWeight(1.5);
        stroke(50, 50, 50, 160);
      } else {
        this.strokeWeight(0.5);
        stroke(50, 50, 50, 70);
      }
      line(x, minY, x, maxY);
    }

    int firstY = floor(minY / step);
    int lastY = ceil(maxY / step);

    for (int i = firstY; i <= lastY; i++) {
      float y = i * step;
      if (i % majorEvery == 0) {
        this.strokeWeight(1.5);
        stroke(50, 50, 50, 160);
      } else {
        this.strokeWeight(0.5);
        stroke(50, 50, 50, 70);
      }
      line(minX, y, maxX, y);
    }

    if (!before) leave();
  }

  void enter() {
    if (active) return;
    pushMatrix();
    translate(width / 2, height / 2);  // den Ursprung auf die Bildmitte setzen
    scale(zoom, -zoom);
    translate(-x, -y);
    this.active = true;
  }
  
  void strokeWeight(float w) {
    g.strokeWeight(w / zoom);
  }

  void leave() {
    if (!active) return;
    popMatrix();
    this.active = false;
  }

  // Führt das `lambda` mit Kameratransformation aus. Anschließend wird der 
  // ursprüngliche Status wiederhergestellt.
  void entered(Runnable lambda) {
    boolean before = this.active;
    this.enter();
    try { lambda.run(); } // lambda.run() könnte eine Exception erzeugen. Try sorgt dafür, dass der Zustant immer zurückgesetzt wird.
    finally { if (!before) this.leave(); }
  }

  void text(String s, float x, float y) {
    pushMatrix();
    translate(x, y);
    scale(1, -1);              // y-Spiegelung für den Text aufheben
    g.textSize(16 / zoom);     // 16 px auf dem Bildschirm
    g.fill(0);
    g.textAlign(CENTER, BOTTOM);
    g.text(s, 0, 0);           // g.text statt text → keine Rekursion
    popMatrix();
  }

  public void pan(float dx, float dy) {
    this.x += dx;
    this.y += dy;
  }

  public void zoom(float d) {
    this.zoom += d;
  }

  public void handleDrag() {
    float dx = mouseX - pmouseX;
    float dy = mouseY - pmouseY;
    pan(-dx / zoom, dy / zoom);
  }

  PGraphics graphics() { return g; }
}
