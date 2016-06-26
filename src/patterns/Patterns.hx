package patterns;

import bullets.NormalBullet;
import bullets.HunterBullet;
import Laser;
import Weakspot;
import physics.ShapePhysics;
import physics.DynamicShape;
import luxe.Visual;
import luxe.Vector;
import luxe.Scene;
import luxe.utils.Maths;
import luxe.resource.Resource;
import timeline.Timeline;
import timeline.Timelines;
import timeline.PropTween;
import timeline.FuncTween;
import timeline.Trigger;
import timeline.Updater;

class Patterns {
    public static var patterns:Map<String, Visual->Timeline>;

    public static var config:Dynamic;
    public static var timelines:Array<Timeline> = [];

    public static var phys_engine:ShapePhysics;
    public static var scene:Scene;
    public static var weakspot:Weakspot;

    public static var muted:Bool = false;

    static var single_bullet_snd:AudioResource;
    static var laser_snd:AudioResource;
    static var spread_shot_snd:AudioResource;

    public static function init() {
        patterns = ['driveby' => driveby, 
                    'arc_shots' => arc_shots,
                    'one_shot' => one_shot,
                    'one_hunter' => one_hunter,
                    'spread_shot' => spread_shot,
                    'circ_shots' => circ_shots,
                    'laser' => laser];

        single_bullet_snd = Luxe.resources.audio('assets/sounds/single_bullet.wav');
        laser_snd = Luxe.resources.audio('assets/sounds/laser.wav');
        spread_shot_snd = Luxe.resources.audio('assets/sounds/spread_shot.wav');

    }

    public static function ongameover() {
        for(timeline in timelines) {
            Timelines.remove(timeline);
        }
        timelines = [];
    }

    public static function driveby(_spawner:Visual) {
        var linear:Float = config.driveby.linear;
        var windup:Float = config.driveby.windup; 
        var winddown:Float = config.driveby.winddown;
        var start_x:Float = config.driveby.start_x;
        var start_y:Float = config.driveby.start_y;
        var windup_delta:Float = config.driveby.windup_delta;
        var linear_delta:Float = config.driveby.linear_delta;
        var winddown_delta:Float = config.driveby.winddown_delta;
        var start_linear_variance:Float = config.driveby.start_linear_variance;
        var shots:Int = config.driveby.shots;

        var tl = get_timeline();
        
        start_y += Math.random() * start_linear_variance;

        transition(tl, _spawner, start_x, start_y, Math.PI);

        var seq_helper = new SequenceHelper(config.defaults.transition_t);

        tl.add(seq_helper.prop(_spawner.pos, 'y', timeline.easing.Quad.easeIn, windup).delta(windup_delta));
        tl.add(seq_helper.prop(_spawner.pos, 'y', timeline.easing.Linear.none, linear).delta(linear_delta));
        tl.add(seq_helper.prop(_spawner.pos, 'y', timeline.easing.Quad.easeOut, winddown).delta(winddown_delta));

        for(i in 0...shots) {
            var spawn_y:Float = start_y + windup_delta + i * (linear_delta) / shots;
            tl.add(new Trigger(config.defaults.transition_t + windup + i * (linear / shots), function(_) {
                spawn_normal_bullet(_spawner.pos.x, spawn_y, Math.PI, config.defaults.shotspeed);
                play_randomised(single_bullet_snd, _);
            }));
        }

        return tl;
    }

    public static function arc_shots(_spawner:Visual) {
        var linear:Float = config.arc_shots.linear;
        var winddown:Float = config.arc_shots.winddown;
        var radius:Float = config.arc_shots.radius;
        var shots:Int = config.arc_shots.shots;
        var arc_time:Float = config.arc_shots.arc_time;
        var min_angle_delta:Float = config.arc_shots.min_angle_delta; //Minimum fraction of pi radians to move before shooting
        var max_angle_delta:Float = config.arc_shots.max_angle_delta; //Maximum ^

        var tl = get_timeline();

        var transition_time = transition_to_closest_arc(tl, _spawner, radius, radius);

        var seq_helper = new SequenceHelper(transition_time);

        var get_func = arc_get.bind(_spawner, Main.mid);
        var set_func = arc_set.bind(_spawner, Main.mid, radius, _);

        var move_angle_delta:Float = get_rand_angle_delta(min_angle_delta, max_angle_delta);
        var move_duration:Float = get_arc_duration(move_angle_delta, arc_time);

        tl.add(seq_helper.func(get_func, set_func, timeline.easing.Quad.easeIn, move_duration).delta(move_angle_delta));
        tl.add(seq_helper.func(get_func, set_func, timeline.easing.Linear.none, linear).delta(Maths.sign(move_angle_delta) * (Math.PI - Math.PI / 20)));
        tl.add(seq_helper.func(get_func, set_func, timeline.easing.Back.easeOut, winddown).delta(Maths.sign(move_angle_delta) * (Math.PI / 20)));

        tl.add(new Updater(function(_) {
            _spawner.radians = arc_get(_spawner, Main.mid) + Math.PI;
        }, transition_time, seq_helper.cur_t));

        for(i in 0...shots) {
            tl.add(new Trigger(transition_time + move_duration + i * (linear / shots), spawn_normal_bullet_at_spawner.bind(_spawner, config.defaults.shotspeed)));
            tl.add(new Trigger(transition_time + move_duration + i * (linear / shots), play_randomised.bind(single_bullet_snd)));

        }

        return tl;
    }

