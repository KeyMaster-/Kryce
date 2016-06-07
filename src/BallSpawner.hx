package ;
import luxe.Visual;
import luxe.Vector;
import luxe.Color;
import luxe.options.VisualOptions;
import luxe.tween.Actuate;
import luxe.tween.easing.Quad;
import luxe.collision.shapes.Polygon;
import phoenix.Batcher.PrimitiveType;
import phoenix.geometry.Geometry;
import phoenix.geometry.Vertex;


class BallSpawner extends Visual {
    var phys_engine:ShapePhysics;

    var spawn_interval:Float = 2.0;
    var spawn_radius:Float = 400;
    var goal_radius:Float = 500;

    var spawn_vel:Float = 600;

    public function new(_phys_engine:ShapePhysics, ?_options:VisualOptions) {
        if(_options == null) _options = {};

        var geom = new Geometry({
            primitive_type:PrimitiveType.triangle_strip,
            batcher:Luxe.renderer.batcher
        });

        var geom_col = new ColorHSV(5, 0.83, 0.93, 1.0); //#EC3828
        var geom_width = 40;
        var geom_depth = 60;

        geom.add(new Vertex(new Vector(spawn_radius, -geom_width / 2), geom_col));
        geom.add(new Vertex(new Vector(spawn_radius, geom_width / 2), geom_col));
        geom.add(new Vertex(new Vector(spawn_radius + geom_depth, -geom_width / 2), geom_col));
        geom.add(new Vertex(new Vector(spawn_radius + geom_depth, geom_width / 2), geom_col));

        super({
            name:'BallSpawner',
            geometry:geom,
            pos:Luxe.screen.mid.clone(),
            color:geom_col
        });

        phys_engine = _phys_engine;

        Actuate.timer(spawn_interval).onComplete(spawn_ball);
    }

    function spawn_ball() {
        if(radians < 0) radians += 2 * Math.PI; //Dealing with negative starting angles for tweening becomes annoying
        var spawn_angle = radians;
        var ball = new Ball(pos.x + Math.cos(spawn_angle) * spawn_radius, pos.y + Math.sin(spawn_angle) * spawn_radius, 30, 0, 0, phys_engine);
        Luxe.timer.schedule(1, function() {
            ball.dyn_shape.vel.set_xy(Math.cos(spawn_angle + Math.PI) * spawn_vel, Math.sin(spawn_angle + Math.PI) * spawn_vel);
        });

        var next_radians = Math.random() * 2 * Math.PI;
        if(next_radians - radians > Math.PI) {
            next_radians -= 2 * Math.PI;
        } 
        Actuate.tween(this, spawn_interval, {radians: Math.random() * 2 * Math.PI})
        .ease(Quad.easeInOut)
        .onComplete(spawn_ball);
    }
}