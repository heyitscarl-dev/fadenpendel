class ForceArrow implements UIArrow {
    int stroke;
    PVector vector;
    PVector origin;

    int strokeColor() {
        return stroke;
    }

    PVector vector() {
        return vector;
    }

    PVector origin() {
        return origin;
    }

    ForceArrow(int stroke, PVector vector, PVector origin) {
        this.stroke = stroke;
        this.vector = vector;
        this.origin = origin;
    }
}

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

    ForceArrow toArrow() {
        return new ForceArrow(this.stroke, this.vector, this.origin);
    }

    Force scaled(float scalar) {
        PVector updated = PVector.mult(this.vector, scalar);
        return new Force(origin, updated, label, stroke);
    }

    PVector getVector() {
        return vector;
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