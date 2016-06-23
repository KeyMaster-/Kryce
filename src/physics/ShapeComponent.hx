package physics;
import physics.DynamicShape;
import luxe.Visual;
import luxe.Component;
import luxe.options.ComponentOptions;

class ShapeComponent extends Component {
    public var dyn_shape:DynamicShape;

    var vis:Visual;

    public function new(?_shape:DynamicShape) {
        super({name:'ShapeComponent'});
        dyn_shape = _shape;
    }

    override public function init() {
        vis = cast(entity, Visual);
    }

    override public function update(dt:Float) {
        vis.pos.copy_from(dyn_shape.shape.position);
        vis.rotation_z = dyn_shape.shape.rotation;
    }
}