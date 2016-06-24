package ;

import InputMap;
import physics.ShapePhysics;
import luxe.Scene;
import luxe.Color;
import luxe.Vector;
import luxe.Text;
import luxe.utils.Maths;
import luxe.collision.shapes.Polygon;
import luxe.options.GeometryOptions;
import phoenix.geometry.Geometry;
import phoenix.geometry.Vertex;
import phoenix.Batcher.PrimitiveType;
import patterns.Patterns;
import patterns.Phases;

import luxe.Visual;

class MainGame extends Scene {
    var game_input:InputMap;
    var misc_input:InputMap;

    var rotation_radius:Float = 0.3125;
    var dots_radius:Float = 15.625;
    var ball_radius:Float = 15.625;

    var weakspot:Weakspot;

    var phys_engine:ShapePhysics;

    var ball_spawner:AttackSpawner;

    var game_over:Bool = false;

    var game_over_text:Text;

    var timer:Timer;

    public function new() {
        super('MainGame');
    }

    override public function init(_) {
        game_input = new InputMap();
        game_input.bind_gamepad_range('left_stick', 0, -1, 1, true, false, false);
        game_input.bind_gamepad_range('left_stick', 1, -1, 1, true, false, false);
        game_input.bind_gamepad_range('right_stick', 2, -1, 1, true, false, false);
        game_input.bind_gamepad_range('right_stick', 3, -1, 1, true, false, false);
        // game_input.bind_gamepad_button('left_bumper', 9);
        // game_input.bind_gamepad_button('right_bumper', 10);
        game_input.bind_gamepad_button('reset', 4); //back

        #if manual_testing
            game_input.bind_gamepad_button('one_shot', 0);
            game_input.bind_gamepad_button('driveby', 1);
            game_input.bind_gamepad_button('arc_shots', 2);
            game_input.bind_gamepad_button('spread_shot', 3);
            game_input.bind_gamepad_button('laser', 9);
            game_input.bind_gamepad_button('circ_shots', 10);
            game_input.bind_gamepad_button('one_hunter', 13);
        #end
        
        game_input.on(InteractType.down, ondown);
        game_input.on(InteractType.change, onchange);

        misc_input = new InputMap();
        misc_input.bind_gamepad_button('start', 6); //start

        misc_input.on(InteractType.down, ondown);

        #if no_gamepad
            game_input.bind_mouse_range('mouse', InputMap.ScreenAxis.X, 0, 1, true, false, false);
            game_input.bind_mouse_range('mouse', InputMap.ScreenAxis.Y, 0, 1, true, false, false);
            misc_input.bind_key('start', luxe.Input.Key.enter); //:todo: for testing
        #end

        phys_engine = Luxe.physics.add_engine(ShapePhysics);
        add_walls();

        weakspot = new Weakspot(Main.screen_size / 2, Main.screen_size / 2, ball_radius, rotation_radius * Main.screen_size / 2, phys_engine, {
            depth:1,
            color:ColorMgr.player,
            scene:this
        });

        ball_spawner = new AttackSpawner({
            color:ColorMgr.spawner,
            scene:this,
            depth:3
        });

        Patterns.phys_engine = phys_engine;
        Patterns.scene = this;
        Patterns.weakspot = weakspot;
        Patterns.init();

        //red color: ColorHSV(5, 0.93, 0.88, 1)
        //blue color: ColorHSV(207, 0.64, 0.95, 1)

        var circumference = make_circle_geom(rotation_radius * Main.screen_size / 2, 0.025, Maths.radians(10), Maths.radians(10), {
            depth: 0,
            color:new Color(1, 1, 1, 0.5)
        });
        circumference.transform.pos.copy_from(Main.mid);

        // test_scale_transform = new luxe.Transform();

        // circumference.transform.parent = test_scale_transform;

        var font = Luxe.resources.font('assets/fonts/kelsonsans_regular/kelsonsans_regular.fnt');

        game_over_text = new Text({
            font:font,
            sdf:true,
            text:'Game Over! Press start to try again.',
            point_size:32 * Luxe.screen.device_pixel_ratio,
            align:TextAlign.center,
            align_vertical:TextAlign.center,
            pos:new Vector(Main.screen_size / 2, Main.screen_size * 0.2),
            depth:100
        });

        game_over_text.visible = false;

        Luxe.draw.box({
            x:0,
            y:0,
            w:Main.screen_size,
            h:Main.screen_size,
            depth: -1,
            color:ColorMgr.background
        });

        var mask = draw_rings_mask({
            depth: 4
        });
        mask.transform.pos.copy_from(Main.mid);

        timer = new Timer(rotation_radius, this);

        Luxe.events.listen('Game.over', ongameover);

        super.init(null);
    }

