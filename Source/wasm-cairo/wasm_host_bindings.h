

#include <stdint.h>
#import	<Foundation/NSObjCRuntime.h>

//#import "wasm/wasm-entry.h"
//#import "wasm/bindings.h"

#ifndef __WASM_IMPORT
#define __WASM_IMPORT(module, symbol) __attribute__((import_module(#module), import_name(#symbol)))
#endif

// 
#ifdef __cplusplus
extern "C" {
#endif

struct proxy_screen_t {
	uint32_t width;
	uint32_t height;
};

struct window_surface_t {
	uint32_t x_pos;
	uint32_t y_pos;
	uint32_t width;
	uint32_t height;
	uint32_t win_id;
};

struct IOSurface_t {
	uint32_t x_pos;
	uint32_t y_pos;
	uint32_t width;
	uint32_t height;
	void *nsWindow;
	void *ctx;
	void *wcs;
	uint32_t screen_id;
	uint32_t win_id;
};

struct proxy_fontInfo_t {

	CGFloat underlinePosition;
	CGFloat underlineThickness;
	CGFloat capHeight;
	CGFloat xHeight;
	CGFloat descender;
	CGFloat ascender;
	uint32_t traits;
};

struct proxy_point_t {
	CGFloat x;
	CGFloat y;
};

struct proxy_rect_t {
	CGFloat x;
	CGFloat y;
	CGFloat width;
	CGFloat height;
};

struct proxy_mouse_event {
	uint32_t eventId;
	uint32_t modifier;
	uint64_t timestamp;
	void *window; 		// IOSurface_t;
	uint32_t mouseX;
	uint32_t mouseY; // 28
	uint32_t screenX;
	uint32_t screenY;
	uint16_t button;
	uint16_t clickCount;
	uint8_t screen_id;
	char defaultPrevented; // boolean
}; // 31 bytes (aligned = 32)

struct proxy_mouse_move_event {
	uint32_t eventId;
	uint32_t modifier;
	uint64_t timestamp;
	void *window; 		// IOSurface_t;
	uint32_t mouseX;
	uint32_t mouseY;
	uint32_t movementX;
	uint32_t movementY;
	uint32_t screenX;
	uint32_t screenY;
	uint8_t screen_id;
	char defaultPrevented; // boolean
}; // 37 bytes (aligned = 40 bytes)

struct proxy_mouse_wheel_event {
	uint32_t eventId;
	uint32_t modifier;
	uint64_t timestamp;
	void *window; 		// IOSurface_t;
	uint32_t mouseX;
	uint32_t mouseY;
	float wheelDeltaX;
	float wheelDeltaY;
	char defaultPrevented; // boolean
}; // 37 bytes (aligned = 40 bytes)

struct proxy_keyboard_event {
	uint32_t eventId;
	uint32_t modifier;
	uint64_t timestamp;
	void *window; 		   			// IOSurface_t;
	uint32_t keyCode;	   			//
	char *chars; 					// null-terminated
	char *charsIgnoringModifiers; 	// null-terminated
	char isRepeat; 		   			// boolean
	char defaultPrevented; 			// boolean
}; // 

struct DOMDataTransfer {

};

struct proxy_drag_event {
	uint32_t eventId;
	uint32_t modifier;
	uint64_t timestamp;
	void *window; 		// IOSurface_t;
	struct DOMDataTransfer *dataTransfer;
	uint32_t mouseX;
	uint32_t mouseY;
	uint32_t movementX;
	uint32_t movementY;
	uint32_t screenX;
	uint32_t screenY;
	uint8_t screen_id;
	char defaultPrevented; // boolean
}; // 

extern struct proxy_screen_t* __gnustep_get_screen_size() __WASM_IMPORT(wmaker, get_screen_size);
extern int __gnustep_create_window(struct IOSurface_t *surface) __WASM_IMPORT(wmaker, create_window);
extern int __gnustep_increment_window_id() __WASM_IMPORT(wmaker, increment_window_id);
extern void __gnustep_assign_framebuffer(int win_id, uint8_t *addr) __WASM_IMPORT(wmaker, assign_framebuffer);

extern void __gsc_set_cursor(int style, const char *name) __WASM_IMPORT(wmaker, set_cursor);
extern void __gsc_hide_cursor() __WASM_IMPORT(wmaker, hide_cursor);
extern void __gsc_show_cursor() __WASM_IMPORT(wmaker, show_cursor);
extern void __gnustep_setWindowTitle(int surfaceId, const char *title) __WASM_IMPORT(wmaker, set_window_title);
extern void __gnustep_flushDirtyRect(int surfaceId, int x, int y, int w, int h) __WASM_IMPORT(wmaker, flush_dirty_rect);
extern void __wmaker_setinputstate(int state, int win_num) __WASM_IMPORT(wmaker, set_input_state);
extern void __wmaker_placewindow(int surfaceId, int x_pos, int y_pos, int width, int height) __WASM_IMPORT(wmaker, place_window);
extern void __wmaker_setwindowlevel(int level, int surfaceId) __WASM_IMPORT(wmaker, set_window_level);
extern void __wmaker_orderwindow(int op, int otherWin, int winNum) __WASM_IMPORT(wmaker, order_window);
extern void __wmaker_finalize_surface(int surfaceId) __WASM_IMPORT(wmaker, finalize_surface);

// Function signatures exported by emscripten and accessable from the host (JavaScript side) 

void _gstep_handle_mouse_down(struct proxy_mouse_event *evt); // alt. naming conv. 'dispatch_' or 'post_xxx_event'
void _gstep_handle_mouse_up(struct proxy_mouse_event *evt);
void _gstep_handle_mouse_move(struct proxy_mouse_move_event *evt);
void _gstep_handle_mouse_click(struct proxy_mouse_event *evt);
void _gstep_handle_mouse_dbl_click(struct proxy_mouse_event *evt);
void _gstep_handle_mouse_wheel(struct proxy_mouse_wheel_event *evt);

void _gstep_handle_keyboard_key_down(struct proxy_keyboard_event *evt);
void _gstep_handle_keyboard_key_up(struct proxy_keyboard_event *evt);
void _gstep_handle_text_input_composition(void *);

void _gstep_handle_drag_evt(struct proxy_drag_event *evt);
void _gstep_handle_drag_end_evt(struct proxy_drag_event *evt);
void _gstep_handle_drag_enter_evt(struct proxy_drag_event *evt);
void _gstep_handle_drag_leave_evt(struct proxy_drag_event *evt);
void _gstep_handle_drag_over_evt(struct proxy_drag_event *evt);
void _gstep_handle_drag_start_evt(struct proxy_drag_event *evt);
void _gstep_handle_drag_drop_evt(struct proxy_drag_event *evt);

void _log_sizes();


//
#ifdef __cplusplus
}
#endif