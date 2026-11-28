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
}

class Toggle implements ScreenSpaceElement {
    final float WIDTH   = 25;
    final float HEIGHT  = 12.5;
    
    boolean state;

    PVector dimensions() {
        return new PVector(WIDTH, HEIGHT);
    }

    void drawToScreen(Camera camera, Rectangle bounds) {
        fill(THEME_TEST);
        rect(bounds.position.x, bounds.position.y, bounds.size.x, bounds.size.y);
    }
}