    override public function update(_dt:Float) {
        if(game_over) return;

        super.update(_dt);
        timer.update(_dt);
    }

    public function resources(_user_config:Dynamic, _patterns_config:Dynamic, _phases_config:Dynamic) {
        Patterns.config = _patterns_config;
        Phases.parse_info(_phases_config);
        timer.resources(_user_config.timer);
    }

    override public function reset() {
        super.reset();
        game_over = false;
        phys_engine.paused = false;
        game_input.listen();
        game_over_text.visible = false;
        timer.cur_t = 0;
    }

    function ongameover(_) {
        Patterns.ongameover();
        phys_engine.paused = true;
        game_over = true;
        game_input.unlisten();
        game_over_text.visible = true;
    }

    function onchange(_e:InputEvent) {
        if(_e.name == 'left_stick') {
            weakspot.axis_change(_e.gamepad_event.axis, _e.gamepad_event.value);
        }
        #if no_gamepad
            if(_e.name == 'mouse') {
                var mouse_pos = Vector.Subtract(_e.mouse_event.pos, Luxe.screen.mid);
                Maths.clamp(mouse_pos.length, 0, rotation_radius);
                mouse_pos.length /= rotation_radius;
                weakspot.axis_change(0, mouse_pos.x);
                weakspot.axis_change(1, mouse_pos.y);
            }
        #end
    }

    function ondown(_e:InputEvent) {
        switch(_e.name) {
            case 'start':
                if(game_over) {
                    reset();
                    Luxe.events.fire('Game.restart');
                }

        #if manual_testing
            case 'arc_shots':
                Patterns.arc_shots(ball_spawner);
            case 'driveby':
                Patterns.driveby(ball_spawner);
            case 'one_shot':
                Patterns.one_shot(ball_spawner);
            case 'one_hunter':
                Patterns.one_hunter(ball_spawner);
            case 'spread_shot':
                Patterns.spread_shot(ball_spawner);
            case 'laser':
                Patterns.laser(ball_spawner);
            case 'circ_shots':
                Patterns.circ_shots(ball_spawner);
        #end
        }
    }

    function add_walls() {

            //Outer destroying walls
        var shape = Polygon.rectangle(-10 - 2 * ball_radius, 0, 10, Main.screen_size + 4 * ball_radius, false);
        shape.tags.set('destroy_ball', '');
        phys_engine.statics.push(shape);
        shape = Polygon.rectangle(Main.screen_size + 2 * ball_radius, 0, 10, Main.screen_size + 4 * ball_radius, false);
        shape.tags.set('destroy_ball', '');
        phys_engine.statics.push(shape);
        shape = Polygon.rectangle(0, -10 - 2 * ball_radius, Main.screen_size + 4 * ball_radius, 10, false);
        shape.tags.set('destroy_ball', '');
        phys_engine.statics.push(shape);
        shape = Polygon.rectangle(0, Main.screen_size + 2 * ball_radius, Main.screen_size + 4 * ball_radius, 10, false);
        shape.tags.set('destroy_ball', '');
        phys_engine.statics.push(shape);
    }

