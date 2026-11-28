final float BOUNDING_BOX_GAP = 4.0;

class Display {
    int strokeBody = color(0);
    int fillBody = color(0.9 * 255);
    int strokeSpring = color(0);
    int fillSpring = color(255);

    void draw(Camera cam) {
        cam.enter();

        for (Spring s : env.getSprings()) {
            s.draw(cam);
        }

        for (Body b : env.getBodies()) {
            fill(fillBody);
            stroke(strokeBody);
            if (b == selected) {  }
            cam.strokeWeight(1);
            b.draw(cam);
        }

        if (selected != null) selected.drawBounding(cam, cam.screenToWorld(BOUNDING_BOX_GAP));
        
        cam.leave();

        fill(0, 0, 0);
        textSize(12.5);
        textAlign(LEFT, BASELINE);
        text("[Space] to pause", 30, height - 30);
        text("[Enter] to step", 30, height - 45);
        text("[1-8] scenario", 30, height - 60);
    }
}