    public static function one_shot(_spawner:Visual) {
        var radius:Float = config.one_shot.radius;
        var arc_time:Float = config.one_shot.arc_time; //Seconds per pi radians (i.e. 1.0 means a PI radians turn should take 1 second)
        var min_angle_delta:Float = config.one_shot.min_angle_delta; //Minimum fraction of pi radians to rotate around.
        var tl = get_timeline();

        var transition_time = transition_to_closest_arc(tl, _spawner, radius, radius);

        var tween_end_t = arc_to(tl, _spawner, radius, transition_time, arc_time, min_angle_delta);
        tl.add(new Trigger(tween_end_t, spawn_normal_bullet_at_spawner.bind(_spawner, config.defaults.shotspeed)));
        tl.add(new Trigger(tween_end_t, play_randomised.bind(single_bullet_snd)));

        return tl;
    }

    public static function one_hunter(_spawner:Visual) {
        var radius:Float = config.one_hunter.radius;
        var arc_time:Float = config.one_hunter.arc_time;
        var min_angle_delta:Float = config.one_hunter.min_angle_delta;
        var aim_time:Float = config.one_hunter.aim_time;

        var tl = get_timeline();

        var transition_time = transition_to_closest_arc(tl, _spawner, radius, radius);

        var tween_end_t = arc_to(tl, _spawner, radius, transition_time, arc_time, min_angle_delta);
        tl.add(new Trigger(tween_end_t, function(_) {
            spawn_hunter(_spawner.pos.x, _spawner.pos.y, config.defaults.shotspeed, aim_time);
            play_randomised(single_bullet_snd, _);
        }));

        return tl;
    }

    public static function spread_shot(_spawner:Visual) {
        var radius:Float = config.spread_shot.radius;
        var arc_time:Float = config.spread_shot.arc_time; //Seconds per pi radians (i.e. 1.0 means a PI radians turn should take 1 second)
        var min_angle_delta:Float = config.spread_shot.min_angle_delta; //Minimum fraction of pi radians to rotate around.
        var shots:Int = config.spread_shot.shots;
        var kickback_duration:Float = config.spread_shot.kickback_duration;
        var kickback_delta:Float = config.spread_shot.kickback_delta;
        var spread_angle_range:Float = config.spread_shot.spread_angle_range;
        spread_angle_range *= Math.PI;

        var tl = get_timeline();

        var transition_time = transition_to_closest_arc(tl, _spawner, radius, radius);

        var tween_end_t = arc_to(tl, _spawner, radius, transition_time, arc_time, min_angle_delta);

        for(i in 0...shots) {
            tl.add(new Trigger(tween_end_t, function(_) {
                var shot_angle = _spawner.radians - (spread_angle_range / 2) + i * (spread_angle_range / (shots - 1)); //shots - 1 can lead do div by 0 when shots = 1, but this is not supposed to only shoot once anyway (that's one_shot)
                spawn_normal_bullet(_spawner.pos.x, _spawner.pos.y, shot_angle, config.defaults.shotspeed);
            }));
        }
        tl.add(new Trigger(tween_end_t, play_randomised.bind(spread_shot_snd)));

        var radius_get_func = radius_get.bind(_spawner, Main.mid);
        var radius_set_func = radius_set.bind(_spawner, Main.mid, _);

        tl.add(new FuncTween(radius_get_func, radius_set_func, tween_end_t, tween_end_t + kickback_duration / 4, timeline.easing.Cubic.easeOut).delta(kickback_delta));
        tl.add(new FuncTween(radius_get_func, radius_set_func, tween_end_t + kickback_duration / 4, tween_end_t + kickback_duration, timeline.easing.Quart.easeOut).delta(-kickback_delta));

        return tl;
    }

