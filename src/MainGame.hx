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
import overlays.MenuOverlay;
import overlays.GameOverOverlay;

class MainGame extends Scene {
    var game_input:InputMap;
    var misc_input:InputMap;

    var rotation_radius:Float = 0.3125;
    var ball_radius:Float = 15.625;

    var weakspot:Weakspot;

    var phys_engine:ShapePhysics;

    var attack_spawners:Array<AttackSpawner> = [];

    var game_running:Bool = false;

    var game_time:Float;

    var timer_display:TimerDisplay;

    var selected_stick:String = 'left_stick';

    var menu_overlay:MenuOverlay;
    var game_over_overlay:GameOverOverlay;

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
        
        #if manual_testing
            game_input.bind_gamepad_button('one_shot', 0);
            game_input.bind_gamepad_button('driveby', 1);
            game_input.bind_gamepad_button('arc_shots', 2);
            game_input.bind_gamepad_button('spread_shot', 3);
            game_input.bind_gamepad_button('laser', 9);
            game_input.bind_gamepad_button('circ_shots', 10);
            game_input.bind_gamepad_button('one_hunter', 13);
            game_input.bind_gamepad_button('advance_time', 12);
        #end
        
        game_input.on(InteractType.down, ondown);
        game_input.on(InteractType.change, onchange);

        misc_input = new InputMap();
        misc_input.bind_gamepad_button('start', 6); //start
        misc_input.bind_gamepad_button('back', 4); //back

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

        Patterns.phys_engine = phys_engine;
        Patterns.scene = this;
        Patterns.weakspot = weakspot;
        Patterns.init();

        make_overlays();

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

        timer_display = new TimerDisplay(rotation_radius, this);

        Luxe.events.listen('Game.over', ongameover);

        super.init(null);
    }

    function make_overlays() {
        game_over_overlay = new GameOverOverlay();
        game_over_overlay.set_visible(false, false);

        menu_overlay = new MenuOverlay();
    }

    override public function update(_dt:Float) {
        if(!game_running) return;

        super.update(_dt);
        game_time += _dt;
        timer_display.update(game_time);

        if(game_time > attack_spawners.length * Phases.total_duration) {
            attack_spawners.push(create_spawner());
        }
    }

    public function resources(_user_config:Dynamic, _patterns_config:Dynamic, _phases_config:Dynamic) {
        Patterns.config = _patterns_config;
        Phases.parse_info(_phases_config);
        timer_display.resources(_user_config.timer);
        menu_overlay.resources(_user_config.menu_overlay);
        game_over_overlay.resources(_user_config.game_over_overlay);
    }

    public function game_start() {
        game_running = true;
        phys_engine.paused = false;
        game_input.listen();
        game_time = 0;

        if(attack_spawners.length > 1) {
            var idx = attack_spawners.length;
            while(idx > 1) {
                idx--;
                attack_spawners[idx].destroy();
                attack_spawners.splice(idx, 1);
            }
        }
        else if(attack_spawners.length == 0) {
            attack_spawners.push(create_spawner());
        }

        Luxe.events.fire('Game.restart');
    }

    function ongameover(_) {
        Patterns.ongameover();
        phys_engine.paused = true;
        game_running = false;
        game_input.unlisten();
        game_over_overlay.set_visible(true);
    }

    function create_spawner():AttackSpawner {
        return new AttackSpawner({
            color:ColorMgr.spawner,
            scene:this,
            depth:3
        });
    }

    function onchange(_e:InputEvent) {
        if(_e.name == selected_stick) {
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
                if(!game_running) {
                    if(menu_overlay.visible) { //from main menu
                        menu_overlay.set_visible(false);
                    }
                    else { //from game over
                        game_over_overlay.set_visible(false);
                    }
                    game_start();
                }
            case 'back':
                if(menu_overlay.visible) {
                    //In the main menu, swap analog stick
                    if(selected_stick == 'left_stick') {
                        selected_stick = 'right_stick';
                    }
                    else {
                        selected_stick = 'left_stick';
                    }
                }
                else if(game_over_overlay.visible) {
                    //Otherwise, go back to menu
                    game_over_overlay.set_visible(false);
                    menu_overlay.set_visible(true);
                }
                

        #if manual_testing
            case 'arc_shots':
                Patterns.arc_shots(attack_spawners[0]);
            case 'driveby':
                Patterns.driveby(attack_spawners[0]);
            case 'one_shot':
                Patterns.one_shot(attack_spawners[0]);
            case 'one_hunter':
                Patterns.one_hunter(attack_spawners[0]);
            case 'spread_shot':
                Patterns.spread_shot(attack_spawners[0]);
            case 'laser':
                Patterns.laser(attack_spawners[0]);
            case 'circ_shots':
                Patterns.circ_shots(attack_spawners[0]);
            case 'advance_time':
                game_time += 10;
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