
import luxe.GameConfig;
import luxe.Input;
import luxe.Visual;
import luxe.Vector;
import luxe.Color;
import luxe.utils.Maths;
import luxe.options.GeometryOptions;
import phoenix.geometry.Geometry;
import phoenix.geometry.Vertex;
import phoenix.Batcher.PrimitiveType;
import InputMap;
import luxe.collision.shapes.Polygon;
import luxe.collision.shapes.Shape;
import luxe.collision.Collision;
import luxe.collision.data.ShapeCollision;
import luxe.resource.Resource.JSONResource;
import ShapePhysics;

class Main extends luxe.Game {

    var input:InputMap;

    var left_stick_circle:Visual;
    var right_stick_circle:Visual;

    var left_stick_pos:Vector;
    var right_stick_pos:Vector;

    var left_stick_base:Vector;
    var right_stick_base:Vector;

    var stick_deadzone:Float = 30.0;

    var rotation_radius:Float = 200;
    var dots_radius:Float = 20;
    var circle_radius:Float = 20;

    var phys_engine:ShapePhysics;

    var user_config:JSONResource;

    var ball_spawner:BallSpawner;

    override function config(config:GameConfig) {

        config.window.title = 'luxe game';
        config.window.width = 960;
        config.window.height = 640;
        config.window.fullscreen = false;

        var config_path = 'config.json';
        #if project_assets config_path = '../../../../../' + config_path; #end
        config.preload.jsons.push({id:config_path});

        return config;

    } //config

    override function ready() {

        user_config = Luxe.resources.json(#if project_assets '../../../../../' + #end 'config.json');

        input = new InputMap();
        input.bind_gamepad_range('left_stick', 0, -1, 1, true, false, false);
        input.bind_gamepad_range('left_stick', 1, -1, 1, true, false, false);
        input.bind_gamepad_range('right_stick', 2, -1, 1, true, false, false);
        input.bind_gamepad_range('right_stick', 3, -1, 1, true, false, false);
        // input.bind_gamepad_button('left_bumper', 9);
        // input.bind_gamepad_button('right_bumper', 10);
        input.bind_gamepad_button('reset', 4); //back
        input.bind_gamepad_button('start', 6); //start
        input.bind_gamepad_button('reload_config', 11); //dpad up

        input.on(InteractType.change, onchange);
        input.on(InteractType.down, ondown);

        left_stick_base = new Vector(Luxe.screen.w / 2, Luxe.screen.h / 2);
        right_stick_base = new Vector(Luxe.screen.w / 2, Luxe.screen.h / 2);

        left_stick_circle = new Visual({
            pos:left_stick_base.clone(),
            geometry:Luxe.draw.circle({
                r:dots_radius,
                x:0,
                y:0
            }),
            color:new ColorHSV(5, 0.93, 0.88, 1),
            depth:2
        });

        right_stick_circle = new Visual({
            pos:right_stick_base.clone(),
            geometry:Luxe.draw.circle({
                r:dots_radius,
                x:0,
                y:0
            }),
            color:new ColorHSV(207, 0.64, 0.95, 1),
            depth:3
        });

        left_stick_pos = new Vector();
        right_stick_pos = new Vector();

        var circumference = make_circle_geom(rotation_radius, 5, Maths.radians(10), Maths.radians(10), {
            depth: 0,
            color:new Color(1, 1, 1, 0.5)
        });
        circumference.transform.pos.copy_from(Luxe.screen.mid);

        phys_engine = Luxe.physics.add_engine(ShapePhysics);

        add_walls();

        ball_spawner = new BallSpawner(phys_engine);
        // Luxe.on(luxe.Ev.gamepaddown, function(_e:GamepadEvent){trace(_ e.button);});
    } //ready

    function add_walls() {
        var shape:Shape = Polygon.rectangle(-10 - 2 * circle_radius, 0, 10, Luxe.screen.h + 4 * circle_radius, false);
        shape.tags.set('destroy_ball', '');
        phys_engine.statics.push(shape);
        shape = Polygon.rectangle(Luxe.screen.w + 2 * circle_radius, 0, 10, Luxe.screen.h + 4 * circle_radius, false);
        shape.tags.set('destroy_ball', '');
        phys_engine.statics.push(shape);
        shape = Polygon.rectangle(0, -10 - 2 * circle_radius, Luxe.screen.w + 4 * circle_radius, 10, false);
        shape.tags.set('destroy_ball', '');
        phys_engine.statics.push(shape);
        shape = Polygon.rectangle(0, Luxe.screen.h + 2 * circle_radius, Luxe.screen.w + 4 * circle_radius, 10, false);
        shape.tags.set('destroy_ball', '');
        phys_engine.statics.push(shape);
    }

    override function onkeyup( e:KeyEvent ) {

        if(e.keycode == Key.escape) {
            Luxe.shutdown();
        }

    } //onkeyup

    override function update(dt:Float) {

    } //update

    function onchange(_e:InputEvent) {
        var stick_visual:Visual = null;
        var stick_pos:Vector = null;
        var stick_base:Vector = null;

        if(_e.name == 'left_stick') {
            stick_pos = left_stick_pos;
            stick_visual = left_stick_circle;
            stick_base = left_stick_base;
        }
        if(_e.name == 'right_stick') {
            stick_pos = right_stick_pos;
            stick_visual = right_stick_circle;
            stick_base = right_stick_base;
        }
        if(_e.gamepad_event.axis % 2 == 0) {
            stick_pos.x = _e.gamepad_event.value * rotation_radius;
        }
        else {
            stick_pos.y = _e.gamepad_event.value * rotation_radius;
        }

        stick_pos.length = trunc_abs(Maths.clamp(stick_pos.length, -rotation_radius, rotation_radius), stick_deadzone);
        stick_visual.pos.copy_from(stick_pos);
        stick_visual.pos.add(stick_base);
    }

    function ondown(_e:InputEvent) {
        switch(_e.name) {
            case 'reload_config':
                user_config.reload().then(function(res:JSONResource) {trace(res.asset.json); user_config = res;});
        }
    }

    inline function trunc_abs(_v:Float, _epsilon:Float):Float {
        return Math.abs(_v) < _epsilon ? 0 : _v;
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
} //Main
