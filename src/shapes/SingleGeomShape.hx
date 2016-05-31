package shapes;
import phoenix.geometry.Geometry;
import luxe.options.GeometryOptions;
import luxe.Vector;
import luxe.Log.*;

class SingleGeomShape extends Geometry {
    var options:GeometryOptions;

    public function new(_options:GeometryOptions) {
        if(_options.batcher == null) _options.batcher = Luxe.renderer.batcher;
        super(_options);
        options = _options;
    }

    public function show():Void {
        visible = true;
    }

    public function hide():Void {
        visible = false;
    }

    function duplicate_options(_options:GeometryOptions):GeometryOptions {
        return {
            id:_options.id,
            no_batcher_add:_options.no_batcher_add,
            color:_options.color == null ? null : _options.color.clone(),
            primitive_type:_options.primitive_type,
            clip_rect:_options.clip_rect == null ? null : _options.clip_rect.clone(),
            batcher:_options.batcher,
            immediate:_options.immediate,
            visible:_options.visible,
            depth:_options.depth,
            pos:_options.pos == null ? null : _options.pos.clone(),
            rotation:_options.rotation == null ? null : _options.rotation.clone(),
            scale:_options.scale == null ? null : _options.scale.clone(),
            origin:_options.origin == null ? null : _options.origin.clone()
        }
    }

    public function reposition(left_pos:Vector, right_pos:Vector):Void { }

    public function duplicate():SingleGeomShape {
        return new SingleGeomShape(duplicate_options(options));
    }
}