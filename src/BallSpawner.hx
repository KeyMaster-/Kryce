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
    var cur_timer:snow.api.Timer;

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

    override public function onreset() {
        pos.set_xy(Luxe.screen.mid.x, Luxe.screen.h * 0.1);
        radians = Math.PI / 2;
        cur_timer = Luxe.timer.schedule(1, new_pattern);
    }

    function ongameover(_) {
        cur_timer.stop();
    }

    function new_pattern() {
        var pattern_idx = Math.floor(Math.random() * patterns.Patterns.patterns.length);
        var tl = patterns.Patterns.patterns[pattern_idx](this);
        cur_timer = Luxe.timer.schedule(tl.end_t, new_pattern);
    }
}