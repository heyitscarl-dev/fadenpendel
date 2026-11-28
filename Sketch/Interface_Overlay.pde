class WorldSpaceOverlay {
    ArrayList<WorldSpaceElement> elements   = new ArrayList();
    boolean active                          = true;

    void draw(Camera camera) {
        if (!this.active) return;
        camera.entered(() -> {
            for (WorldSpaceElement e : this.elements) {
                e.draw(camera);
            }
        });
    }
}

class ScreenSpaceOverlay {
    class Entry {
        ScreenSpaceElement element;
        PVector anchor, pivot, offset;
        Rectangle bounds;
    }

    ArrayList<Entry> entries                = new ArrayList();
    boolean active                          = true;

    public Entry add(ScreenSpaceElement element, PVector anchor, PVector pivot, PVector offset) {
        Entry entry     = new Entry();
        entry.element   = element;
        entry.anchor    = anchor.copy();
        entry.pivot     = pivot.copy();
        entry.offset    = offset.copy();
        entries.add(entry);
        return entry;
    }

    // Eine Überlagerung für die `add` Methode, wenn `anchor` und `pivot` gleich sind.
    public Entry add(ScreenSpaceElement element, PVector anchor, PVector offset) {
        Entry entry     = new Entry();
        entry.element   = element;
        entry.anchor    = anchor.copy();
        entry.pivot     = anchor.copy();
        entry.offset    = offset.copy();
        entries.add(entry);
        return entry;
    }

    public void remove(ScreenSpaceElement element) {
        entries.removeIf(e -> e.element == element);
    }

    // Setzt `bounds` (die absolute Position) für alle `entries`
    void layout() {
        Rectangle screen = new Rectangle(new PVector(0, 0), new PVector(width, height));

        for (Entry e : entries) {
            PVector size = e.element.dimensions();
            PVector point = PVector.add(screen.absolute(e.anchor), e.offset);
            PVector position = new PVector(
                point.x - size.x * e.pivot.x,
                point.y - size.y * e.pivot.y
            );
            
            e.bounds = new Rectangle(position, size);
        }
    }

    void drawToScreen(Camera camera) {
        if (!active) return;
        layout();

        for (Entry e : entries) {
            e.element.drawToScreen(camera, e.bounds);
        }
    }

    boolean handleMouse(PVector position) {
        for (Entry e : this.entries) {
            if (!e.bounds.contains(position)) continue;
            if (e.element.handleMouse(position, e.bounds)) {
                return true;
            }
        }
        return false;
    }
}

