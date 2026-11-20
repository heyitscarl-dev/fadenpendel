class Spring {
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

    float length(){
        float s1 = b.position.x - a.position.x;
        float s2 = b.position.y - a.position.y;

        float length = sqrt(s1*s1+s2*s2);

        return length;
    }
}