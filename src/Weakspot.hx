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

    var deadzone:Float;
    var move_radius:Float;

    var shape:Circle;

    public function new(_x:Float, _y:Float, _r:Float, _move_radius:Float, _deadzone:Float, _phys_engine:ShapePhysics, ?_options:VisualOptions) {
        if(_options == null) _options = {};

        base_pos = new Vector(_x, _y);
        relative_pos = new Vector(0, 0);

        move_radius = _move_radius;        
        deadzone = _deadzone;

        _options.name = 'Weakspot';
        _options.geometry = Luxe.draw.circle({
            r:_r,
            x:0,
            y:0
        });
        super(_options);

        pos.copy_from(base_pos);

        shape = new Circle(_x, _y, _r);
        shape.tags.set('destroy_ball', '');
        _phys_engine.statics.push(shape);
        _phys_engine.callbacks.set(shape, oncollision);
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

        relative_pos.length = trunc_abs(Maths.clamp(relative_pos.length, 0, 1), deadzone);
        pos.copy_from(relative_pos);
        pos.multiplyScalar(move_radius);
        pos.add(base_pos);
        shape.position.copy_from(pos);
    }

    inline function trunc_abs(_v:Float, _epsilon:Float):Float {
        return Math.abs(_v) < _epsilon ? 0 : _v;
    }
}