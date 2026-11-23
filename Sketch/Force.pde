class Force implements Labeled {
    PVector origin;
    PVector vector;
    String label;
    int stroke;

    Force(PVector origin, PVector vector, String label, int stroke) {
        this.origin = origin;
        this.vector = vector;
        this.label  = label;
        this.stroke = stroke;
    }

    Force scaled(float scalar) {
        PVector updated = PVector.mult(this.vector, scalar);
        return new Force(origin, updated, label, stroke);
    }

    PVector getVector() {
        return vector;
    }

    public void draw(Camera cam) {
        float len = vector.mag();
        if (len < 1e-6) return;

        PVector to = PVector.add(origin, vector);
        PVector dir = PVector.div(vector, len);
        PVector perp = new PVector(-dir.y, dir.x);

        float head = min(0.2, len * 0.2);
        PVector base = PVector.sub(to, PVector.mult(dir, head));

        stroke(this.stroke);
        cam.strokeWeight(1.5);
        line(origin.x, origin.y, to.x, to.y);
        line(to.x, to.y, base.x + perp.x * head * 0.5, base.y + perp.y * head * 0.5);
        line(to.x, to.y, base.x - perp.x * head * 0.5, base.y - perp.y * head * 0.5);
        stroke(0);

        cam.drawLabel(label, this);
    }

    public PVector getAttachmentPoint() {
        PVector to = PVector.add(origin, vector);
        PVector mid = PVector.lerp(origin, to, 0.5);
        PVector perp = PVector.sub(to, origin);
        perp.normalize();
        perp = new PVector(-perp.y, perp.x);
        mid = PVector.add(mid, PVector.mult(perp, 0.35));
        return mid;
    }
}