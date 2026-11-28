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
    final float WIDTH   = 50;
    final float HEIGHT  = 25;
    
    boolean state;

    float animation; // Describes the progerssion of the animation, from 0.0 (left) to 1.0 (right)

    PVector dimensions() {
        return new PVector(WIDTH, HEIGHT);
    }

    void animate() {
        
    }

    void drawToScreen(Camera camera, Rectangle bounds) {
        animate();

        camera.strokeWeight(THEME_TOGGLE_STROKE_WEIGHT);
        stroke(THEME_TOGGLE_STROKE);

        fill(lerpColor(THEME_TOGGLE_TRACK_OFF, THEME_TOGGLE_TRACK_ON, animation));
        rect(bounds.position.x, bounds.position.y, WIDTH, HEIGHT, HEIGHT / 2);
    }

    boolean handleMouse(PVector position, Rectangle bounds) {
        System.out.println("HEY");
        return true;
    }
}