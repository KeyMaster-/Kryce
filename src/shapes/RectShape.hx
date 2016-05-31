package shapes;
import phoenix.Batcher.PrimitiveType;
import phoenix.geometry.Geometry;
import phoenix.geometry.Vertex;
import luxe.Vector;
import luxe.options.GeometryOptions;

class RectShape extends SingleGeomShape implements TwoPointForm {
    public function new(_options:GeometryOptions) {
        _options.primitive_type = PrimitiveType.triangle_strip;
        super(_options);

        add(new Vertex(new Vector(0, 0), _options.color));
        add(new Vertex(new Vector(1, 0), _options.color));
        add(new Vertex(new Vector(0, 1), _options.color));
        add(new Vertex(new Vector(1, 1), _options.color));
    }

    public function reposition(left_pos:Vector, right_pos:Vector):Void {
        transform.pos.copy_from(left_pos);
        var diff = Vector.Subtract(right_pos, left_pos);
        transform.scale.set_xy(diff.x, diff.y);
    }
}