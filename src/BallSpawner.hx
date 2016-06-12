package ;
import luxe.Scene;
import luxe.Visual;
import luxe.Vector;
import luxe.Color;
import luxe.options.VisualOptions;
import luxe.utils.Maths;
import luxe.collision.shapes.Polygon;
import phoenix.Batcher.PrimitiveType;
import phoenix.geometry.Geometry;
import phoenix.geometry.Vertex;

import timeline.Timeline;
import timeline.Timelines;
import timeline.PropTween;
import timeline.Trigger;

class BallSpawner extends Visual {
    public function new(?_options:VisualOptions) {

        if(_options == null) _options = {};
        _options.name = 'BallSpawner';

        var geom = new Geometry({
            primitive_type:PrimitiveType.triangle_strip,
            batcher:Luxe.renderer.batcher
        });

        var geom_size = 60;

        // geom.add(new Vertex(new Vector(spawn_radius, -geom_width / 2), _options.color));
        // geom.add(new Vertex(new Vector(spawn_radius, geom_width / 2), _options.color));
        // geom.add(new Vertex(new Vector(spawn_radius + geom_depth, -geom_width / 2), _options.color));
        // geom.add(new Vertex(new Vector(spawn_radius + geom_depth, geom_width / 2), _options.color));

        geom.add(new Vertex(new Vector(-geom_size / 2, -geom_size / 2), _options.color));
        geom.add(new Vertex(new Vector(-geom_size / 2, geom_size / 2), _options.color));
        geom.add(new Vertex(new Vector(geom_size / 2, -geom_size / 2), _options.color));
        geom.add(new Vertex(new Vector(geom_size / 2, geom_size / 2), _options.color));

        _options.geometry = geom;

        super(_options);
    }

    // function ondown(_e:InputMap.InputEvent) {
    //     switch(_e.name) {
    //         case 'spawn_single_ball':
    //             tween_to_angle(new_random_angle(), spawn_interval, function(_) {spawn_ball(ball_delay);});
    //         case 'spawn_ball_series':

    //             var linear_time = 1.0;
    //             var balls = 10;

    //             var tl = new Timeline();
    //             tl.add(new PropTween(this, 'radians', 0, 0.2, timeline.easing.Quad.easeIn).delta(Math.PI / 20));
    //             tl.add(new PropTween(this, 'radians', 0.2, 0.2 + linear_time, timeline.easing.Linear.none).delta(Math.PI / 2));
    //             tl.add(new PropTween(this, 'radians', 0.2 + linear_time, 0.2 + linear_time + 0.2, timeline.easing.Quad.easeOut).delta(Math.PI / 20));

    //             for(i in 0...balls) {
    //                 tl.add(new Trigger(0.2 + (i + 1) * (linear_time / balls), function(_) {
    //                     spawn_ball(0);
    //                 }));
    //             }

    //             Timelines.add(tl);
    //             timelines.push(tl);
    //     }
    // }

    // function spawn_ball(_ball_delay:Float) {
    //     if(radians < 0) radians += 2 * Math.PI; //Dealing with negative starting angles for tweening becomes annoying
    //     if(radians > 2 * Math.PI) radians -= 2 * Math.PI;
    //     var spawn_angle = radians;
    //     var ball = new Ball(pos.x + Math.cos(spawn_angle) * spawn_radius, pos.y + Math.sin(spawn_angle) * spawn_radius, ball_radius, 0, 0, phys_engine, {
    //         scene:this.scene
    //     });
    //     Luxe.timer.schedule(_ball_delay, function() {
    //         ball.dyn_shape.vel.set_xy(Math.cos(spawn_angle + Math.PI) * spawn_vel, Math.sin(spawn_angle + Math.PI) * spawn_vel);
    //     });
    // }

    // function new_random_angle():Float {
    //     var next_radians = Math.random() * 2 * Math.PI;
    //     if(next_radians - radians > Math.PI) {
    //         next_radians -= 2 * Math.PI;
    //     }
    //     if(radians - next_radians > Math.PI) {
    //         next_radians += 2 * Math.PI;
    //     }
    //     return next_radians;
    // }

    // function tween_to_angle(_angle:Float, _interval:Float, ?_oncomplete:Float->Void) {
    //     var tl = new Timeline();
    //     tl.add(new PropTween(this, 'radians', 0, _interval, timeline.easing.Quad.easeInOut).to(_angle));
    //     if(_oncomplete != null) tl.add(new Trigger(_interval, _oncomplete));
    //     Timelines.add(tl);
    // }
}