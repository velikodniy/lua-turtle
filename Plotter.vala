using Cairo;
using Math;

class Plotter {
	Context context;
	public Plotter(Context context) {
		this.context = context;
		context.set_source_rgb (0, 0, 0);
		context.set_line_width (1);
		context.set_tolerance (0.1);

	}

	public void Clear() {
		context.set_source_rgb(1.0, 1.0, 1.0);
		context.paint();
	}

	public void PlotTurtle(Turtle t, double size = 20.0) {
		Triangle(t.x, t.y, t.phi, size);
	}

	public void Triangle(double x, double y, double angle, double size = 20.0) {
		context.set_source_rgb (0, 0.5, 0);

		context.new_path();
		context.translate(x, y);
		context.move_to(0, 0);
		context.line_to(
			-size * cos(angle) / 4.0,
			size * sin(angle) / 4.0);
		context.line_to(
			size * sin(angle),
			size * cos(angle));
		context.line_to(
			size * cos(angle) / 4.0,
			-size * sin(angle) / 4.0);
		context.close_path();
		context.fill();
	}
}
