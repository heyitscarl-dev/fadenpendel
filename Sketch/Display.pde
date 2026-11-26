class Display {
    int strokeBody = color(0);
    int fillBody = color(0.9 * 255);
    int strokeSpring = color(0);
    int fillSpring = color(255);

    void draw(Camera cam) {
        cam.enter();
        background(THEME_BACKGROUND);

        for (Spring s : env.getSprings()) s.draw(cam);

        for (Body b : env.getBodies()) {
            stroke(strokeBody);
            fill(fillBody);
            cam.strokeWeight(1);
            b.draw(cam);
        }

        forceOverlay.elements.clear();
        velocityOverlay.elements.clear();
        quantityOverlay.elements.clear();
        for (Body b : env.getBodies()) {
            if (b.fixed == true) continue; // skip fixed bodies
            velocityOverlay.elements.add(b.toVelocityArrow());
            quantityOverlay.elements.add(b);
            for (Force f : b.lastForces) {
                forceOverlay.elements.add(f.scaled(FORCE_SCALE).toArrow());
            }
        }
        for (Spring s : env.getSprings()) {
            quantityOverlay.elements.add(s);
        }
        
        cam.leave();

        fill(0, 0, 0);
        textSize(12.5);
        textAlign(LEFT, BASELINE);
        text("[Space] to pause", 30, height - 30);
        text("[Enter] to step", 30, height - 45);
        text("[1-8] scenario", 30, height - 60);
    }
}