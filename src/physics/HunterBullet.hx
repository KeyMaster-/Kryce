package physics;
import Weakspot;
import luxe.Vector;
import luxe.collision.shapes.Shape;
import timeline.Timeline;
import timeline.Timelines;
import timeline.PropTween;
import timeline.Trigger;

class HunterBullet extends DynamicShape {
    public var speed:Float;
    public var radius:Float;
    public var aim_time:Float;

    static var bounce_max:Int = 2;

    var dir:Vector;
    var weakspot:Weakspot;
    var bounce_count:Int = 0;
    var cur_tl:Timeline = null;    
    var listen_id:String;

    public function new(_shape:Shape, _weakspot:Weakspot, _speed:Float, _radius:Float, _aim_time:Float) {
        super(_shape);
        weakspot = _weakspot;
        speed = _speed;
        radius = _radius;
        aim_time = _aim_time;

        dir = new Vector();
        aim_dir();
        shape.rotation = dir.angle2D * 180 / Math.PI;

        listen_id = Luxe.events.listen('Game.over', ongameover);

        tween_move();
    }

    function ongameover(_) {
        Timelines.remove(cur_tl);
    }

    function aim_dir() {
        dir.copy_from(weakspot.pos);
        dir.subtract(shape.position);
        dir.normalize();
    }

    function tween_aim() {
        var angle_delta = dir.angle2D * (180 / Math.PI) - shape.rotation;
        luxe.utils.Maths.wrap_angle(angle_delta, 0, 360);

        cur_tl = new Timeline();
        cur_tl.add(new PropTween(shape, 'rotation', 0, aim_time, timeline.easing.Quad.easeInOut).delta(angle_delta));
        
        bounce_count++;
        cur_tl.add(new Trigger(aim_time, function(_) {tween_move(bounce_count == bounce_max);}));

        Timelines.add(cur_tl);
    }

    function tween_move(exit:Bool = false) {
            //Intersect direction ray and circle
            //Code from http://stackoverflow.com/questions/1073336/circle-line-segment-collision-detection-algorithm
        var f = Vector.Subtract(shape.position, Main.mid);
        var a = dir.dot(dir);
        var b = 2 * f.dot(dir);
        var c = f.dot(f) - radius * radius;

        var discriminant = b * b - 4 * a * c;
        if(discriminant < 0) {
            trace('No circle intersections, something has gone very wrong!');
            return;
        }
        discriminant = Math.sqrt(discriminant);
        var t2 = (-b + discriminant) / (2 * a);

        cur_tl = new Timeline();

        var easing = exit ? timeline.easing.Quad.easeIn : timeline.easing.Quad.easeInOut;
        if(exit) t2 /= 2; //On exit, we do easIn only, which is half of easinout, so halve the distance we're going too to get hte same speed

        cur_tl.add(new PropTween(shape.position, 'x', 0, t2 / speed, easing).delta(dir.x * t2));
        cur_tl.add(new PropTween(shape.position, 'y', 0, t2 / speed, easing).delta(dir.y * t2));
        
        if(!exit) {
            cur_tl.add(new Trigger(t2 / speed, function(_) {
                aim_dir();
                tween_aim();
            }));
        }
        else {
            cur_tl.add(new PropTween(shape.position, 'x', t2 / speed, Main.screen_size / speed, timeline.easing.Linear.none).delta(dir.x * Main.screen_size));
            cur_tl.add(new PropTween(shape.position, 'y', t2 / speed, Main.screen_size / speed, timeline.easing.Linear.none).delta(dir.y * Main.screen_size));
        }
        Timelines.add(cur_tl);
    }

    override public function destroy() {
        super.destroy();
        Timelines.remove(cur_tl);
        Luxe.events.unlisten(listen_id); //We can unlisten here directly since our callback doesn't call destroy, so we're not editing listeners while iterating them
    }
}