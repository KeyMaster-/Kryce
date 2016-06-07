package ;
import luxe.Physics.PhysicsEngine;
import luxe.collision.Collision;
import luxe.collision.shapes.Shape;
import luxe.collision.data.ShapeCollision;
import luxe.Vector;

class ShapePhysics extends PhysicsEngine {

    public var statics:Array<Shape>;
    public var dynamics:Array<DynamicShape>;

        //Register a callback for a certain shape. Gets called for each collision result between a dynamic and a static
        //In the shape collision, shape1 is always the dynamic involved, and shape2 always the static
    public var callbacks:Map<Shape, ShapeCollision->Void>;

    public function new() {
        super();
        statics = [];
        dynamics = [];
        callbacks = new Map();
        DynamicShape.phys_engine = this;
    }

    override public function update() {
        if(paused) return;

        var dt = Luxe.physics.step_delta * Luxe.timescale;

        for(dyn in dynamics) {
            dyn.shape.position.add_xyz(dyn.vel.x * dt, dyn.vel.y * dt);
            
            var results = Collision.shapeWithShapes(dyn.shape, statics);
            for(result in results) {
                if(callbacks.exists(dyn.shape)) callbacks.get(dyn.shape)(result);
                if(callbacks.exists(result.shape2)) callbacks.get(result.shape2)(result);
                if(dyn.destroyed) {
                    dynamics.remove(dyn);
                    break;
                }
            }
        }
    }
}

class DynamicShape {
    @:allow(ShapePhysics)
    static var phys_engine:ShapePhysics;

    public var shape:Shape;
    public var vel:Vector;

    public var destroyed:Bool = false;

    public function new(_shape:Shape, ?_vel:Vector) {
        shape = _shape;
        vel = _vel == null ? new Vector() : _vel;
    }


    public function destroy():Void {
        phys_engine.callbacks.remove(shape);
        destroyed = true;
    }
}