class_name MarbleTexture
extends RefCounted
## The swirl of a glass marble: bands of a lighter and a darker shade of the side's colour, painted
## once per colour. It is the sphere's own texture, so it turns with the marble and a rolling
## marble can be seen to roll. The flat mark on top (MarbleBadge) does not turn, so a side stays
## readable.

const SIZE := Vector2i(128, 64)
const LIGHTEN := 0.55
const DARKEN := 0.4

static var _cache: Dictionary = {}


## The texture for a colour, made on first use.
static func for_colour(colour: Color) -> ImageTexture:
	var key := colour.to_html()
	if not _cache.has(key):
		_cache[key] = ImageTexture.create_from_image(make_image(colour))
	return _cache[key]


## The swirl as an image. Bands run round the marble, so the left and right edges meet.
static func make_image(colour: Color) -> Image:
	var image := Image.create(SIZE.x, SIZE.y, true, Image.FORMAT_RGB8)
	var light := colour.lightened(LIGHTEN)
	var dark := colour.darkened(DARKEN)
	for y in SIZE.y:
		var v := float(y) / SIZE.y
		for x in SIZE.x:
			var u := float(x) / SIZE.x
			var wide := sin(TAU * (3.0 * u + 0.9 * v + 0.35 * sin(TAU * 2.0 * v)))
			var narrow := sin(TAU * (2.0 * u - 0.6 * v + 0.4 * sin(TAU * v)))
			var pale := smoothstep(0.55, 0.92, wide)
			var shade := smoothstep(0.72, 0.97, narrow)
			image.set_pixel(x, y, colour.lerp(light, pale * 0.85).lerp(dark, shade * 0.6))
	image.generate_mipmaps()
	return image
