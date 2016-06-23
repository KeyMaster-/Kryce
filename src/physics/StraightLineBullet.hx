package physics;
import luxe.Vector;
import luxe.collision.shapes.Shape;

class StraightLineBullet extends DynamicShape {
    public var vel:Vector;
    public function new(_shape:Shape, ?_vel:Vector) {
        super(_shape);
        vel = _vel == null ? new Vector() : _vel;
        shape.rotation = (180 / Math.PI) * vel.angle2D;
    }

    override public function update(_dt:Float) {
        shape.position.add_xyz(_dt * vel.x, _dt * vel.y);
    }
}