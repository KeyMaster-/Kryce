package shapes;
import phoenix.Batcher.PrimitiveType;
import phoenix.geometry.Geometry;
import phoenix.geometry.Vertex;
import luxe.Vector;
import luxe.options.GeometryOptions;

class SquareShape extends SingleGeomShape {
    static var sqrt_2:Float = 1.4142135623730951;

    public function new(_options:GeometryOptions) {
        _options.primitive_type = PrimitiveType.triangle_strip;
        super(_options);

        add(new Vertex(new Vector(0, 0), _options.color));
        add(new Vertex(new Vector(1, 0), _options.color));
        add(new Vertex(new Vector(0, 1), _options.color));
        add(new Vertex(new Vector(1, 1), _options.color));
    }

    override public function reposition(left_pos:Vector, right_pos:Vector):Void {
        transform.pos.copy_from(left_pos);
        var diff = Vector.Subtract(right_pos, left_pos);
        // transform.rotation.setFromEuler(new Vector(0, 0, diff.angle2D));
        // transform.scale.set_xy(diff.length, diff.length);
        transform.rotation.setFromEuler(new Vector(0, 0, diff.angle2D - Math.PI / 4)); // Correct by 45° since we're connecting the diagonal points
        var scale = diff.length / sqrt_2; //Diagonal of a unit square is sqrt2, so divide by that to get actual scale value
        transform.scale.set_xy(scale, scale);
    }

    override public function duplicate():SquareShape {
        return new SquareShape(duplicate_options(options));
    }
}