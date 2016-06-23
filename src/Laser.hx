package ;
import physics.ShapePhysics;
import physics.DynamicShape;
import luxe.Visual;
import luxe.Vector;
import luxe.options.VisualOptions;
import luxe.collision.shapes.Polygon;
import phoenix.geometry.Geometry;
import phoenix.geometry.Vertex;
import phoenix.Batcher.PrimitiveType;

class Laser extends Visual {
    var phys_engine:ShapePhysics;
    public var dyn_shape:DynamicShape; //Technically doesn't have to be a dynamic shape, but it's easier this way since as a static it wouldn't collide with the weakspot (another static)
    var listen_id:String;

    public function new(_x:Float, _y:Float, _width:Float, _angle:Float, _phys_engine:ShapePhysics, ?_options:VisualOptions) {
        if(_options == null) _options = {};

        _options.name = 'Laser';
        _options.name_unique = true;

        var geom = new Geometry({
            primitive_type:PrimitiveType.triangle_strip,
            batcher:Luxe.renderer.batcher
        });

        var sqrt_2 = Math.sqrt(2);
            //Using sqrt(2) for x values so that even if this was spawned in the center, th laser would cover the whole diagonal
        geom.add(new Vertex(new Vector(-sqrt_2, -_width / 2), _options.color));
        geom.add(new Vertex(new Vector(-sqrt_2, _width / 2), _options.color));
        geom.add(new Vertex(new Vector(sqrt_2, -_width / 2), _options.color));
        geom.add(new Vertex(new Vector(sqrt_2, _width / 2), _options.color));

        _options.geometry = geom;

        super(_options);
        
        pos.set_xy(_x, _y);

        radians = _angle;

        var shape = new Polygon(_x, _y, [
            new Vector(0, -_width / 2),
            new Vector(Main.screen_size * 2, -_width / 2),
            new Vector(Main.screen_size * 2, _width / 2),
            new Vector(0, _width / 2)]);
        shape.rotation = _angle * 180 / Math.PI;
        shape.position.copy_from(pos);

        dyn_shape = new DynamicShape(shape);

        listen_id = Luxe.events.listen('Game.restart', game_restart);

        phys_engine = _phys_engine;
    }

    function game_restart(_) {
        destroy();
    }

    public function add_to_physics() {
        phys_engine.dynamics.push(dyn_shape);
    }

    override public function destroy(?_from_parent:Bool) {
        super.destroy();
        dyn_shape.destroy();
        Luxe.next(Luxe.events.unlisten.bind(listen_id));
    }
}