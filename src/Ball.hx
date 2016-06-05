package ;
import luxe.Visual;
import luxe.Vector;
import luxe.collision.shapes.Circle;
import luxe.collision.data.ShapeCollision;
import ShapePhysics;

class Ball extends Visual {
    var dyn_shape:DynamicShape;

    public function new(_x:Float, _y:Float, _r:Float, _vx:Float, _vy:Float, _engine:ShapePhysics) {
        super({
            name:'ball',
            name_unique:true,
            geometry:Luxe.draw.circle({
                x:0,
                y:0,
                r:_r
            })
        });

        dyn_shape = new DynamicShape(new Circle(_x, _y, _r), new Vector(_vx, _vy), onshapecollision);
        add(new ShapeComponent(dyn_shape));

        _engine.dynamics.push(dyn_shape);
    }

    function onshapecollision(_coll:ShapeCollision):Void {
        if(_coll.shape2.tags.exists('wall')) {
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
    }
}