        //_radius: radius around 0,0; _line_width: total width of segments as fraction of radius, half inside radius, half outside
        //_line_theta: arc length of segments, in radians; _gap_theta: arc length of gaps between segmtens, in radians
    function make_circle_geom(_radius:Float, _line_width:Float, _line_theta:Float, _gap_theta:Float, _options:GeometryOptions):Geometry {
        _line_width /= 2; //Line width becomes the offset from the center line, so overall we get _line_width wide segments
        _line_width *= _radius;

        if(_options.batcher == null) _options.batcher = Luxe.renderer.batcher;
        _options.primitive_type = PrimitiveType.triangles;

        var circle = new Geometry(_options);

        var angle = 0.0;
        var angle_end = 0.0;

        while(2 * Math.PI - angle > 0.0005) {
            angle_end = angle + _line_theta;
            var start_unit = new Vector(Math.cos(angle), Math.sin(angle));
            var end_unit = new Vector(Math.cos(angle_end), Math.sin(angle_end));

            var inner_start = start_unit.clone().multiplyScalar(_radius - _line_width);
            var outer_start = start_unit.multiplyScalar(_radius + _line_width);
            var inner_end = end_unit.clone().multiplyScalar(_radius - _line_width);
            var outer_end = end_unit.multiplyScalar(_radius + _line_width);

            circle.add(new Vertex(inner_start, _options.color));
            circle.add(new Vertex(outer_start, _options.color));
            circle.add(new Vertex(inner_end, _options.color));
            circle.add(new Vertex(outer_start, _options.color));
            circle.add(new Vertex(outer_end, _options.color));
            circle.add(new Vertex(inner_end, _options.color));

            angle = angle_end + _gap_theta;
        }

        return circle;
    }

        //Using the repeated rotation algorithm from this page: http://slabode.exofire.net/circle_draw.shtml
    function draw_rings_mask(_options:GeometryOptions):Geometry {
        if(_options.batcher == null) _options.batcher = Luxe.renderer.batcher;
        _options.primitive_type = PrimitiveType.triangles;
        var geom = new Geometry(_options);

        var radii = [rotation_radius * Main.screen_size / 2, rotation_radius * Main.screen_size, rotation_radius * 3 * Main.screen_size / 2, Main.screen_size];
        var alphas = ColorMgr.ring_alphas;

        //Use the second-to-last radius for step calculation as it's the last one visible.
        //Using the same step count for all radii since otherwise there are small gaps between the bands
        var steps = Luxe.utils.geometry.segments_for_smooth_circle(radii[radii.length - 2]); 
        
        for(i in 1...radii.length) {
            var theta = 2 * Math.PI / steps;

            var c = Math.cos(theta);
            var s = Math.sin(theta);
            var tmp:Float = 0;

            var x_inner = radii[i - 1];
            var y_inner = 0.0;
            var x_outer = radii[i];
            var y_outer = 0.0;

            var inner = new Vector(x_inner, y_inner);
            var outer = new Vector(x_outer, y_outer);

            var color = new Color(0, 0, 0, alphas[i - 1]);

            for(n in 0...steps) {
                geom.add(new Vertex(inner, color));
                geom.add(new Vertex(outer, color));

                //rotate the outer point
                tmp = x_outer;
                x_outer = c * x_outer - s * y_outer;
                y_outer = s * tmp + c * y_outer;

                outer = new Vector(x_outer, y_outer);
                geom.add(new Vertex(outer, color)); //First tri complete

                geom.add(new Vertex(inner, color));
                geom.add(new Vertex(outer, color));
                
                //rotate inner point
                tmp = x_inner;
                x_inner = c * x_inner - s * y_inner;
                y_inner = s * tmp + c * y_inner;

                inner = new Vector(x_inner, y_inner);
                geom.add(new Vertex(inner, color)); //Second tri complete
            } //for steps
        } //for all radii

        return geom;
    } //draw_rings_mask
}