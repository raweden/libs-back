


#ifndef _HTML5CanvasDisplayServer_h_INCLUDE
#define _HTML5CanvasDisplayServer_h_INCLUDE

#include <GNUstepGUI/GSDisplayServer.h>


struct mouse_config_t {
  uint32_t screenX;
  uint32_t screenY;
  uint8_t screen_id;
};

struct wcs_screen_t {
  int width;
  int height;
};

struct wcs_config_t {

  struct mouse_config_t mouse;
  struct wcs_screen_t **screens;
  int num_screen;
};

struct wcs_screen_t *wcs_getScreen();
struct mouse_config_t *lastMouseLocation();



//struct window *get_window_with_id(WaylandConfig *wlconfig, int winid);

@interface WasmCairoDisplayServer : GSDisplayServer
{
  //WaylandConfig *wlconfig;
  
  struct wcs_config_t *_config;

  BOOL handlesWindowDecorations;
  //BOOL _mouseInitialized;
}
@end

#endif /* _WaylandServer_h_INCLUDE */