    public static function circ_shots(_spawner:Visual) {
        var radius:Float = config.circ_shots.radius;
        var arc_time:Float = config.circ_shots.arc_time;
        var min_angle_delta:Float = config.circ_shots.min_angle_delta;
        var shots:Int = config.circ_shots.shots;
        var shot_interval:Float = config.circ_shots.shot_interval;
        var magnitude:Float = config.circ_shots.magnitude;
        var period:Float = config.circ_shots.period;
        var angle_correction_time:Float = config.circ_shots.angle_correction_time;
        var spread_angle_range:Float = config.circ_shots.spread_angle_range;
        spread_angle_range *= Math.PI;

        var tl = get_timeline();

        var transition_time = transition_to_closest_arc(tl, _spawner, radius, radius);

        var move_angle_delta = get_rand_angle_delta(min_angle_delta);
        var move_duration = get_arc_duration(move_angle_delta, arc_time);

        var tween_end_t = transition_time + move_duration;

        var get_func = arc_get.bind(_spawner, Main.mid);
        var set_func = arc_set.bind(_spawner, Main.mid, radius, _);

        tl.add(new FuncTween(get_func, set_func, transition_time, tween_end_t, timeline.easing.Quad.easeInOut).delta(move_angle_delta));
        tl.add(new PropTween(_spawner, 'radians', transition_time, tween_end_t, timeline.easing.Quad.easeInOut).delta(move_angle_delta - (spread_angle_range / 2))); //Tween to the start angle of the first shots

        tl.add(new PropTween(_spawner, 'radians', tween_end_t, tween_end_t + shot_interval * shots, timeline.easing.Linear.none).delta(spread_angle_range));

        for(i in 0...shots) {
            tl.add(new Trigger(tween_end_t + shot_interval * i, function(_) {
                // var shot_angle = _spawner.radians - (spread_angle_range / 2) + i * (spread_angle_range / (shots - 1));
                // spawn_sine_shot(_spawner.pos.x, _spawner.pos.y, shot_angle, config.defaults.shotspeed, magnitude, period);
                spawn_sine_shot(_spawner.pos.x, _spawner.pos.y, _spawner.radians, config.defaults.shotspeed, magnitude, period);
                play_randomised(single_bullet_snd, _);
            }));
        }

        tween_end_t += shot_interval * shots;

        tl.add(new PropTween(_spawner, 'radians', tween_end_t, tween_end_t + angle_correction_time, timeline.easing.Quad.easeInOut).delta(-spread_angle_range / 2));

        return tl;
    }

