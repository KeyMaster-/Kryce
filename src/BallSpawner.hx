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
import patterns.Patterns;
import patterns.Phases;

class BallSpawner extends Visual {
    var cur_timer:snow.api.Timer;

    var phase_time:Float = 0.0;
    var phase_idx:Int = 0;
    public function new(?_options:VisualOptions) {

        if(_options == null) _options = {};
        _options.name = 'BallSpawner';

        var geom = new Geometry({
            primitive_type:PrimitiveType.triangle_strip,
            batcher:Luxe.renderer.batcher
        });

        var geom_size = 60;

        geom.add(new Vertex(new Vector(-geom_size / 2, -geom_size / 2), _options.color));
        geom.add(new Vertex(new Vector(-geom_size / 2, geom_size / 2), _options.color));
        geom.add(new Vertex(new Vector(geom_size / 2, -geom_size / 2), _options.color));
        geom.add(new Vertex(new Vector(geom_size / 2, geom_size / 2), _options.color));

        _options.geometry = geom;

        super(_options);

        Luxe.events.listen('Game.over', ongameover);
    }

    override public function update(_dt:Float) {
        phase_time += _dt;
        if(phase_idx < Phases.phases.length - 1 && phase_time >= Phases.phases[phase_idx + 1].start) {
            phase_idx++;
        }
    }

    override public function onreset() {
        pos.set_xy(Luxe.screen.mid.x, Luxe.screen.h * 0.1);
        radians = Math.PI / 2;
        phase_time = 0;
        phase_idx = 0;

        #if !manual_testing 
            cur_timer = Luxe.timer.schedule(1, new_pattern);
        #end
    }

    function ongameover(_) {
        #if !manual_testing
            cur_timer.stop();
        #end
    }

    function new_pattern() {
        var pattern = Phases.get_rand_pattern(Phases.phases[phase_idx]);
        var tl = Patterns.patterns.get(pattern)(this);
        cur_timer = Luxe.timer.schedule(tl.end_t, new_pattern);
    }
}