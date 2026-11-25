final float THREAD_STIFFNESS = 4 * 7500.0;

class Spring implements UIOffsetLabel {
    public static final int PEAKS_PER_DISTANCE = 2;

    float stiffness;
    float length;
    float damping;

    Body a, b;

    TeXIcon label(Camera camera) {
        return latexIcon("l = " + round(length() * 10) / 10.0 + "\\,\\mathrm m", LABEL_SIZE);
    }

    // Das Label sitzt, wie bei den Pfeilen, mittig neben der Strecke a -> b.
    PVector origin() { return a.position; }
    PVector vector() { return PVector.sub(b.position, a.position); }

    Spring(float stiffness, Body a, Body b) {
        float zeta;
        if (stiffness > THREAD_STIFFNESS) zeta = 1.0;
        else zeta = 0.0;

        // c = 2*\zeta \sqrt{k*\mu}
        float mu;
        if (a.fixed) mu = b.mass;
        else if (b.fixed) mu = a.mass;
        else mu = (a.mass * b.mass) / (a.mass + b.mass);

        float damping = 2 * zeta * sqrt(stiffness * mu);
        this.stiffness = stiffness;
        this.damping = damping;
        this.a = a;
        this.b = b;

        this.length = length();
    }

    /// Return a -> b as [0]
    ///    and b -> a as [1]
    Force[] forces(String[] labels) {
        PVector a = this.a.position();
        PVector b = this.b.position();

        float distance = PVector.dist(a, b);
        float error = distance - length;

        PVector normal = PVector.sub(b, a);
        normal.normalize();

        PVector vRel = PVector.sub(this.b.velocity, this.a.velocity);
        float vAlong = vRel.dot(normal);

        float f = error * -(stiffness) - damping * vAlong;

        PVector force = PVector.mult(normal, f);

        String mag = "" + round(force.mag() * 10) / 10.0;

        // [0]: Kraft auf b, [1]: Kraft auf a;
        return new Force[] {
            new Force(b, force, labels[0].replaceAll("%v", mag), color(0, 255, 0)),
            new Force(a, PVector.mult(force, -1), labels[1].replaceAll("%v", mag), color(0, 255, 0))
        };
    }

    public void draw(Camera cam) {
        stroke(0);
        if (this.stiffness >= 500) {
            draw_as_line(cam);
            return;
        }
        draw_as_spring(cam);
    }

    private void draw_as_spring(Camera cam) {
        cam.strokeWeight(1);

        int steps = int(5 * length);
        float amplitude = 0.2;

        PVector delta = PVector.sub(b.position, a.position);
        float len = PVector.dist(b.position, a.position);

        float nx = -delta.y / len;
        float ny = delta.x / len;

        fill(255);
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