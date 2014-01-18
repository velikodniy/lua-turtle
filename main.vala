using Gtk;
using Cairo;

// Widgets
static SourceView sourceview;
static Statusbar statusbar;
static Button button_start;
static Button button_stop;
static DrawingArea canvas;
	
// Used for stop Lua code execution
static Cancellable stopper;
	
static Turtle t;
	
static uint context_id;
	
void on_start (Button sender) {
	// Switch buttons 
	button_start.sensitive = false;
	button_stop.sensitive = true;
		
	statusbar.pop(context_id);
		
	stopper = new Cancellable();
		
	// Create new Lua VM
	var vm = new Lua.LuaVM();
	//vm.open_libs ();
	vm.register ("move", move);
	vm.register ("rotate", rotate);
		
	// Set hook for execution stopping
	Lua.Debug debug;
	vm.set_hook((vm, ref debug) => {
			if (stopper.is_cancelled()) {
				vm.push_string("Stopped on line " + debug.current_line.to_string());
				vm.error();
			}
		}, Lua.EventMask.COUNT, 1);
		
	// Execure the rest of the method in new thread
	new Thread<int>("LuaVM", () => {
			bool fail = vm.do_string (sourceview.buffer.text);
			Idle.add(()=>{
					if (fail)
						statusbar.push(context_id, vm.to_string(-1));
					else
						statusbar.push(context_id, "OK");
						
					button_start.sensitive = true;
					button_stop.sensitive = false;
					return false;
				});
			return 0;
		});
}
	
	
static void on_stop (Button sender) {
	stopper.cancel();
	button_start.sensitive = true;
	button_stop.sensitive = false;
}
	
	
static bool on_draw (Widget da, Context ctx) {
	var p = new Plotter(ctx);
	p.Clear();
	p.PlotTurtle(t);
		
	return true;
}
	
static void wait() {
	Thread.usleep(500000);
}
	
static int move(Lua.LuaVM vm) {
	t.Move(vm.to_number(1));
	canvas.queue_draw();
	wait();
	return 1;
}
	
static int rotate(Lua.LuaVM vm) {
	t.Rotate(vm.to_number(1));
	canvas.queue_draw();
	wait();
	return 1;
}
	
static void init (Builder builder) {
	// show widgets
	var window = builder.get_object ("window") as Window;
	window.show_all ();
		
	// SourceView
	sourceview = builder.get_object("sourceview") as SourceView;
	var langs = new SourceLanguageManager();
	sourceview.buffer = new SourceBuffer.with_language(langs.get_language("lua"));
		
	// Statusbar
	statusbar = builder.get_object("statusbar") as Statusbar;
	context_id = statusbar.get_context_id("Error");
		
	// Start/stop buttons
	button_start = builder.get_object("button_start") as Button;
	button_stop = builder.get_object("button_stop") as Button;
		
	// DrawingArea
	canvas = builder.get_object("drawingarea") as DrawingArea;
		
	t = new Turtle();
}
	
static int main (string[] args) {
	const string GUI_FILE = "turtle.ui";
		
	Gtk.init (ref args);
		
	// Register SourceView widget
	Type type = typeof(SourceView);
	assert(type != 0);
		
	try {
		Builder builder = new Builder();
		builder.add_from_file(GUI_FILE);
		init(builder);
		builder.connect_signals(null);
	} catch (Error e) {
		stderr.printf("Could not load UI: %s\n", e.message);
		return 1;
	}
		
	// Main loop
	Gtk.main();
		
	return 0;
}
