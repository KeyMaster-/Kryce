package ;
import physics.ShapePhysics;
import physics.StraightLineBullet;
import physics.DynamicShape;
import physics.ShapeComponent;
import luxe.Visual;
import luxe.Vector;
import luxe.options.VisualOptions;
import luxe.collision.shapes.Shape;
import luxe.collision.data.ShapeCollision;

import phoenix.geometry.Geometry;
import phoenix.geometry.Vertex;
import phoenix.Batcher.PrimitiveType;
import luxe.collision.shapes.Polygon;
import physics.SineWaveBullet;

class Bullet extends Visual {
    public var phys_shape:DynamicShape;
    var listen_id:String;

    static var length:Float = 40;
    static var height:Float = 24;

    public function new(_phys_shape:DynamicShape, _phys_engine:ShapePhysics, ?_options:VisualOptions) {
        if(_options == null) _options = {};

        _options.name = 'Bullet';
        _options.name_unique = true;

        if(_options.batcher == null) _options.batcher = Luxe.renderer.batcher;

        _options.geometry = new Geometry({
            batcher:_options.batcher,
            primitive_type:PrimitiveType.triangle_strip
        });

        _options.geometry.add(new Vertex(new Vector(length / 2, 0), _options.color));
        _options.geometry.add(new Vertex(new Vector(-length / 2, height / 2), _options.color));
        _options.geometry.add(new Vertex(new Vector(-length / 2, -height / 2), _options.color));

        super(_options);

        phys_shape = _phys_shape;

        _phys_engine.callbacks.set(phys_shape.shape, onshapecollision);
        add(new ShapeComponent(phys_shape));

        _phys_engine.dynamics.push(phys_shape);

        listen_id = Luxe.events.listen('Game.restart', game_restart);
    }

    public static function get_collision_shape(_x:Float = 0, _y:Float = 0):Shape {
        return new Polygon(_x, _y, [
            new Vector(length / 2, 0),
            new Vector(-length / 2, height / 2),
            new Vector(-length / 2, -height / 2)]);
    }

    function game_restart(_) {
        destroy();
    }

    function onshapecollision(_coll:ShapeCollision):Void {
        if(_coll.shape2.tags.exists('destroy_ball')) {
            destroy();
            return;
        }
    }

    override public function destroy(?_from_parent:Bool) {
        super.destroy();
        phys_shape.destroy();
        Luxe.next(Luxe.events.unlisten.bind(listen_id)); //Delay removing the listener since otherwise we're modifying the listeners array while iterating it in events
    }
}