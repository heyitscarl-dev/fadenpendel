static final float LABEL_SIZE = 16f;

interface UIElement {
    void drawToScreen(Camera camera, PVector position);
    PVector dimensions(Camera camera);
    boolean handleClick(Camera camera, PVector position);
    default boolean visible() { return true; }
    // Wird nur für das Element mit Fokus aufgerufen (siehe `focused` in Sketch.pde).
    // true = Taste verbraucht, keine weiteren Shortcuts.
    default boolean handleKey(char key, int keyCode) { return false; }
    default void tick() {}
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

    default boolean handleClick(Camera camera, PVector position) { return false; }
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

    default boolean handleClick(Camera camera, PVector position) { return false; }
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

    boolean state;

    // Position des Knopfs: 0 = ganz links (aus), 1 = ganz rechts (an).
    // Läuft jedes Frame ein Stück auf den Zielwert zu, dadurch gleitet er.
    float knob = state ? 1 : 0;

    // Wo der Schalter zuletzt gezeichnet wurde (für contains()).
    PVector lastPosition = null;

    TeXIcon label;

    Toggle(boolean state, String label) {
        this.state = state;
        this.label = latexIcon(label, LABEL_SIZE);
    }

    boolean handleClick(Camera camera, PVector position) {
        if (contains(position.x, position.y)) {
            toggle();
            return true;
        }
        return false;
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

// Berührungspunkt zweier Körper. Pro Körperpaar gibt es höchstens einen
// Contact; solange die Körper sich berühren, wird er aufgefrischt.
class Contact implements UIElement {
    Body a, b;
    PVector position;
    float since; // Simulationszeit der letzten Berührung (s)

    Contact(Body a, Body b, PVector position) {
        this.a = a;
        this.b = b;
        refresh(position);
    }

    void refresh(PVector position) {
        this.position = position;
        this.since = simTime;
    }

    boolean involves(Body a, Body b) {
        return (this.a == a && this.b == b) || (this.a == b && this.b == a);
    }

    PVector dimensions(Camera camera) { return null; }
    boolean handleClick(Camera camera, PVector position) { return false; }
    void drawToScreen(Camera camera, PVector _position) {
        push(); // Stil nicht an nachfolgende Zeichnungen weitergeben
        noStroke();
        fill(color(200, 0, 200));
        circle(position.x, position.y, 0.125);
        pop();
    }
}

/* Ein Textfeld, dessen Inhalt live als LaTeX gesetzt wird.
 * Klick hinein = Fokus, Enter/Escape oder Klick daneben = Fokus weg.
 * Solange die Eingabe kein gültiges LaTeX ist (z. B. "\frac{"),
 * wird der Quelltext grau angezeigt. */
class Pill implements UIElement {
    final float MIN_WIDTH = 50;
    final float MIN_HEIGHT = 25;
    final float INNER_PADDING = 8;

    String prefix = "";
    String suffix = "";
    String text = "";
    TeXIcon icon = null;  // null = Text ist (noch) kein gültiges LaTeX
    TeXIcon suffixIcon = null;

    PVector lastPosition = null;

    Pill() {}

    Pill(String prefix, String text, String suffix) {
        this.prefix = prefix;
        this.suffix = suffix;
        setText(text);
    }

    void setText(String text) {
        this.text = text;
        try {
            // Nicht über latexIcon(): der Cache würde sonst jeden Tastendruck speichern.
            icon = new TeXFormula(prefix + text).createTeXIcon(TeXConstants.STYLE_DISPLAY, LABEL_SIZE);
            suffixIcon = new TeXFormula(suffix).createTeXIcon(TeXConstants.STYLE_DISPLAY, LABEL_SIZE);
            icon.setForeground(java.awt.Color.BLACK);
            suffixIcon.setForeground(java.awt.Color.BLACK);
        } catch (Exception e) {
            icon = null;  // ParseException o. ä.: unvollständige Eingabe
            suffixIcon = null;
        }
    }

    boolean isFocused() { return focused == this; }

    float contentWidth() {
        float a = icon != null ? icon.getIconWidth() : 0;
        float b = suffixIcon != null ? suffixIcon.getIconWidth() : 0;
        if (max(a, b) != 0) return a + b;
        textSize(12.5);
        return textWidth(text);
    }

    float contentHeight() {
        float a = icon != null ? icon.getIconHeight() : 12.5;
        float b = suffixIcon != null ? suffixIcon.getIconHeight() : 12.5;
        return max(a, b);
    }

    PVector dimensions(Camera camera) {
        return new PVector(
            max(MIN_WIDTH, contentWidth() + 2 * INNER_PADDING),
            max(MIN_HEIGHT, contentHeight() + 2 * INNER_PADDING)
        );
    }

    boolean contains(float x, float y) {
        if (lastPosition == null) return false;
        PVector d = dimensions(null);
        return x >= lastPosition.x && x <= lastPosition.x + d.x
            && y >= lastPosition.y && y <= lastPosition.y + d.y;
    }

    boolean handleClick(Camera camera, PVector position) {
        if (contains(position.x, position.y)) {
            focused = this;
            return true;
        }
        return false;
    }

    boolean handleKey(char key, int keyCode) {
        if (key == CODED) return true;  // Pfeiltasten, Shift, ... schlucken
        if (key == ENTER || key == RETURN || key == ESC) {
            focused = null;
        } else if (key == BACKSPACE) {
            if (text.length() > 0) setText(text.substring(0, text.length() - 1));
        } else if (key >= ' ') {
            setText(text + key);
        }
        return true;
    }

    void drawToScreen(Camera camera, PVector position) {
        if (position == null) return;
        lastPosition = position.copy();
        PVector d = dimensions(camera);

        fill(THEME_PANEL);
        stroke(isFocused() ? THEME_SELECTION : THEME_PANEL_EDGE);
        strokeWeight(isFocused() ? 1 : 0.5);
        rect(position.x, position.y, d.x, d.y, UI_CONTAINER_BORDER_RADIUS);

        float x = position.x + INNER_PADDING;
        float bottom = position.y + (d.y + contentHeight()) / 2;  // vertikal zentriert
        if (icon != null) {
            camera.latexScreen(icon, x, bottom);
        } else {
            fill(120);
            textSize(12.5);
            textAlign(LEFT, BOTTOM);
            text(text, x, bottom);
        }

        // Blinkender Cursor am Ende
        if (isFocused() && millis() % 1000 < 500) {
            float cx = x + contentWidth() + 2;
            stroke(0);
            strokeWeight(1);
            line(cx, position.y + INNER_PADDING / 2, cx, position.y + d.y - INNER_PADDING / 2);
        }

        // Suffix
        if (suffixIcon != null) {
            camera.latexScreen(suffixIcon, x + icon.getIconWidth(), bottom);
        } else {
            fill(120);
            textSize(12.5);
            textAlign(LEFT, BOTTOM);
            text(text, x + icon.getIconWidth(), bottom);
        }
    }
}