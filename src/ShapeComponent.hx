package ;
import ShapePhysics.DynamicShape;
import luxe.Component;
import luxe.options.ComponentOptions;

class ShapeComponent extends Component {
    public var dyn_shape:DynamicShape;

    public function new(?_shape:DynamicShape) {
        super({name:'ShapeComponent'});
        dyn_shape = _shape;
    }

    override public function update(dt:Float) {
        entity.pos.copy_from(dyn_shape.shape.position);
    }
}