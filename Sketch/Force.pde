class ForceArrow implements UIArrow {
    int stroke;
    PVector vector;
    PVector origin;
    String label;

    int strokeColor() {
        return stroke;
    }

    PVector vector() {
        return vector;
    }

    PVector origin() {
        return origin;
    }

    TeXIcon label() {
        return latexIcon(label, LABEL_SIZE);
    }

    ForceArrow(int stroke, PVector vector, PVector origin, String label) {
        this.stroke = stroke;
        this.vector = vector;
        this.origin = origin;
        this.label = label;
    }
}

class Force {
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
        return new ForceArrow(this.stroke, this.vector, this.origin, this.label);
    }

    Force scaled(float scalar) {
        PVector updated = PVector.mult(this.vector, scalar);
        return new Force(origin, updated, label, stroke);
    }

    PVector getVector() {
        return vector;
    }
}