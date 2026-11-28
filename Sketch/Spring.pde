final float THREAD_STIFFNESS = 1e5;

class Spring implements UIOffsetLabel, Selectable {
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
        if (stiffness >= THREAD_STIFFNESS) zeta = 1.0;
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

    // Kopie, die zwischen den Körpern `a` und `b` (aus dem kopierten
    // Environment) hängt. Steifigkeit, Dämpfung und Ruhelänge werden
    // übernommen statt neu berechnet, weil der Konstruktor die Ruhelänge
    // aus den *aktuellen* Positionen bestimmt.
    Spring copy(Body a, Body b) {
        Spring copy = new Spring(stiffness, a, b);
        copy.damping = damping;
        copy.length = length;
        return copy;
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
        if (this.stiffness >= THREAD_STIFFNESS) {
            draw_as_line(cam);
            return;
        }
        draw_as_spring(cam);
    }

    final float SPRING_AMPLITUDE = 0.2;

    private void draw_as_spring(Camera cam) {
        cam.strokeWeight(1);

        int steps = int(5 * length);
        float amplitude = SPRING_AMPLITUDE;

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

    PVector midpoint() {
        return PVector.lerp(this.a.position, this.b.position, 0.5);
    }

    void drawBounding(Camera camera, float gap) {
        float rad = PVector.sub(b.position, a.position).heading();
        float width =  (this.stiffness >= THREAD_STIFFNESS) ? 0.5 : (2 * SPRING_AMPLITUDE);
        PVector midpoint = PVector.lerp(a.position, b.position, 0.5);
        pushMatrix();
        translate(midpoint.x, midpoint.y);
        rotate(rad);
        fill(color(THEME_SELECTION, 100));
        stroke(color(THEME_SELECTION));
        rectMode(CENTER);
        rect(0, 0, length(), width + 2 * gap);
        rectMode(CORNER);
        popMatrix();
    }
}