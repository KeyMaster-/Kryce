package ;
import ShapePhysics.DynamicShape;
import luxe.Vector;
import luxe.Visual;
import luxe.options.VisualOptions;
import luxe.utils.Maths;
import luxe.collision.shapes.Circle;
import luxe.collision.data.ShapeCollision;

class Weakspot extends Visual {
    var base_pos:Vector;
    var relative_pos:Vector;

    var move_radius:Float;

    var dyn_shape:DynamicShape;
    var collision_vis:Visual;

    public function new(_x:Float, _y:Float, _r:Float, _move_radius:Float, _phys_engine:ShapePhysics, ?_options:VisualOptions) {
        if(_options == null) _options = {};

        base_pos = new Vector(_x, _y);
        relative_pos = new Vector(0, 0);

        move_radius = _move_radius;

        dyn_shape = new DynamicShape(new Circle(_x, _y, _r), new Vector(0, 0));
        // _phys_engine.dynamics.push(dyn_shape);
        _phys_engine.weakspot = dyn_shape;
        _phys_engine.callbacks.set(dyn_shape.shape, oncollision);

        _options.name = 'weakspot_collision';
        _options.geometry = Luxe.draw.circle({
            r:_r,
            x:0,
            y:0
        });

        collision_vis = new Visual(_options);
        collision_vis.add(new ShapeComponent(dyn_shape));

        _options.name = 'weakspot';
        _options.geometry = Luxe.draw.circle({
            r:_r / 2,
            x:0,
            y:0
        });

        if(_options.color != null) _options.color.a = 0.5;
        super(_options);

        pos.copy_from(base_pos);
    }

    override public function onreset() {
        axis_change(0, 0);
        axis_change(1, 0);
    }

    override public function update(_dt:Float) {
        dyn_shape.vel.copy_from(pos);
        dyn_shape.vel.subtract(dyn_shape.shape.position);
        if(dyn_shape.vel.length < 5) {
            dyn_shape.shape.position.copy_from(pos);
            dyn_shape.vel.set_xy(0, 0);
        }
        else {
            dyn_shape.vel.length = 400;
        }
        // dyn_shape.vel.length = Math.min(dyn_shape.vel.length, 300);

    }

    function oncollision(coll:ShapeCollision) {
        Luxe.events.fire('Game.over');
    }

    public function axis_change(_axis:Int, _value:Float) {
        if(_axis == 0) {
            relative_pos.x = _value;
        }
        else {
            relative_pos.y = _value;
        }

        relative_pos.length = Maths.clamp(relative_pos.length, 0, 1);
        pos.copy_from(relative_pos);
        pos.multiplyScalar(move_radius);
        pos.add(base_pos);
    }

    inline function trunc_abs(_v:Float, _epsilon:Float):Float {
        return Math.abs(_v) < _epsilon ? 0 : _v;
    }
}