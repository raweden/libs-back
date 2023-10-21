


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

/*
struct pointer
{
  struct wl_pointer *wlpointer;
  float		     x;
  float		     y;
  uint32_t	     last_click_button;
  uint32_t	     last_click_time;
  float		     last_click_x;
  float		     last_click_y;

  uint32_t		       button;
  NSTimeInterval	   last_timestamp;
  enum wl_pointer_button_state button_state;

  uint32_t axis_source;

  uint32_t	 serial;
  struct window *focus;
  struct window *captured;

};

struct cursor
{
  struct wl_cursor *cursor;
  struct wl_surface *surface;
  struct wl_cursor_image *image;
  struct wl_buffer *buffer;
};

struct output
{
  WaylandConfig	*wlconfig;
  struct wl_output *output;
  uint32_t	    server_output_id;
  struct wl_list    link;
  int		    alloc_x;
  int		    alloc_y;
  int		    width;
  int		    height;
  int		    transform;
  int		    scale;
  char	       *make;
  char	       *model;

  void *user_data;
};*/

/*
struct window
{
  WaylandConfig *wlconfig;
  id		 instance;
  int		 window_id;
  struct wl_list link;
  BOOL		 configured; // surface has been configured once
  BOOL buffer_needs_attach;  // there is a new buffer avaialble for the surface
  BOOL terminated;
  BOOL moving;
  BOOL resizing;
  BOOL ignoreMouse;

  float pos_x;
  float pos_y;
  float width;
  float height;
  float saved_pos_x;
  float saved_pos_y;
  int	is_out;
  int	level;

  struct wl_surface *surface;
  struct xdg_surface *xdg_surface;
  struct xdg_toplevel *toplevel;
  struct xdg_popup *popup;
  struct xdg_positioner	*positioner;
  struct zwlr_layer_surface_v1 *layer_surface;
  struct output *output;
  CairoSurface *wcs;
};*/

// struct window *get_window_with_id(WaylandConfig *wlconfig, int winid);

@interface WasmCairoDisplayServer : GSDisplayServer
{
    // WaylandConfig *wlconfig;

    struct wcs_config_t *_config;

    BOOL handlesWindowDecorations;
    // BOOL _mouseInitialized;
}
@end

#endif /* _WaylandServer_h_INCLUDE */