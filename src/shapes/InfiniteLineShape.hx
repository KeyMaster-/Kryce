package shapes;
import phoenix.Batcher.PrimitiveType;
import phoenix.geometry.Geometry;
import phoenix.geometry.Vertex;
import luxe.Vector;
import luxe.options.GeometryOptions;

class InfiniteLineShape extends SingleGeomShape {
    public function new(_options:GeometryOptions) {
        _options.primitive_type = PrimitiveType.triangle_strip;
        super(_options);

        add(new Vertex(new Vector(-Luxe.screen.w, -5), _options.color));
        add(new Vertex(new Vector(-Luxe.screen.w, 5), _options.color));
        add(new Vertex(new Vector(Luxe.screen.w, -5), _options.color));
        add(new Vertex(new Vector(Luxe.screen.w, 5), _options.color));
    }

    override public function reposition(left_pos:Vector, right_pos:Vector):Void {
        transform.pos.copy_from(left_pos);
        var diff = Vector.Subtract(right_pos, left_pos);
        transform.rotation.setFromEuler(new Vector(0, 0, diff.angle2D));
    }

    override public function duplicate():InfiniteLineShape {
        return new InfiniteLineShape(duplicate_options(options));
    }
}