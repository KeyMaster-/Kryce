package shapes;
import phoenix.Batcher.PrimitiveType;
import phoenix.geometry.Geometry;
import phoenix.geometry.Vertex;
import luxe.Vector;
import luxe.options.GeometryOptions;
import luxe.collision.shapes.Polygon;

class LineShape extends SingleGeomShape {
    public var collider:Polygon;

    public function new(_options:GeometryOptions) {
        _options.primitive_type = PrimitiveType.triangle_strip;
        super(_options);

        add(new Vertex(new Vector(0, -5), color));
        add(new Vertex(new Vector(0, 5), color));
        add(new Vertex(new Vector(1, -5), color));
        add(new Vertex(new Vector(1, 5), color));

        collider = new Polygon(transform.pos.x, transform.pos.y, [new Vector(0, -5), new Vector(0, 5), new Vector(1, -5), new Vector(1, 5)]);
    }

    override public function reposition(left_pos:Vector, right_pos:Vector):Void {
        transform.pos.copy_from(left_pos);
        var diff = Vector.Subtract(right_pos, left_pos);
        transform.rotation.setFromEuler(new Vector(0, 0, diff.angle2D));
        transform.scale.x = diff.length;

        collider.position.copy_from(left_pos);
        collider.rotation = diff.angle2D * 180 / Math.PI;
        collider.scaleX = diff.length;
    }

    override public function duplicate():LineShape {
        return new LineShape(duplicate_options(options));
    }
}