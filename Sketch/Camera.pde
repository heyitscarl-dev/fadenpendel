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

  void drawLabel(String text, PVector attachment) {
    latex(text, attachment.x, attachment.y);
  }

  void latex(String tex, float x, float y) {
    latex(tex, x, y, 16);
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

  void drawArrow(PVector origin, PVector vector, int stroke_color) {
      float len = vector.mag();
      if (len < 1e-6) return;

      PVector to = PVector.add(origin, vector);
      PVector dir = PVector.div(vector, len);
      PVector perp = new PVector(-dir.y, dir.x);

      float head = min(0.2, len * 0.2);
      PVector base = PVector.sub(to, PVector.mult(dir, head));

      stroke(stroke_color);
      this.strokeWeight(1.5);
      line(origin.x, origin.y, to.x, to.y);
      line(to.x, to.y, base.x + perp.x * head * 0.5, base.y + perp.y * head * 0.5);
      line(to.x, to.y, base.x - perp.x * head * 0.5, base.y - perp.y * head * 0.5);
  }
}
