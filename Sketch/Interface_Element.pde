interface UIElement {
    void drawToScreen(Camera camera, PVector position);
    PVector dimensions();
    void handleClick(PVector position);
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

    void handleClick(PVector position) {
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

    PVector dimensions() {
        return new PVector(WIDTH + label.getIconWidth() + LABEL_INNER_MARGIN, HEIGHT);
    }
}