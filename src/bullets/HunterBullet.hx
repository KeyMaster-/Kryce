package bullets;
import physics.ShapePhysics;
import physics.DynamicShape;
import luxe.Vector;
import luxe.options.VisualOptions;
import luxe.collision.shapes.Polygon;
import phoenix.geometry.Geometry;
import phoenix.geometry.Vertex;
import phoenix.Batcher.PrimitiveType;

class HunterBullet extends Bullet {
    static var length:Float = 40;
    static var height:Float = 24;
    static var back_height:Float = 16;
    static var back_length:Float = 14;

    var second_geom:Geometry;

    public function new(_phys_shape:DynamicShape, _phys_engine:ShapePhysics, ?_options:VisualOptions) {
        _options = default_options(_options);
        _options.geometry = new Geometry({
            batcher:_options.batcher,
            primitive_type:PrimitiveType.triangles
        });


        _options.geometry.add(new Vertex(new Vector(length / 2, 0), _options.color));
        _options.geometry.add(new Vertex(new Vector(-length / 2, height / 2), _options.color));
        _options.geometry.add(new Vertex(new Vector(-length / 2, -height / 2), _options.color));

        super(_phys_shape, _phys_engine, _options);

        second_geom = new Geometry({
            batcher:_options.batcher,
            primitive_type:PrimitiveType.triangle_strip,
            depth:_options.depth + 0.1
        });

        second_geom.add(new Vertex(new Vector(-(length / 2) - back_length, 0), ColorMgr.hunter_second));
        second_geom.add(new Vertex(new Vector(-length / 2, (back_height / 2)), ColorMgr.hunter_second));
        second_geom.add(new Vertex(new Vector(-length / 2, -(back_height / 2)), ColorMgr.hunter_second));
        second_geom.add(new Vertex(new Vector(-(length / 2) + back_length, 0), ColorMgr.hunter_second));
        
        second_geom.transform.parent = transform;
    }

    public static function get_collision_shape(_x:Float = 0, _y:Float = 0):Polygon {
        return new Polygon(_x, _y, [
            new Vector(length / 2, 0),
            new Vector(-length / 2, height / 2),
            new Vector(-length / 2, (back_height / 2)),
            new Vector(-(length / 2) - back_length, 0),
            new Vector(-length / 2, -(back_height / 2)),
            new Vector(-length / 2, -height / 2)]);
    }

    override public function destroy(?_from_parent:Bool) {
        super.destroy(_from_parent);
        second_geom.drop();
    }
}