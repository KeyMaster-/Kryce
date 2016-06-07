package ;
import luxe.Visual;
import luxe.Vector;
import luxe.Color;
import luxe.options.VisualOptions;
import luxe.utils.Maths;
import luxe.tween.Actuate;
import luxe.tween.easing.Quad;
import luxe.collision.shapes.Polygon;
import phoenix.Batcher.PrimitiveType;
import phoenix.geometry.Geometry;
import phoenix.geometry.Vertex;


class BallSpawner extends Visual {
    var phys_engine:ShapePhysics;

    var spawn_interval:Float;
    var spawn_radius:Float;
    var spawn_vel:Float;
    var ball_radius:Float;

    public function new(_spawn_interval:Float, _spawn_radius:Float, _spawn_vel:Float, _ball_radius:Float, _phys_engine:ShapePhysics, ?_options:VisualOptions) {
        spawn_interval = _spawn_interval;
        spawn_radius = _spawn_radius;
        spawn_vel = _spawn_vel;
        ball_radius = _ball_radius;

        if(_options == null) _options = {};
        _options.name = 'BallSpawner';
        _options.pos = Luxe.screen.mid.clone();

        var geom = new Geometry({
            primitive_type:PrimitiveType.triangle_strip,
            batcher:Luxe.renderer.batcher
        });

        var geom_width = 40;
        var geom_depth = 60;

        geom.add(new Vertex(new Vector(spawn_radius, -geom_width / 2), _options.color));
        geom.add(new Vertex(new Vector(spawn_radius, geom_width / 2), _options.color));
        geom.add(new Vertex(new Vector(spawn_radius + geom_depth, -geom_width / 2), _options.color));
        geom.add(new Vertex(new Vector(spawn_radius + geom_depth, geom_width / 2), _options.color));

        _options.geometry = geom;

        super(_options);

        phys_engine = _phys_engine;

        Actuate.timer(spawn_interval).onComplete(spawn_ball);
    }

    function spawn_ball() {
        if(radians < 0) radians += 2 * Math.PI; //Dealing with negative starting angles for tweening becomes annoying
        if(radians > 2 * Math.PI) radians -= 2 * Math.PI;
        var spawn_angle = radians;
        var ball = new Ball(pos.x + Math.cos(spawn_angle) * spawn_radius, pos.y + Math.sin(spawn_angle) * spawn_radius, ball_radius, 0, 0, phys_engine);
        Luxe.timer.schedule(1, function() {
            ball.dyn_shape.vel.set_xy(Math.cos(spawn_angle + Math.PI) * spawn_vel, Math.sin(spawn_angle + Math.PI) * spawn_vel);
        });

        var next_radians = Math.random() * 2 * Math.PI;
        if(next_radians - radians > Math.PI) {
            next_radians -= 2 * Math.PI;
        }
        if(radians - next_radians > Math.PI) {
            next_radians += 2 * Math.PI;
        }
        Actuate.tween(this, spawn_interval, {radians: next_radians})
        .ease(Quad.easeInOut)
        .onComplete(spawn_ball);
    }
}