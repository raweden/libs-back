
#include "wasm-cairo/WasmCairoIOSurface.h"
#import "wasm_host_bindings.h"
#include <cairo.h>

@implementation WasmCairoIOSurface
{
    struct pool_buffer *pbuffer;
}
- (id)initWithDevice:(void *)device
{
    // fprintf(stderr, "did enter call at %s\n", __PRETTY_FUNCTION__);

    struct IOSurface_t *surface = (struct IOSurface_t *)device;

    _surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, surface->width, surface->height);

    // https://www.cairographics.org/manual/cairo-Image-Surfaces.html#cairo-image-surface-get-data
    uint8_t *data = cairo_image_surface_get_data(_surface);
    __gnustep_assign_framebuffer(surface->win_id, data);

    surface->wcs = self;

    return self;
}

- (void)dealloc
{
    fprintf(stderr, "did enter call at %s\n", __PRETTY_FUNCTION__);
    cairo_surface_destroy(_surface);
    _surface = NULL;

    [super dealloc];
}

- (NSSize)size
{
    if (_surface == NULL) {
        return NSZeroSize;
    }

    return NSMakeSize(cairo_image_surface_get_width(_surface), cairo_image_surface_get_height(_surface));
}

- (void)handleExposeRect:(NSRect)rect
{
    // fprintf(stderr, "did enter call at %s\n", __PRETTY_FUNCTION__);
}

- (void)destroySurface
{
    // noop this is an offscreen surface no need to destroy it when not visible
}


@end