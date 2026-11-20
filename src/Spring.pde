class Spring implements Labeled {
    public static final int PEAKS_PER_DISTANCE = 2;

    float stiffness;
    float length;

    Body a, b;

    Spring(float stiffness, Body a, Body b) {
        this.stiffness = stiffness;
        this.a = a;
        this.b = b;
        this.length = length();
    }

    PVector force() {
        PVector a = this.a.position();
        PVector b = this.b.position();

        float distance = PVector.dist(a, b);
        float error = distance - length;

        float f = error * -(stiffness);
        PVector normal = PVector.sub(b, a);
        normal.normalize();
        return PVector.mult(normal, f);
    }

    public void draw(Camera cam) {
        draw_text("l = " + (round(length() * 10) / 10.0) + "\\,\\mathrm{m}", cam);
        if (this.stiffness >= 500) {
            draw_as_line(cam);
            return;
        }
        draw_as_spring(cam);
    }

    public PVector getAttachmentPoint() {
        PVector mid = PVector.lerp(a.position, b.position, 0.5);
        PVector perp = PVector.sub(b.position, a.position);
        perp.normalize();
        perp = new PVector(-perp.y, perp.x);
        mid = PVector.add(mid, PVector.mult(perp, 0.35));
        return mid;
    }

    private void draw_text(String text, Camera cam) {
        cam.drawLabel(text, this);
    }

    private void draw_as_spring(Camera cam) {
        int steps = int(5 * length);
        float amplitude = 0.2;

        PVector delta = PVector.sub(b.position, a.position);
        float len = PVector.dist(b.position, a.position);

        float nx = -delta.y / len;
        float ny = delta.x / len;

        beginShape();
        vertex(a.position.x, a.position.y);

        for (int i = 0; i < steps; i++) {
            float t = i / float(steps);
            float bx = lerp(a.position.x, b.position.x, t);
            float by = lerp(a.position.y, b.position.y, t);

            float side = (i % 2 == 1) ? 1 : -1;
            float vx, vy;

            if (i < 2 || i >= (steps - 2)) {
                vx = bx;
                vy = by;
            } else {
                vx = bx + nx * amplitude * side;
                vy = by + ny * amplitude * side;
            }

            vertex(vx, vy);
        }

        vertex(b.position.x, b.position.y);
        endShape();
    }

    private void draw_as_line(Camera cam) {
        cam.strokeWeight(1);
        line(a.position.x, a.position.y, b.position.x, b.position.y);
    }
    
    float length(){
        float s1 = b.position.x - a.position.x;
        float s2 = b.position.y - a.position.y;

        float length = sqrt(s1*s1+s2*s2);

        return length;
    }
}