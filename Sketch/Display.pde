class Display {
    int strokeBody = color(0);
    int fillBody = color(0.9 * 255);
    int strokeSpring = color(0);
    int fillSpring = color(255);

    void draw(Camera cam) {
        cam.enter();
        background(255, 255, 255);

        for (Spring s : env.getSprings()) s.draw(cam);

        for (Body b : env.getBodies()) {
            stroke(strokeBody);
            fill(fillBody);
            cam.strokeWeight(1);
            b.draw();
        }

        for (Body b : env.getBodies()) {
            for (Force f : b.lastForces) {
            f.scaled(FORCE_SCALE).draw(cam);
            }
        }
        
        cam.leave();

        fill(0, 0, 0);
        textSize(12.5);
        textAlign(LEFT, BASELINE);
        text("[Space] to pause", 30, height - 30);
        text("[Enter] to step", 30, height - 45);
    }
}