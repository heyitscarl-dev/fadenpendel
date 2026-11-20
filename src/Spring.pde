class Spring {
    float stiffness;
    float length;

    Body a, b;

    Spring(float stiffness, float length, Body a, Body b) {
        this.stiffness = stiffness;
        this.length = length;
        this.a = a;
        this.b = b;
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
        if (this.stiffness >= 500) {
            draw_as_line(cam);
            return;
        }
        draw_as_spring(cam);
    }

    private void draw_as_spring(Camera cam) {
        beginShape();
        vertex(a.position.x, a.position.y);

        // ...

        vertex(b.position.x, b.position.y);
        endShape();
    }

    private void draw_as_line(Camera cam) {
        cam.strokeWeight(1);
        line(a.position.x, a.position.y, b.position.x, b.position.y);
    }
}