final float UI_CONTAINER_BORDER_RADIUS = 6.25;
final PVector UI_CONTAINER_PADDING = new PVector(12.5, 12.5);
final float UI_CONTAINER_MARGIN = 12.5;

class UIContainer implements UIElement {
    public ArrayList<UIElement> elements = new ArrayList();
    public PVector position;

    public UIContainer(PVector position) {
        this.position = position;
    }

    public PVector dimensions(Camera camera) {
        PVector dimensions = new PVector(0f, 0f);
        for (UIElement e : elements) {
            PVector elementDimensions = e.dimensions(camera);
            if (elementDimensions.x > dimensions.x) dimensions.x = elementDimensions.x;
            dimensions.y += UI_CONTAINER_MARGIN + e.dimensions(camera).y;
        }
        if (elements.size() != 0) dimensions.y -= UI_CONTAINER_MARGIN; // Entfernt die letzte margin.
        dimensions.add(UI_CONTAINER_PADDING);
        dimensions.add(UI_CONTAINER_PADDING); // Doppelt; Einmal links/oben, einmal rechts/unten
        return dimensions;
    }

    boolean contains(Camera camera, float x, float y) {
        PVector dimensions = this.dimensions(camera);
        return x >= position.x && x <= position.x + dimensions.x
            && y >= position.y && y <= position.y + dimensions.y;
    }

    boolean handleClick(Camera camera, PVector position) {
        if (contains(camera, position.x, position.y)) {
            elements.forEach(e -> e.handleClick(camera, position));
            return true;
        }
        return false;
    }

    public void drawToScreen(Camera camera, PVector _position) { // `_position` wird ignoriert, da sich Container selber positionieren.
        fill(THEME_PANEL);
        stroke(THEME_PANEL_EDGE);
        strokeWeight(0.5);
        PVector dimensions = dimensions(camera);
        rect(this.position.x, this.position.y, dimensions.x, dimensions.y, UI_CONTAINER_BORDER_RADIUS);
        
        float height = UI_CONTAINER_PADDING.y;
        for (UIElement e : this.elements) {
            e.drawToScreen(camera, PVector.add(position, new PVector(UI_CONTAINER_PADDING.x, height)));
            height += e.dimensions(camera).y + UI_CONTAINER_MARGIN;
        }
    }
}