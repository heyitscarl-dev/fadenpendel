/* Button ist ein UI-Element. Alle Positionen, etc. sind in Screen px, nicht Welt px. */
class Button {
    boolean active;
    String label;
    float radius;

    PVector midpoint;

    Button(boolean initial, String label, PVector midpoint) {
        this.active = initial;
        this.label = label;
        this.midpoint = midpoint;
        this.radius = 25;
    }

    boolean state() {
        return this.active;
    }

    void draw(Camera cam) {
        fill(255);
        stroke(0);
        strokeWeight(0.5);
        ellipse(midpoint.x, midpoint.y, radius, radius);

        if (this.active) {
            float halfRadius = radius / 2.0;
            line(midpoint.x - halfRadius, midpoint.y - halfRadius, midpoint.x + halfRadius, midpoint.y + halfRadius);
            line(midpoint.x - halfRadius, midpoint.y + halfRadius, midpoint.x + halfRadius, midpoint.y - halfRadius);
        }
        
        cam.latexScreen("\\text{" + this.label + "}", midpoint.x + 20, midpoint.y + 8, 16);
    }

    void handleMousePressed() {
        PVector mouse = new PVector(mouseX, mouseY);
        PVector delta = PVector.sub(mouse, midpoint);
        
        if (delta.mag() < radius) {
            this.active = !this.active;
        }
    }
}