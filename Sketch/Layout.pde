// Konstanten für (z.B.) `anchor` oder `pivot`
static final PVector TOP_LEFT = new PVector(0, 0);
static final PVector TOP_CENTRE = new PVector(0.5, 0);
static final PVector TOP_RIGHT = new PVector(1, 0);
static final PVector CENTRE_LEFT = new PVector(0, 0.5);
static final PVector CENTRE_CENTRE = new PVector(0.5, 0.5);
static final PVector CENTRE_RIGHT = new PVector(1, 0.5);
static final PVector BOTTOM_LEFT = new PVector(0, 1);
static final PVector BOTTOM_CENTRE = new PVector(0.5, 1);
static final PVector BOTTOM_RIGHT = new PVector(1, 1);

class Rectangle {
    final PVector position, size;

    Rectangle(PVector position, PVector size) {
        this.position = position.copy();
        this.size = size.copy();
    }

    // Ein "relativer" `PVector` - von (0, 0) bis (1, 1) - beschreibt eine Position
    // innerhalb des `Rectangle`. Die `absolute` Methode verwandelt ihn in einen tatsächlichen
    // Positions-`PVector`. Behält den Koordinatenraum (Screen/World) des Rectangles.
    PVector absolute(PVector relative) {
        return new PVector(
            this.position.x + this.size.x * relative.x,
            this.position.y + this.size.y * relative.y
        );
    }

    // Umkehrung der absolute() Methode.
    // Wenn this.size.x == 0 oder this.size.y == 0, teilt relative() durch 0, wodurch ein
    // PVector mit mindestens einem NaN zurückgegeben wird. Contains funktioniert trotdem, da
    // vergleiche mit NaN immer false ergeben.
    PVector relative(PVector absolute) {
        if (this.size.x == 0) return null;

        return new PVector(
            (absolute.x - this.position.x) / this.size.x,
            (absolute.y - this.position.y) / this.size.y
        );
    }

    // Gibt an, ob der absolute PVector in diesem Rectangle enthalten ist.
    boolean contains(PVector absolute) {
        // Der Punkt ist tatsächlich innerhalb des Rectangles, wenn beide Koordinaten
        // (x und y) als relativer Vektor zwischen 0 und 1 liegen.
        PVector relative = this.relative(absolute);

        return relative.x >= 0 && relative.x <= 1
            && relative.y >= 0 && relative.y <= 1;
    }
}