    public static function laser(_spawner:Visual) {
        var radius:Float = config.laser.radius;
        var arc_time:Float = config.laser.arc_time; //Seconds per pi radians (i.e. 1.0 means a PI radians turn should take 1 second)
        var min_angle_delta:Float = config.laser.min_angle_delta; //Minimum fraction of pi radians to rotate around.
        var width:Float = config.laser.width;
        var charge_time:Float = config.laser.charge_time;
        var laser_time:Float = config.laser.laser_time;
        var cooldown_time:Float = config.laser.cooldown_time;
        var scale_start:Float = config.laser.scale_start;
        var alpha_start:Float = config.laser.alpha_start;
        var alpha_end:Float = config.laser.alpha_end;
        var angle_correction_time:Float = config.laser.angle_correction_time;
        var spread_angle_range:Float = config.laser.spread_angle_range;
        spread_angle_range *= Math.PI;

        var tl = get_timeline();

        var transition_time = transition_to_closest_arc(tl, _spawner, radius, radius);

        var move_angle_delta = get_rand_angle_delta(min_angle_delta);
        var move_duration = get_arc_duration(move_angle_delta, arc_time);

        var laser_angle_change = Luxe.utils.random.float(-spread_angle_range / 2, spread_angle_range / 2);

        arc_to_specified(tl, _spawner, radius, move_angle_delta, transition_time, move_duration);

        var laser_obj:Laser = new Laser(_spawner.pos.x, _spawner.pos.y, width, _spawner.radians, phys_engine, {
            scene:scene,
            depth: 2,
            color: ColorMgr.laser});

        laser_obj.visible = false;

        var tween_end_t = transition_time + move_duration;

        tl.add(new Trigger(tween_end_t, function(_) {
            laser_obj.pos.set_xy(_spawner.pos.x, _spawner.pos.y);
            laser_obj.radians = _spawner.radians;
            laser_obj.dyn_shape.shape.position.copy_from(laser_obj.pos);
            laser_obj.dyn_shape.shape.rotation = laser_obj.radians * 180 / Math.PI;
            laser_obj.visible = true;
            if(!muted) Luxe.audio.play(laser_snd.source, 0.5);
        }));

        //Angle without the laser offset, so it will point to the center as expected by other patterns
        //Uses arc_get since _spawner.radians may still not point towards the center yet. We have our transition_to_closest_arc in the timeline, but it wasn't executed yet!
        var end_angle = arc_get(_spawner, Main.mid) + Math.PI + move_angle_delta; 
        tl.add(new PropTween(_spawner, 'radians', tween_end_t, tween_end_t + angle_correction_time, timeline.easing.Quad.easeInOut).to(end_angle));

        //The spawner is done now and can move on, he laser will tween and activate independently

        var laser_tl = get_timeline();
        laser_tl.add(new PropTween(laser_obj.scale, 'y', tween_end_t, tween_end_t + charge_time, timeline.easing.Cubic.easeOut).from(scale_start).to(1));
        laser_tl.add(new PropTween(laser_obj.scale, 'x', tween_end_t, tween_end_t + charge_time, timeline.easing.Cubic.easeOut).from(0).to(Main.screen_size));
        laser_tl.add(new PropTween(laser_obj.color, 'a', tween_end_t, tween_end_t + charge_time, timeline.easing.Cubic.easeOut).from(alpha_start).to(alpha_end));

        tween_end_t += charge_time;

        laser_tl.add(new Trigger(tween_end_t, function(_) {
            laser_obj.add_to_physics();
            laser_obj.color.a = 1;
        }));

        tween_end_t += laser_time;

        laser_tl.add(new PropTween(laser_obj.color, 'a', tween_end_t, tween_end_t + cooldown_time, timeline.easing.Cubic.easeInOut).to(0));

        tween_end_t += cooldown_time;

        laser_tl.add(new Trigger(tween_end_t, function(_) {
            laser_obj.destroy();
        }));

        
        return tl;
    }

    static function get_timeline():Timeline {
        var tl = new Timeline();
        timelines.push(tl);
        Timelines.add(tl);
        return tl;
    }

    static function spawn_normal_bullet_at_spawner(_spawner:Visual, _shotspeed:Float, _t:Float) { //t parameter just here so binding is easier
        spawn_normal_bullet(_spawner.pos.x, _spawner.pos.y, _spawner.radians, _shotspeed);
    }

    static function spawn_normal_bullet(_x:Float, _y:Float, _radians:Float, _speed:Float) {
        var shape = NormalBullet.get_collision_shape(_x, _y);
        var phys_shape = new physics.StraightLineDynamic(shape, new Vector(Math.cos(_radians) * _speed, Math.sin(_radians) * _speed));

        return make_bullet(phys_shape);
    }

    static function play_randomised(res:AudioResource, _) {
        if(muted) return;
        var handle = Luxe.audio.play(res.source, 0.5);
        Luxe.audio.pitch(handle, 1 + Luxe.utils.random.float(-0.1, 0.1));
    }

    static function spawn_hunter(_x:Float, _y:Float, _speed:Float, _tween_time:Float) {
        var shape = HunterBullet.get_collision_shape(_x, _y);
        var mid_diff = Main.mid.clone();
        mid_diff.subtract_xyz(_x, _y);
        var phys_shape = new physics.HunterDynamic(shape, weakspot, _speed, mid_diff.length, _tween_time);

        return new HunterBullet(phys_shape, phys_engine, {
            scene:scene,
            depth:2,
            color:ColorMgr.bullet
        });
    }

    static function spawn_sine_shot(_x:Float, _y:Float, _radians:Float, _vel:Float, _magnitude:Float, _period:Float) {
        var shape = NormalBullet.get_collision_shape(_x, _y);
        var phys_shape = new physics.SineWaveDynamic(shape, new Vector(Math.cos(_radians) * _vel, Math.sin(_radians) * _vel), _magnitude, _period);
        return make_bullet(phys_shape);
    }

    static function make_bullet(_phys_shape:DynamicShape):NormalBullet {
        return new NormalBullet(_phys_shape, phys_engine, {
            scene:scene,
            depth:2,
            color:ColorMgr.bullet
        });
    }

