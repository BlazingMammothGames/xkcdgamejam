import kha.System;
import kha.math.Random;
import kha.Framebuffer;
import kha.input.Mouse;
import edge.Engine;
import edge.Phase;
import data.Level;

@:allow(Main)
class Game {
	public static var state(default, null):State;
    public static var engine(default, null):Engine;
    
    static var updatePhase:Phase;
    static var renderPhase:Phase;

    public static var random(default, null):Random;
    public static var resources(default, null):Resources;

    public static var currentLevel:Int = 0;
    public static var levels(default, null):Array<Level> = [
        new data.levels.Level1()
    ];

    static function initialize():Void {
        // TODO: new seed each time
        random = new Random(0);
        resources = new Resources();

        Mouse.get(0).notify(
            function(b, x, y) { if(b == 0) state.mouseDown = true; },
            function(b, x, y) { if(b == 0) state.mouseDown = false; },
            function(x:Int, y:Int, mx:Int, my:Int):Void {
                state.mouseX = x;
                state.mouseY = y;
                state.mouseDeltaX = mx;
                state.mouseDeltaY = my;
            },
            null,
            null
        );
        kha.SystemImpl.notifyOfMouseLockChange(function() {
            Game.state.pointerLocked = true;
        }, function() {
            Game.state.pointerLocked = false;
        });
        
        // TODO: input functions

        state = new State();

		engine = new Engine();
        updatePhase = engine.createPhase();
        updatePhase.add(new systems.MouseLookSystem());
        updatePhase.add(new systems.MatricesTransform());
        updatePhase.add(new systems.MatricesCamera());

        renderPhase = engine.createPhase();
        renderPhase.add(new systems.Render());

        levels[currentLevel].load();

        state.time = kha.Scheduler.time();
    }

    static function update():Void {
        state.w = System.windowWidth();
        state.h = System.windowHeight();

		var time:Float = kha.Scheduler.time();
		state.dt_variable = time - state.time;
		state.time = time;

		updatePhase.update(0);

        state.mouseDeltaX = 0;
        state.mouseDeltaY = 0;
    }

    static function render(fb:Framebuffer):Void {
		state.g2 = fb.g2;
		state.g4 = fb.g4;
		renderPhase.update(0);
    }

    public static function lockPointer():Void {
        kha.SystemImpl.lockMouse();
    }
}