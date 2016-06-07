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
    var ball_delay:Float;
    var spawn_radius:Float;
    var spawn_vel:Float;
    var ball_radius:Float;

    public function new(_spawn_interval:Float, _ball_delay:Float, _spawn_radius:Float, _spawn_vel:Float, _ball_radius:Float, _phys_engine:ShapePhysics, ?_options:VisualOptions) {
        spawn_interval = _spawn_interval;
        ball_delay = _ball_delay;
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

        // Actuate.timer(spawn_interval).onComplete(spawn_ball);

        var input_map = new InputMap();
        input_map.bind_gamepad_button('spawn_single_ball', 0);
        input_map.bind_gamepad_button('spawn_ball_series', 1);

        input_map.on(InputMap.InteractType.down, ondown);
    }

    function ondown(_e:InputMap.InputEvent) {
        switch(_e.name) {
            case 'spawn_single_ball':
                tween_to_angle(new_random_angle(), spawn_interval, spawn_ball.bind(ball_delay));
            case 'spawn_ball_series':

                var end_1:Float = radians + Math.PI / 20;
                var end_2:Float = end_1 + Math.PI / 2;
                var end_3:Float = end_2 + Math.PI / 20;

                var linear_time = 1.0;
                var balls = 10;

                Actuate.tween(this, 0.2, {radians: end_1}).onComplete(function() {
                    Actuate.tween(this, linear_time, {radians: end_2}).onComplete(function() {
                        Actuate.tween(this, 0.2, {radians: end_3}).ease(Quad.easeOut).onComplete(function() {
                            if(radians > 2 * Math.PI) {
                                radians -= 2 * Math.PI;
                            }
                        });
                    }).ease(luxe.tween.easing.Linear.easeNone);

                    Actuate.timer(linear_time / balls).repeat(balls).onRepeat(spawn_ball.bind(0));
                }).ease(Quad.easeIn);
        }
    }

    function spawn_ball(_ball_delay:Float) {
        if(radians < 0) radians += 2 * Math.PI; //Dealing with negative starting angles for tweening becomes annoying
        if(radians > 2 * Math.PI) radians -= 2 * Math.PI;
        var spawn_angle = radians;
        var ball = new Ball(pos.x + Math.cos(spawn_angle) * spawn_radius, pos.y + Math.sin(spawn_angle) * spawn_radius, ball_radius, 0, 0, phys_engine);
        Luxe.timer.schedule(_ball_delay, function() {
            ball.dyn_shape.vel.set_xy(Math.cos(spawn_angle + Math.PI) * spawn_vel, Math.sin(spawn_angle + Math.PI) * spawn_vel);
        });
    }

    function new_random_angle():Float {
        var next_radians = Math.random() * 2 * Math.PI;
        if(next_radians - radians > Math.PI) {
            next_radians -= 2 * Math.PI;
        }
        if(radians - next_radians > Math.PI) {
            next_radians += 2 * Math.PI;
        }
        return next_radians;
    }

    function tween_to_angle(_angle:Float, _interval:Float, ?_oncomplete:Void->Void):luxe.tween.actuators.GenericActuator.IGenericActuator {
        var actuator = Actuate.tween(this, _interval, {radians: _angle})
        .ease(Quad.easeInOut);
        if(_oncomplete != null) actuator.onComplete(_oncomplete);
        return actuator;
    }
}