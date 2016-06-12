package ;

import InputMap;
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

import luxe.Visual;

class MainGame extends Scene {
    var game_input:InputMap;
    var misc_input:InputMap;

    var stick_deadzone:Float = 30.0;

    var rotation_radius:Float = 200;
    var dots_radius:Float = 20;
    var ball_radius:Float = 20;

    var weakspot:Weakspot;

    var phys_engine:ShapePhysics;

    var ball_spawner:BallSpawner;

    var game_over:Bool = false;

    var game_over_text:Text;

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
        game_input.bind_gamepad_button('spawn_single_ball', 0);
        game_input.bind_gamepad_button('spawn_ball_series', 1);
        game_input.bind_gamepad_button('test_patterns_json', 2);
        
        game_input.on(InteractType.down, ondown);
        game_input.on(InteractType.change, onchange);

        misc_input = new InputMap();
        misc_input.bind_gamepad_button('start', 6); //start

        misc_input.on(InteractType.down, ondown);

        #if no_gamepad
            game_input.bind_key('spawn_ball_series', luxe.Input.Key.key_k); //:todo: for testing
            game_input.bind_mouse_range('mouse', InputMap.ScreenAxis.X, 0, 1, true, false, false);
            game_input.bind_mouse_range('mouse', InputMap.ScreenAxis.Y, 0, 1, true, false, false);
            misc_input.bind_key('start', luxe.Input.Key.enter); //:todo: for testing
        #end

        phys_engine = Luxe.physics.add_engine(ShapePhysics);
        add_walls();

        Patterns.phys_engine = phys_engine;
        Patterns.scene = this;

        weakspot = new Weakspot(Luxe.screen.mid.x, Luxe.screen.mid.y, 20, 200, 0.15, phys_engine, {
            depth:2,
            color:new ColorHSV(207, 0.64, 0.95, 1),
            scene:this
        });

        ball_spawner = new BallSpawner({
            color: new ColorHSV(5, 0.83, 0.93, 1.0),
            scene:this
        });

        //red color: ColorHSV(5, 0.93, 0.88, 1)
        //blue color: ColorHSV(207, 0.64, 0.95, 1)

        var circumference = make_circle_geom(rotation_radius, 5, Maths.radians(10), Maths.radians(10), {
            depth: 0,
            color:new Color(1, 1, 1, 0.5)
        });
        circumference.transform.pos.copy_from(Luxe.screen.mid);

        game_over_text = new Text({
            text:'Game Over! Press start to try again.',
            point_size:42 * Luxe.screen.device_pixel_ratio,
            align:TextAlign.center,
            align_vertical:TextAlign.center,
            pos:Luxe.screen.mid.clone(),
            depth:100
        });

        game_over_text.visible = false;

        Luxe.events.listen('Game.over', ongameover);

        super.init(null);
    }

    public function resources(_patterns_config_json:Dynamic) {
        Patterns.patterns_config = _patterns_config_json;
    }

    override public function reset() {
        super.reset();
        game_over = false;
        phys_engine.paused = false;
        game_input.listen();
        game_over_text.visible = false;
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
                reset();
                Luxe.events.fire('Game.restart');
            case 'test_patterns_json':
                var tl = Patterns.arc_shots(ball_spawner);
                // tl.add(new timeline.Trigger(0.75, function(_){trace('complete'); test_entity.destroy();}));

        }
    }

    function add_walls() {
        var shape = Polygon.rectangle(-10 - 2 * ball_radius, 0, 10, Luxe.screen.h + 4 * ball_radius, false);
        shape.tags.set('destroy_ball', '');
        phys_engine.statics.push(shape);
        shape = Polygon.rectangle(Luxe.screen.w + 2 * ball_radius, 0, 10, Luxe.screen.h + 4 * ball_radius, false);
        shape.tags.set('destroy_ball', '');
        phys_engine.statics.push(shape);
        shape = Polygon.rectangle(0, -10 - 2 * ball_radius, Luxe.screen.w + 4 * ball_radius, 10, false);
        shape.tags.set('destroy_ball', '');
        phys_engine.statics.push(shape);
        shape = Polygon.rectangle(0, Luxe.screen.h + 2 * ball_radius, Luxe.screen.w + 4 * ball_radius, 10, false);
        shape.tags.set('destroy_ball', '');
        phys_engine.statics.push(shape);
    }

        //_radius: radius around 0,0; _line_width: total width of segments, half inside radius, half outside
        //_line_theta: arc length of segments, in radians; _gap_theta: arc length of gaps between segmtens, in radians
    function make_circle_geom(_radius:Float, _line_width:Float, _line_theta:Float, _gap_theta:Float, _options:GeometryOptions):Geometry {
        _line_width /= 2; //Line width becomes the offset from the center line, so overall we get _line_width wide segments

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
}