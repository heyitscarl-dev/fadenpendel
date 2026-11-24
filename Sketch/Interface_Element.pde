static final float LABEL_SIZE = 16f;

interface UIElement {
    void drawToScreen(Camera camera, PVector position);
    PVector dimensions(Camera camera);
    void handleClick(Camera camera, PVector position);
    default boolean visible() { return true; }
}

interface UILabel extends UIElement {
    TeXIcon label(Camera camera);
    PVector anchor(Camera camera);  // Linke untere Ecke des Labels in Welt-Koordinaten

    default void drawToScreen(Camera camera, PVector position) {
        PVector anchor = anchor(camera);
        camera.latex(label(camera), anchor.x, anchor.y);
    }

    default PVector dimensions(Camera camera) {
        TeXIcon label = label(camera);
        return new PVector(label.getIconWidth(), label.getIconHeight());
    }

    default void handleClick(Camera camera, PVector position) {}
}

interface UIOffsetLabel extends UILabel {
    PVector origin();
    PVector vector();

    default PVector anchor(Camera camera) {
        float len = vector().mag();
        if (len < 1e-6) return origin().copy();

        PVector to = PVector.add(origin(), vector());
        PVector dir = PVector.div(vector(), len);
        PVector perp = new PVector(-dir.y, dir.x);

        PVector mid = PVector.lerp(origin(), to, 0.5);
        TeXIcon label = label(camera);
        float w = label.getIconWidth()  / camera.zoom;
        float h = label.getIconHeight() / camera.zoom;

        PVector anchor = PVector.add(mid, PVector.mult(perp, 0.1));  // small gap
        anchor.x -= w * (1 - perp.x) / 2;
        anchor.y -= h * (1 - perp.y) / 2;
        return anchor;
    }
}

interface UIArrow extends UIOffsetLabel {
    PVector vector();
    PVector origin();
    int strokeColor();

    default PVector dimensions() {
        return new PVector(abs(vector().x), abs(vector().y));
    }

    default void handleClick(Camera camera, PVector position) {}
    default void drawToScreen(Camera camera, PVector _position) {
        float len = vector().mag();
        if (len < 1e-6) return;

        PVector to = PVector.add(origin(), vector());
        PVector dir = PVector.div(vector(), len);
        PVector perp = new PVector(-dir.y, dir.x);

        float head = min(0.2, len * 0.2);
        PVector base = PVector.sub(to, PVector.mult(dir, head));

        camera.graphics().stroke(strokeColor());
        camera.strokeWeight(1.5);
        camera.graphics().line(origin().x, origin().y, to.x, to.y);
        camera.graphics().line(to.x, to.y, base.x + perp.x * head * 0.5, base.y + perp.y * head * 0.5);
        camera.graphics().line(to.x, to.y, base.x - perp.x * head * 0.5, base.y - perp.y * head * 0.5);

        UIOffsetLabel.super.drawToScreen(camera, _position);
    }
}

/* Ein "An/Aus Schalter" im Stil einer TikZ-Zeichnung: schwarze Konturen,
 * weiße bzw. hellgraue Flächen, keine Schatten. Wie
 *   \draw[thick, fill=black!10] (0,0) [rounded rectangle] ...;
 *   \fill (x,y) circle (r);
 * Der Knopf ist aus = hohl, an = schwarz gefüllt, und gleitet zur Seite. */
class Toggle implements UIElement {
    final float LABEL_SIZE = 16;

    final float WIDTH = 38;
    final float HEIGHT = 20;
    final float KNOB_INSET = 3;    // Abstand zwischen Knopf und Rand der Spur
    final float LINE_WIDTH = 0.8;  // entspricht TikZ "thick" (0.8pt)

    final float LABEL_INNER_MARGIN = WIDTH / 2;

    final int INK       = color(0);    // "black"
    final int TRACK_OFF = color(255);  // "white"
    final int TRACK_ON  = color(230);  // "black!10"

    boolean state = true;

    // Position des Knopfs: 0 = ganz links (aus), 1 = ganz rechts (an).
    // Läuft jedes Frame ein Stück auf den Zielwert zu, dadurch gleitet er.
    float knob = state ? 1 : 0;

    // Wo der Schalter zuletzt gezeichnet wurde (für contains()).
    PVector lastPosition = null;

    TeXIcon label;

    Toggle(String label) {
        this.label = latexIcon(label, LABEL_SIZE);
    }

    void handleClick(Camera camera, PVector position) {
        if (contains(position.x, position.y)) toggle();
    }

    void toggle() {
        state = !state;
    }

    // Liegt der Punkt (x, y) auf dem Schalter? Funktioniert erst, nachdem er
    // einmal gezeichnet wurde, weil er seine Position vom Container bekommt.
    boolean contains(float x, float y) {
        if (lastPosition == null) return false;
        return x >= lastPosition.x && x <= lastPosition.x + WIDTH
            && y >= lastPosition.y && y <= lastPosition.y + HEIGHT;
    }

    void drawToScreen(Camera camera, PVector position) {
        if (position == null) return;
        lastPosition = position.copy();

        float target = state ? 1 : 0;
        knob += (target - knob) * 0.25;

        stroke(INK);
        strokeWeight(LINE_WIDTH);

        // Spur: Eckenradius = halbe Höhe ergibt eine Pille.
        // Füllung blendet von weiß (aus) zu hellgrau (an).
        fill(lerpColor(TRACK_OFF, TRACK_ON, knob));
        rect(position.x, position.y, WIDTH, HEIGHT, HEIGHT / 2);

        // Knopf: Kreis mit schwarzer Kontur; Füllung blendet von weiß zu schwarz.
        float diameter = HEIGHT - 2 * KNOB_INSET;
        float left  = position.x + KNOB_INSET + diameter / 2;
        float right = position.x + WIDTH - KNOB_INSET - diameter / 2;
        float x = lerp(left, right, knob);
        float y = position.y + HEIGHT / 2;

        fill(lerpColor(color(255), INK, knob));
        circle(x, y, diameter);

        camera.latexScreen(this.label, position.x + WIDTH + LABEL_INNER_MARGIN, position.y + HEIGHT / 1.2);
    }

    PVector dimensions(Camera camera) {
        return new PVector(WIDTH + label.getIconWidth() + LABEL_INNER_MARGIN, HEIGHT);
    }
}