    static function transition(_tl:Timeline, _spawner:Visual, _x:Float, _y:Float, _radians:Float, ?_ease:timeline.FloatTween.TweenFunc, ?_time:Null<Float>) {
        if(_ease == null) _ease = timeline.easing.Quad.easeInOut;
        if(_time == null) _time = config.defaults.transition_t;
        _tl.add(new PropTween(_spawner.pos, 'x', 0, _time, _ease).to(_x));
        _tl.add(new PropTween(_spawner.pos, 'y', 0, _time, _ease).to(_y));
        _tl.add(new PropTween(_spawner, 'radians', 0, _time, _ease).to(_radians));
    }

    static function transition_to_closest_arc(_tl:Timeline, _spawner:Visual, _radius:Float, _dist_scale:Float, ?_ease:timeline.FloatTween.TweenFunc) {
        var start_angle = arc_get(_spawner, Main.mid);

        var target_pos = new Vector(Math.cos(start_angle) * _radius, Math.sin(start_angle) * _radius);
        target_pos.add(Main.mid);

        var diff = Vector.Subtract(target_pos, _spawner.pos);
        var transition_time = config.defaults.transition_t * Maths.clamp((diff.length / _dist_scale), 0, 1);
        
        if(transition_time != 0) transition(_tl, _spawner, target_pos.x, target_pos.y, start_angle + Math.PI, _ease, transition_time);
        return transition_time;
    }

    static function arc_set(_spawner:Visual, _center:Vector, _r:Float, _radians:Float) {
        _spawner.pos.x = _center.x + Math.cos(_radians) * _r;
        _spawner.pos.y = _center.y + Math.sin(_radians) * _r;
    }

    static function arc_get(_spawner:Visual, _center:Vector) {
        return Math.atan2(_spawner.pos.y - _center.y, _spawner.pos.x - _center.x);
    }

    static function arc_to(_tl:Timeline, _spawner:Visual, _radius:Float, _start_t:Float, _arc_time:Float, _min_angle_delta:Float, _max_angle_delta:Float = 1.0):Float {
        var angle_delta = get_rand_angle_delta(_min_angle_delta, _max_angle_delta);
        var duration = get_arc_duration(angle_delta, _arc_time);

        return arc_to_specified(_tl, _spawner, _radius, angle_delta, _start_t, duration);
    }

    static function arc_to_specified(_tl:Timeline, _spawner:Visual, _radius:Float, _angle_delta:Float, _start_t:Float, _duration:Float):Float {
        var tween_end_t = _start_t + _duration;

        var get_func = arc_get.bind(_spawner, Main.mid);
        var set_func = arc_set.bind(_spawner, Main.mid, _radius, _);

        _tl.add(new FuncTween(get_func, set_func, _start_t, tween_end_t, timeline.easing.Quad.easeInOut).delta(_angle_delta));
        _tl.add(new PropTween(_spawner, 'radians', _start_t, tween_end_t, timeline.easing.Quad.easeInOut).delta(_angle_delta));
        return tween_end_t;
    }

    static function get_rand_angle_delta(_min_angle_delta:Float, _max_angle_delta:Float = 1.0) {
        return Luxe.utils.random.sign() * Luxe.utils.random.float(_min_angle_delta, _max_angle_delta);
    }

    static function get_arc_duration(_angle_delta:Float, _arc_time:Float) {
         return (Math.abs(_angle_delta) / Math.PI) * _arc_time;
    }

    static function radius_get(_spawner:Visual, _center:Vector):Float {
        return Vector.Subtract(_spawner.pos, _center).length;
    }

    static function radius_set(_spawner:Visual, _center:Vector, _radius:Float):Void {
        var angle = arc_get(_spawner, _center);
        _spawner.pos.set_xy(Math.cos(angle) * _radius, Math.sin(angle) * _radius);
        _spawner.pos.add(_center);
    }
}

class SequenceHelper {
    public var cur_t:Float;

    public function new(_t:Float = 0) {
        cur_t = _t;
    }

    public function prop(_target:Dynamic, _prop:String, _easing:timeline.FloatTween.TweenFunc, _duration:Float):PropTween {
        var tween = new PropTween(_target, _prop, cur_t, cur_t + _duration, _easing);
        cur_t += _duration;
        return tween;
    }

    public function func(_get:Void->Float, _set:Float->Void, _easing:timeline.FloatTween.TweenFunc, _duration:Float):FuncTween {
        var tween = new FuncTween(_get, _set, cur_t, cur_t + _duration, _easing);
        cur_t += _duration;
        return tween;
    }
}