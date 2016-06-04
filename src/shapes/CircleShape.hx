package shapes;
import phoenix.Batcher.PrimitiveType;
import phoenix.geometry.Geometry;
import phoenix.geometry.Vertex;
import luxe.Vector;
import luxe.options.GeometryOptions;

class CircleShape extends SingleGeomShape {
    static var vert_count:Int = 100;

    var _euler:Vector;

    public function new(_options:GeometryOptions) {
        _options.primitive_type = PrimitiveType.triangle_fan;
        super(_options);

        add(new Vertex(new Vector(0, 0), _options.color));

        var angle = 0.0;
        while(angle < Math.PI * 2) {
            add(new Vertex(new Vector(1 + Math.cos(angle), Math.sin(angle)), _options.color));
            angle += 2 * Math.PI / vert_count;
        }

        _euler = new Vector();
    }

    override public function reposition(left_pos:Vector, right_pos:Vector):Void {
        transform.pos.copy_from(left_pos);
        var diff = Vector.Subtract(right_pos, left_pos);
        _euler.set_xyz(0, 0, diff.angle2D);
        transform.rotation.setFromEuler(_euler);
        var scale = diff.length / 2;
        transform.scale.set_xy(scale, scale);
    }

    override public function duplicate():CircleShape {
        return new CircleShape(duplicate_options(options));
    }
}