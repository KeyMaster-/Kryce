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
    public static var patterns:Array<Visual->Timeline>;

    public static var config:Dynamic;
    public static var timelines:Array<Timeline> = [];

    public static var phys_engine:ShapePhysics;
    public static var scene:Scene;

    public static function init() {
        patterns = [driveby, arc_shots];
    }

    public static function driveby(_spawner:Visual) {
        var linear:Float = config.driveby.linear;
        var windup:Float = config.driveby.windup;
        var winddown:Float = config.driveby.winddown;
        var shots:Int = config.driveby.shots;

        var tl = new Timeline();
        
        transition(tl, _spawner, 0.75 * Luxe.screen.w, 0.1 * Luxe.screen.h, Math.PI);

        var seq_helper = new SequenceHelper(config.defaults.transition_t);

        tl.add(seq_helper.prop(_spawner.pos, 'y', timeline.easing.Quad.easeIn, windup).to(0.2 * Luxe.screen.h));
        tl.add(seq_helper.prop(_spawner.pos, 'y', timeline.easing.Linear.none, linear).to(0.8 * Luxe.screen.h));
        tl.add(seq_helper.prop(_spawner.pos, 'y', timeline.easing.Quad.easeOut, winddown).to(0.9 * Luxe.screen.h));

        for(i in 0...shots) {
            var spawn_y:Float = (0.2 * Luxe.screen.h) + i * (0.6 * Luxe.screen.h) / shots;
            tl.add(new Trigger(config.defaults.transition_t + windup + i * (linear / shots), function(_) {
                spawn_ball(_spawner.pos.x, spawn_y, Math.PI, config.defaults.shotspeed);
            }));
        }

        Timelines.add(tl);
        timelines.push(tl);
        return tl;
    }

    public static function arc_shots(_spawner:Visual) {
        var linear:Float = config.arc_shots.linear;
        var windup:Float = config.arc_shots.windup;
        var winddown:Float = config.arc_shots.winddown;
        var radius:Float = config.arc_shots.radius;
        var shots:Int = config.arc_shots.shots;
        var start_angle:Float = config.arc_shots.start_angle * (Math.PI / 180);

        var tl = new Timeline();

        var start_angle = arc_get(_spawner, Luxe.screen.mid);

        var target_pos = new Vector(Math.cos(start_angle) * radius, Math.sin(start_angle) * radius);
        target_pos.add(Luxe.screen.mid);

        var diff = Vector.Subtract(target_pos, _spawner.pos);
        var transition_time = config.defaults.transition_t * Maths.clamp((diff.length / radius), 0, 1);
        
        if(transition_time != 0) transition(tl, _spawner, Luxe.screen.mid.x + Math.cos(start_angle) * radius, Luxe.screen.mid.y + Math.sin(start_angle) * radius, start_angle + Math.PI, timeline.easing.Quad.easeInOut, transition_time);

        var seq_helper = new SequenceHelper(transition_time);
        
        var get_func = arc_get.bind(_spawner, Luxe.screen.mid);
        var set_func = arc_set.bind(_spawner, Luxe.screen.mid, radius, _);

        tl.add(seq_helper.func(get_func, set_func, timeline.easing.Quad.easeIn, windup).delta(Math.PI / 20));
        tl.add(seq_helper.func(get_func, set_func, timeline.easing.Linear.none, linear).delta(Math.PI - Math.PI / 10));
        tl.add(seq_helper.func(get_func, set_func, timeline.easing.Quad.easeOut, winddown).delta(Math.PI / 20));

        tl.add(new Updater(function(_) {
            _spawner.radians = arc_get(_spawner, Luxe.screen.mid) + Math.PI;
        }, transition_time, seq_helper.cur_t));

        for(i in 0...shots) {
            tl.add(new Trigger(transition_time + windup + i * (linear / shots), function(_) {
                spawn_ball(_spawner.pos.x, _spawner.pos.y, _spawner.radians, config.defaults.shotspeed);
            }));
        }

        Timelines.add(tl);
        timelines.push(tl);
        return tl;
    }

    public static function ongameover() {
        for(timeline in timelines) {
            Timelines.remove(timeline);
        }
        timelines = [];
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