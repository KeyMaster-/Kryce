package ;
import ShapePhysics;
import luxe.Visual;
import luxe.Vector;
import luxe.options.VisualOptions;
import luxe.collision.shapes.Circle;
import luxe.collision.data.ShapeCollision;


class Ball extends Visual {
    public var dyn_shape:DynamicShape;
    var listen_id:String;

    public function new(_x:Float, _y:Float, _r:Float, _vx:Float, _vy:Float, _engine:ShapePhysics, ?_options:VisualOptions) {
        if(_options == null) _options = {};

        _options.name = 'Ball';
        _options.name_unique = true;
        _options.geometry = Luxe.draw.circle({
            x:0,
            y:0,
            r:_r
        });

        super(_options);

        dyn_shape = new DynamicShape(new Circle(_x, _y, _r), new Vector(_vx, _vy));
        _engine.callbacks.set(dyn_shape.shape, onshapecollision);
        add(new ShapeComponent(dyn_shape));

        transform.pos.set_xy(_x, _y);

        _engine.dynamics.push(dyn_shape);

        listen_id = Luxe.events.listen('Game.restart', game_restart);
    }

    function game_restart(_) {
        destroy();
    }

    function onshapecollision(_coll:ShapeCollision):Void {
        if(_coll.shape2.tags.exists('destroy_ball')) {
            destroy();
            return;
        }

        dyn_shape.shape.position.add(_coll.separation);

        var dot_product = dyn_shape.vel.dot(_coll.unitVector);

        if(dot_product < 0) dyn_shape.vel.subtract(_coll.unitVector.multiplyScalar(dot_product * 2));
    }

    override public function destroy(?_from_parent:Bool) {
        super.destroy();
        dyn_shape.destroy();
        Luxe.next(Luxe.events.unlisten.bind(listen_id)); //Delay removing the listener since otherwise we're modifying the listeners array while iterating it in events
    }
}