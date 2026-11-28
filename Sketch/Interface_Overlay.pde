/* Ein `Overlay` beschreibt eine Ebene, auf der UI Elemente gezeichnet werden können. */
class UIOverlay {
    public ArrayList<UIElement> elements = new ArrayList();
    public boolean active = true;

    public void drawToScreen(Camera camera) {
        if (!active) return;
        if (elements.isEmpty()) return;

        elements.forEach(e -> {
            if (e == null) return;
            if (!e.visible()) return;
            e.drawToScreen(camera, null);
        });
    }

    public boolean handleClick(Camera camera, PVector position) {
        boolean handled = false;
        for (UIElement e : elements) {
            if (e == null) continue;
            if (e.handleClick(camera, position)) handled = true;
        }
        return handled;
    }
}