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

        var block = new GoalBlock(spawn_angle + (Math.random() - 0.5) * Math.PI, Math.PI / 8, goal_radius, phys_engine);

        ball.dyn_shape.shape.data = {
            goal:block
        };

        var next_radians = Math.random() * 2 * Math.PI;
        if(next_radians - radians > Math.PI) {
            next_radians -= 2 * Math.PI;
        } 
        Actuate.tween(this, spawn_interval, {radians: Math.random() * 2 * Math.PI})
        .ease(Quad.easeInOut)
        .onComplete(spawn_ball);
    }
}

class GoalBlock extends Visual {
    var collider:Polygon;
    var phys_engine:ShapePhysics;

    public function new(_angle:Float, _span:Float, _radius:Float, _phys_engine:ShapePhysics, ?_options:VisualOptions) {
        phys_engine = _phys_engine;
        if(_options == null) _options = {};

        var geom = new Geometry({
            primitive_type:PrimitiveType.triangle_strip,
            batcher:Luxe.renderer.batcher
        });

        var width = 2 * Math.sin(_span / 2) * _radius;
        var depth = 20;
        var geom_color = new ColorHSV(137, 0.59, 0.79);

        geom.add(new Vertex(new Vector(0, 0), geom_color));
        geom.add(new Vertex(new Vector(width, 0), geom_color));
        geom.add(new Vertex(new Vector(0, depth), geom_color));
        geom.add(new Vertex(new Vector(width, depth), geom_color));

        var block_pos = new Vector(Math.cos(_angle) * _radius, Math.sin(_angle) * _radius);
        block_pos.add(Luxe.screen.mid);
        block_pos.add_xyz(Math.cos(_angle + _span / 2) * depth, Math.sin(_angle + _span / 2) * depth);

        super({
            name:'GoalBlock',
            name_unique:true,
            pos:block_pos,
            color:geom_color,
            geometry:geom
        });

        radians = _angle + _span / 2 + Math.PI / 2;

        collider = Polygon.rectangle(block_pos.x, block_pos.y, width, depth, false);
        collider.tags.set('destroy_ball', '');
        collider.tags.set('goal', '');
        collider.rotation = radians * (180 / Math.PI);
        phys_engine.statics.push(collider);
    }

    override public function destroy(?_from_parent:Bool = false) {
        super.destroy(_from_parent);
        phys_engine.statics.remove(collider);
        collider.destroy();
    }
}