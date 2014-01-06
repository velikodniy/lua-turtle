using Math;

class Turtle {
	public double x = 0;
	public double y = 0;
	public double phi = 0;

	public void Move(double length) {
		x += length * sin(phi);
		y += length * cos(phi);
	}
		
	public void Rotate(double deg) {
		phi += deg / 180.0 * PI;
		while (phi > 2 * PI)
			phi -= 2 * PI;
		while (phi < 0)
			phi += 2 * PI;
	}
}
