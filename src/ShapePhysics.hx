package ;
import luxe.Physics.PhysicsEngine;
import luxe.collision.Collision;
import luxe.collision.shapes.Shape;
import luxe.collision.data.ShapeCollision;
import luxe.Vector;

class ShapePhysics extends PhysicsEngine {

    public var statics:Array<Shape>;
    public var dynamics:Array<DynamicShape>;

    public function new() {
        super();
        statics = [];
        dynamics = [];
    }

    override public function update() {
        if(paused) return;

        var dt = Luxe.physics.step_delta * Luxe.timescale;

        for(dyn in dynamics) {
            dyn.shape.position.add_xyz(dyn.vel.x * dt, dyn.vel.y * dt);
            
            var results = Collision.shapeWithShapes(dyn.shape, statics);
            for(result in results) {
                dyn.oncollision(result);
                if(dyn.destroyed) {
                    dynamics.remove(dyn);
                    break;
                }
            }
        }
    }
}

class DynamicShape {
    public var shape:Shape;
    public var vel:Vector;

    public var destroyed:Bool = false;

    public var oncollision:ShapeCollision->Void;

    public function new(_shape:Shape, ?_vel:Vector, ?_oncollision:ShapeCollision->Void) {
        shape = _shape;
        vel = _vel == null ? new Vector() : _vel;
        oncollision = _oncollision == null ? default_oncollision : _oncollision;
    }

    function default_oncollision(_coll:ShapeCollision):Void {}

    public function destroy():Void {
        destroyed = true;
    }
}