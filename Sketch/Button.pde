class Button {
    boolean active;
    String label;

    PVector midpoint;

    Button(boolean initial, String label, PVector midpoint) {
        this.active = initial;
        this.label = label;
        this.midpoint = midpoint;
    }

    boolean state() {
        return this.active;
    }

    void draw(Camera cam) {
        fill(255);
        stroke(50);
        strokeWeight(0.5);
        ellipse(midpoint.x, midpoint.y, 25, 25);
        
        // Beschriftung rechts neben dem Kreis, in Bildschirm-Pixeln
        cam.latexScreen("\\text{" + this.label + "}", midpoint.x + 20, midpoint.y + 8, 16);
    }
}