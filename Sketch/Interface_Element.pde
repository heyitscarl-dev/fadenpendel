// Element, das in Weltkoordinaten (Meter) gezeichnet wird, z.B. Kräftepfeile oder
// Labels. Beim Aufruf ist die Kameratransformation (cam.enter() / cam.leave)
// bereits aktiv.
interface WorldSpaceElement {
    void draw(Camera camera);
}

// Element, das in Bildschirmkoordinaten (px) gezeichnet wird, z.B. Toggles oder
// Textfelder. Beim Aufruf ist die Kameratransformation (cam.enter() / cam.leave)
// nicht aktiv.
interface ScreenSpaceElement {
    void drawToScreen(Camera camera, Rectangle bounds);
    PVector dimensions();

    // Rückgabe: `true` = verbraucht; `false` = transparent oder nicht verbraucht.
    default boolean handleMouse(PVector position, Rectangle bounds) { return false; }
}

class Toggle implements ScreenSpaceElement {
    final float WIDTH   = 40;
    final float HEIGHT  = 25;
    
    boolean state;

    float animation; // Describes the progerssion of the animation, from 0.0 (left) to 1.0 (right)

    PVector dimensions() {
        return new PVector(WIDTH, HEIGHT);
    }

    void animate() {
        float target = state ? 1.0 : 0.0;
        animation += (target - animation) * 0.2;
    }

    void drawToScreen(Camera camera, Rectangle bounds) {
        animate();

        strokeWeight(THEME_TOGGLE_STROKE_WEIGHT);
        stroke(THEME_TOGGLE_STROKE);

        fill(lerpColor(THEME_TOGGLE_TRACK_OFF, THEME_TOGGLE_TRACK_ON, animation));
        rect(bounds.position.x, bounds.position.y, bounds.size.x, bounds.size.y, bounds.size.y / 2);

        fill(lerpColor(THEME_TOGGLE_KNOB_OFF, THEME_TOGGLE_KNOB_ON, animation));
        float offset = 0.1;
        float radius = bounds.size.y * 0.5;
        float radiusRelative = radius / bounds.size.x;
        PVector left = new PVector(radiusRelative - offset, 0.5);
        PVector right = new PVector(1.0 - (radiusRelative - offset), 0.5);
        PVector point = PVector.lerp(left, right, animation);
        PVector centre = bounds.absolute(point);
        circle(centre.x, centre.y, 2 * radius);
    }

    boolean handleMouse(PVector position, Rectangle bounds) {
        state = !state;
        return true;
    }
}