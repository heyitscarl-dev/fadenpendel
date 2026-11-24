/* Ein `Overlay` beschreibt eine Ebene, auf der UI Elemente gezeichnet werden können. */
class UIOverlay {
    public ArrayList<UIElement> elements = new ArrayList();
    public boolean active = true;

    public void drawToScreen(Camera camera) {
        if (!active) return;
        if (elements.isEmpty()) return;

        elements.forEach(e -> {
            if (!e.visible()) return;
            e.drawToScreen(camera, null);
        });
    }

    public void handleClick(Camera camera, PVector position) {
        elements.forEach(e -> e.handleClick(camera, position));
    }
}