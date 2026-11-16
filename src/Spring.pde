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
}