void tick(float dt) {
    if (!running && !doStep) return;
    if (doStep) doStep = false;

    for (Spring spring : env.getSprings()) {
        Force[] forces = spring.forces(new String[]{
        "|F_D|=%v\\,\\mathrm{N}",
        "|F_D|=%v\\,\\mathrm{N}"
        });

        spring.b.applyForce(forces[0]);
        spring.a.applyForce(forces[1]);
    }

    // !!! ERSTE IMPLEMENTIERUNG VON KOLLISION ÜBER IMPULSE

    ArrayList<Body> bodies = env.getBodies();
    for (int i = 0; i < bodies.size(); i++) {
        Body b1 = bodies.get(i);
        for (int i2 = i + 1; i2 < bodies.size(); i2++) {
            Body b2 = bodies.get(i2);
            if (b1 == b2) continue;
            if (b1.fixed && b2.fixed) continue;

            float invMass1 = (b1.fixed) ? 0 : 1 / b1.mass;
            float invMass2 = (b2.fixed) ? 0 : 1 / b2.mass;

            // Einfacher Ansatz, der einch alle möglichen Parre überprüft (ohne broad und narrow stage)

            PVector delta = PVector.sub(b2.position, b1.position);
            float distance = delta.mag();

            if (distance > (b1.radius + b2.radius)) continue;

            float error = (b1.radius + b2.radius) - distance;
            PVector normal = delta.copy();
            normal.normalize();

            float vRel = PVector.dot(PVector.sub(b2.velocity, b1.velocity), normal);
            if (vRel > 0) { // Körper entfernen sich bereits voneinander; Nichts tun
                continue;
            }

            float e = 1.0;
            float j = -(1 + e) * vRel / (invMass1 + invMass2);
            
            b1.velocity = PVector.sub(b1.velocity, PVector.mult(normal, j * invMass1));
            b2.velocity = PVector.add(b2.velocity, PVector.mult(normal, j * invMass2));

            float w1 = invMass1 / (invMass1 + invMass2);
            float w2 = invMass2 / (invMass1 + invMass2);

            b1.position = PVector.sub(b1.position, PVector.mult(normal, error * w1));
            b2.position = PVector.add(b2.position, PVector.mult(normal, error * w2));
        }
    }

    for (Body body : env.getBodies()) {    
        if (body.fixed) {
        body.clearForces();
        continue;
        }

        // Kräfte
        body.forces.add(new Force(
        body.position,
        new PVector(0.0, -env.gravity * body.mass),
        "|F_g|=" + round((env.gravity * body.mass) * 10)/10.0 + "\\,\\mathrm{N}",
        color(255, 0, 0)
        )); // Gewichtskraft

        float velocity = body.velocity.mag();
        float dragFactor = -0.5 * 1.204 * 0.4 * PI * body.radius * body.radius * velocity; // nur 1x velocity, weil body.velocity später multipliziert wird
        PVector drag = PVector.mult(body.velocity, dragFactor);
        body.forces.add(new Force(
        body.position,
        drag,
        "|F_L|=" + round(drag.mag()*10)/10.0 + "\\,\\mathrm{N}",
        color(0, 0, 255)
        )); // Luftwiderstand
        

        //float Fliehkraft = (body.mass * sq(velocity) / spring.length() );
        //body.forces.add(new Force(body.position ,body.position, "|F_f|=" + round(Fliehkraft*10)/10.0 + "\\,\\mathrm{N}", color(0,0,0)));
        //Fliehkraft

        // Resultierende Kraft berechnen 
        PVector res = new PVector(0.0, 0.0);
        for (Force f : body.forces) {
            res = res.add(f.getVector());
        }
        
        body.clearForces();

        // Beschleunigung
        PVector a = res.div(body.mass);
        
        // Geschwindigkeits aenderung
        PVector dv = a.mult(dt);

        //Geschwindigkeits aenderung auf Geschwindigkeit addieren
        body.velocity = body.velocity.add(dv);
        
        // Zurueckgelegte Strecke
        PVector dp = PVector.mult(body.velocity, dt);
        
        // Neue Position
        body.position = body.position.add(dp);
    }
}