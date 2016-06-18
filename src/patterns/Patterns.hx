package patterns;

import Ball;
import ShapePhysics;
import luxe.Visual;
import luxe.Vector;
import luxe.Scene;
import luxe.utils.Maths;
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

    public static function init() {
        patterns = ['driveby' => driveby, 
                    'arc_shots' => arc_shots,
                    'one_shot' => one_shot];
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
        
        transition(tl, _spawner, start_x * Luxe.screen.w, start_y * Luxe.screen.h, Math.PI);

        var seq_helper = new SequenceHelper(config.defaults.transition_t);

        windup_delta += Math.random() * start_linear_variance;

        tl.add(seq_helper.prop(_spawner.pos, 'y', timeline.easing.Quad.easeIn, windup).delta(windup_delta * Luxe.screen.h));
        tl.add(seq_helper.prop(_spawner.pos, 'y', timeline.easing.Linear.none, linear).delta(linear_delta * Luxe.screen.h));
        tl.add(seq_helper.prop(_spawner.pos, 'y', timeline.easing.Quad.easeOut, winddown).delta(winddown_delta * Luxe.screen.h));

        for(i in 0...shots) {
            var spawn_y:Float = ((start_y + windup_delta) * Luxe.screen.h) + i * (linear_delta * Luxe.screen.h) / shots;
            tl.add(new Trigger(config.defaults.transition_t + windup + i * (linear / shots), function(_) {
                spawn_ball(_spawner.pos.x, spawn_y, Math.PI, config.defaults.shotspeed);
            }));
        }

        return tl;
    }

    public static function arc_shots(_spawner:Visual) {
        var linear:Float = config.arc_shots.linear;
        var windup:Float = config.arc_shots.windup;
        var winddown:Float = config.arc_shots.winddown;
        var radius:Float = config.arc_shots.radius;
        var shots:Int = config.arc_shots.shots;
        var arc_time:Float = config.arc_shots.arc_time;
        var min_angle_delta:Float = config.arc_shots.min_angle_delta; //Minimum fraction of pi radians to move before shooting
        var max_angle_delta:Float = config.arc_shots.max_angle_delta; //Maximum ^


        var tl = get_timeline();

        var transition_time = transition_to_closest_arc(tl, _spawner, radius, radius);

        var seq_helper = new SequenceHelper(transition_time);
        
        var get_func = arc_get.bind(_spawner, Luxe.screen.mid);
        var set_func = arc_set.bind(_spawner, Luxe.screen.mid, radius, _);

        var delta_angle = Luxe.utils.random.sign() * Luxe.utils.random.float(min_angle_delta, max_angle_delta) * Math.PI;
        var delta_angle_t = arc_time * (Math.abs(delta_angle) / Math.PI);

        tl.add(seq_helper.func(get_func, set_func, timeline.easing.Quad.easeInOut, delta_angle_t).delta(delta_angle));
        tl.add(seq_helper.func(get_func, set_func, timeline.easing.Quad.easeIn, windup).delta(Math.PI / 20));
        tl.add(seq_helper.func(get_func, set_func, timeline.easing.Linear.none, linear).delta(Math.PI - Math.PI / 10));
        tl.add(seq_helper.func(get_func, set_func, timeline.easing.Quad.easeOut, winddown).delta(Math.PI / 20));

        tl.add(new Updater(function(_) {
            _spawner.radians = arc_get(_spawner, Luxe.screen.mid) + Math.PI;
        }, transition_time, seq_helper.cur_t));

        for(i in 0...shots) {
            tl.add(new Trigger(transition_time + delta_angle_t + windup + i * (linear / shots), spawn_ball_at_spawner.bind(_spawner, config.defaults.shotspeed)));
        }

        return tl;
    }

    public static function one_shot(_spawner:Visual) {
        var radius:Float = config.one_shot.radius;
        var arc_time:Float = config.one_shot.arc_time; //Seconds per pi radians (i.e. 1.0 means a PI radians turn should take 1 second)
        var min_angle_delta:Float = config.one_shot.min_angle_delta; //Minimum fraction of pi radians to rotate around.
        var tl = get_timeline();

        var transition_time = transition_to_closest_arc(tl, _spawner, radius, radius);

        var get_func = arc_get.bind(_spawner, Luxe.screen.mid);
        var set_func = arc_set.bind(_spawner, Luxe.screen.mid, radius, _);

        var angle_delta = Luxe.utils.random.sign() * Luxe.utils.random.float(min_angle_delta, 1.0) * Math.PI; //We want some minimum movement
        var tween_end_t = transition_time + (Math.abs(angle_delta) / Math.PI) * arc_time;
        tl.add(new FuncTween(get_func, set_func, transition_time, tween_end_t, timeline.easing.Quad.easeInOut).delta(angle_delta));
        tl.add(new PropTween(_spawner, 'radians', transition_time, tween_end_t, timeline.easing.Quad.easeInOut).delta(angle_delta));
        tl.add(new Trigger(tween_end_t, spawn_ball_at_spawner.bind(_spawner, config.defaults.shotspeed)));

        return tl;
    }

    public static function ongameover() {
        for(timeline in timelines) {
            Timelines.remove(timeline);
        }
        timelines = [];
    }

    static function get_timeline():Timeline {
        var tl = new Timeline();
        timelines.push(tl);
        Timelines.add(tl);
        return tl;
    }

    static function spawn_ball_at_spawner(_spawner:Visual, _shotspeed:Float, _t:Float) { //t parameter just here so binding is easier
        spawn_ball(_spawner.pos.x, _spawner.pos.y, _spawner.radians, _shotspeed);
    }

    static function spawn_ball(_x:Float, _y:Float, _radians:Float, _vel:Float) {
        return new Ball(_x, _y, 20, Math.cos(_radians) * _vel, Math.sin(_radians) * _vel, phys_engine, {scene:scene});
    }

    static function transition(_tl:Timeline, _spawner:Visual, _x:Float, _y:Float, _radians:Float, ?_ease:timeline.FloatTween.TweenFunc, ?_time:Null<Float>) {
        if(_ease == null) _ease = timeline.easing.Quad.easeInOut;
        if(_time == null) _time = config.defaults.transition_t;
        _tl.add(new PropTween(_spawner.pos, 'x', 0, _time, _ease).to(_x));
        _tl.add(new PropTween(_spawner.pos, 'y', 0, _time, _ease).to(_y));
        _tl.add(new PropTween(_spawner, 'radians', 0, _time, _ease).to(_radians));
    }

    static function transition_to_closest_arc(_tl:Timeline, _spawner:Visual, _radius:Float, _dist_scale:Float, ?_ease:timeline.FloatTween.TweenFunc) {
        var start_angle = arc_get(_spawner, Luxe.screen.mid);

        var target_pos = new Vector(Math.cos(start_angle) * _radius, Math.sin(start_angle) * _radius);
        target_pos.add(Luxe.screen.mid);

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