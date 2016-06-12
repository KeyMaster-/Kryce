package patterns;

import Ball;
import ShapePhysics;
import luxe.Visual;
import luxe.Vector;
import luxe.Scene;
import timeline.Timeline;
import timeline.Timelines;
import timeline.PropTween;
import timeline.FuncTween;
import timeline.Trigger;

class Patterns {
    public static var patterns_config:Dynamic;
    public static var timelines:Array<Timeline> = [];

    public static var phys_engine:ShapePhysics;
    public static var scene:Scene;

    public static function driveby(_spawner:Visual) {
        _spawner.pos.x = 0.75 * Luxe.screen.w;
        _spawner.pos.y = 0.1 * Luxe.screen.h;

        var linear:Float = patterns_config.driveby.linear;
        var windup:Float = patterns_config.driveby.windup;
        var winddown:Float = patterns_config.driveby.winddown;
        var shots:Int = patterns_config.driveby.shots;

        var tl = new Timeline();
        var seq_helper = new SequenceHelper(0);
        
        tl.add(seq_helper.prop(_spawner.pos, 'y', timeline.easing.Quad.easeIn, windup).to(0.2 * Luxe.screen.h));
        tl.add(seq_helper.prop(_spawner.pos, 'y', timeline.easing.Linear.none, linear).to(0.8 * Luxe.screen.h));
        tl.add(seq_helper.prop(_spawner.pos, 'y', timeline.easing.Quad.easeOut, winddown).to(0.9 * Luxe.screen.h));

        // tl.add(new PropTween(_spawner, 'radians', 0, seq_helper.cur_t, timeline.easing.Sine.easeInOut).delta(Math.PI));

        for(i in 0...shots) {
            var spawn_y:Float = (0.2 * Luxe.screen.h) + i * (0.6 * Luxe.screen.h) / shots;
            tl.add(new Trigger(windup + i * (linear / shots), function(_) {
                spawn_ball(_spawner.pos.x, spawn_y, Math.PI, 600);
            }));
        }

        Timelines.add(tl);
        timelines.push(tl);
        return tl;
    }

    public static function arc_shots(_spawner:Visual) {
        var linear:Float = patterns_config.driveby.linear;
        var windup:Float = patterns_config.driveby.windup;
        var winddown:Float = patterns_config.driveby.winddown;
        var shots:Int = patterns_config.driveby.shots;

        var tl = new Timeline();
        var seq_helper = new SequenceHelper(0);
        
        var get_func = arc_get.bind(_spawner, Luxe.screen.mid);
        var set_func = arc_set.bind(_spawner, Luxe.screen.mid, 400, _);

        tl.add(seq_helper.func(get_func, set_func, timeline.easing.Quad.easeIn, windup).from(-Math.PI / 2).delta(Math.PI / 20));
        tl.add(seq_helper.func(get_func, set_func, timeline.easing.Linear.none, linear).delta(Math.PI - Math.PI / 10));
        tl.add(seq_helper.func(get_func, set_func, timeline.easing.Quad.easeOut, winddown).delta(Math.PI / 20));

        for(i in 0...shots) {
            tl.add(new Trigger(windup + i * (linear / shots), function(_) {
                var angle = arc_get(_spawner, Luxe.screen.mid);
                spawn_ball(_spawner.pos.x, _spawner.pos.y, angle + Math.PI, 600);
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