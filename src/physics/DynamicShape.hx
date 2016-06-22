package physics;
import physics.ShapePhysics;
import luxe.collision.shapes.Shape;

class DynamicShape {
    @:allow(physics.ShapePhysics)
    static var phys_engine:ShapePhysics;

    public var shape:Shape;

    public var destroyed:Bool = false;

    public function new(_shape:Shape) {
        shape = _shape;
    }

    public function update(_dt:Float) {} //To be overridden 

    public function destroy():Void {
        phys_engine.callbacks.remove(shape);
        destroyed = true;
    }
}