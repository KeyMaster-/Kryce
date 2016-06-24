package bullets;
import physics.ShapePhysics;
import physics.DynamicShape;
import luxe.Vector;
import luxe.options.VisualOptions;
import luxe.collision.shapes.Polygon;
import phoenix.geometry.Geometry;
import phoenix.geometry.Vertex;
import phoenix.Batcher.PrimitiveType;

class NormalBullet extends Bullet {
    static var length:Float = 40;
    static var height:Float = 24;

    public function new(_phys_shape:DynamicShape, _phys_engine:ShapePhysics, ?_options:VisualOptions) {
        _options = default_options(_options);
        _options.geometry = new Geometry({
            batcher:_options.batcher,
            primitive_type:PrimitiveType.triangle_strip
        });

        _options.geometry.add(new Vertex(new Vector(length / 2, 0), _options.color));
        _options.geometry.add(new Vertex(new Vector(-length / 2, height / 2), _options.color));
        _options.geometry.add(new Vertex(new Vector(-length / 2, -height / 2), _options.color));

        super(_phys_shape, _phys_engine, _options);
    }

    public static function get_collision_shape(_x:Float = 0, _y:Float = 0):Polygon {
        return new Polygon(_x, _y, [
            new Vector(length / 2, 0),
            new Vector(-length / 2, height / 2),
            new Vector(-length / 2, -height / 2)]);
    }
}