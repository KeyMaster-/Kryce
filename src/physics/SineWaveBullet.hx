package physics;
import luxe.Vector;
import luxe.collision.shapes.Shape;

class SineWaveBullet extends DynamicShape {
    public var vel:Vector;
    public var magnitude:Float;
    public var period:Float;

    var vel_length:Float;

    var linear_pos:Vector;
    var normal:Vector;
    var dir_angle:Float;
    var time:Float = 0;

    public function new(_shape:Shape, _vel:Vector, _magnitude:Float, _period:Float) {
        super(_shape);
        vel = _vel;
        vel_length = vel.length;
        vel.listen_x = vel.listen_y = vel_update;
        magnitude = _magnitude;
        period = _period;

        dir_angle = vel.angle2D;

        linear_pos = _shape.position.clone();
        normal = _vel.clone();
        normal.normalize();
        normal.angle2D += Math.PI / 2;
    }

    function vel_update(_axis_val:Float) {
        vel_length = vel.length;
    }

    var prev_scalar:Float = 0;

    override public function update(_dt:Float) {
        linear_pos.add_xyz(vel.x * _dt, vel.y * _dt);
        shape.position.copy_from(linear_pos);

        time += _dt;

        var angle = 2 * Math.PI * (time / period);

        var scalar = Math.sin(angle);
        scalar *= magnitude;
        shape.position.add_xyz(normal.x * scalar, normal.y * scalar);

            //The atan2 part is the angle of the vector we moved by relative to the linear direction. We moed _dt * |vel| forward, while moving the difference in scalars normal to our direction
            //Add the direction angle to get our final rotation
        shape.rotation = (180 / Math.PI) * (dir_angle + Math.atan2(scalar - prev_scalar, _dt * vel_length));
        prev_scalar = scalar;
    }
}