package physics;
import luxe.Vector;
import luxe.collision.shapes.Shape;

class StraightLineBullet extends DynamicShape {
    public var vel:Vector;
    public function new(_shape:Shape, ?_vel:Vector) {
        super(_shape);
        vel = _vel == null ? new Vector() : _vel;
    }

    override public function update(_dt:Float) {
        shape.position.add_xyz(_dt * vel.x, _dt * vel.y);
    }
}