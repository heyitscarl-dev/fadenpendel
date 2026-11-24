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
        }

        PVector Fliehkraft = PVector.mult(body.position, body.mass * sq(velocity) / body.radius);
        body.forces.add(new Force(body.position ,body.position, "|F_f|=" + round(Fliehkraft.mag()*10)/10.0 + "\\,\\mathrm{N}"));
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