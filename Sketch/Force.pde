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

    Force scaled(float scalar) {
        PVector updated = PVector.mult(this.vector, scalar);
        return new Force(origin, updated, label, stroke);
    }

    PVector getVector() {
        return vector;
    }
}