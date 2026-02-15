/**
 * Example main.cpp for M5Stack LVGL Emulator with StackChan Integration
 *
 * This is a template showing how to integrate StackChan UI components
 * into the M5Stack LVGL emulator for local testing.
 *
 * Place this file in your emulator's src/ directory and customize as needed.
 */

#include <lvgl.h>
#include <M5GFX.h>

// If you've linked StackChan components, include them here
// #include "stackchan_avatar/avatar.h"
// #include "stackchan_assets/assets.h"

// Display configuration for CoreS3 (320x240)
static const int SCREEN_WIDTH = 320;
static const int SCREEN_HEIGHT = 240;

// Global display object
M5GFX display;

/**
 * LVGL display buffer and flush callback
 */
static lv_disp_draw_buf_t draw_buf;
static lv_color_t buf1[SCREEN_WIDTH * 10];
static lv_color_t buf2[SCREEN_WIDTH * 10];

void lvgl_flush_cb(lv_disp_drv_t *disp, const lv_area_t *area, lv_color_t *color_p) {
    uint32_t w = (area->x2 - area->x1 + 1);
    uint32_t h = (area->y2 - area->y1 + 1);

    display.startWrite();
    display.setAddrWindow(area->x1, area->y1, w, h);
    display.writePixels((lgfx::rgb565_t *)&color_p->full, w * h);
    display.endWrite();

    lv_disp_flush_ready(disp);
}

/**
 * Initialize LVGL display
 */
void init_lvgl_display() {
    lv_init();

    // Initialize display buffer
    lv_disp_draw_buf_init(&draw_buf, buf1, buf2, SCREEN_WIDTH * 10);

    // Initialize display driver
    static lv_disp_drv_t disp_drv;
    lv_disp_drv_init(&disp_drv);
    disp_drv.hor_res = SCREEN_WIDTH;
    disp_drv.ver_res = SCREEN_HEIGHT;
    disp_drv.flush_cb = lvgl_flush_cb;
    disp_drv.draw_buf = &draw_buf;
    lv_disp_drv_register(&disp_drv);
}

/**
 * Create sample StackChan UI
 * Replace this with actual StackChan avatar initialization
 */
void create_stackchan_ui() {
    // Example: Create a simple screen
    lv_obj_t *scr = lv_scr_act();
    lv_obj_set_style_bg_color(scr, lv_color_hex(0x000000), 0);

    // Example: Add a label
    lv_obj_t *label = lv_label_create(scr);
    lv_label_set_text(label, "StackChan Emulator");
    lv_obj_set_style_text_color(label, lv_color_hex(0xFFFFFF), 0);
    lv_obj_align(label, LV_ALIGN_CENTER, 0, -40);

    // Example: Add a button
    lv_obj_t *btn = lv_btn_create(scr);
    lv_obj_align(btn, LV_ALIGN_CENTER, 0, 20);

    lv_obj_t *btn_label = lv_label_create(btn);
    lv_label_set_text(btn_label, "Click Me!");
    lv_obj_center(btn_label);

    // TODO: Initialize StackChan avatar here
    // Example:
    // stackchan_avatar_init();
    // stackchan_avatar_set_expression(EXPRESSION_HAPPY);
}

/**
 * Setup function - called once at startup
 */
void setup() {
    // Initialize M5GFX display
    display.init();
    display.setRotation(1);
    display.setBrightness(128);
    display.fillScreen(TFT_BLACK);

    // Initialize LVGL
    init_lvgl_display();

    // Create StackChan UI
    create_stackchan_ui();
}

/**
 * Loop function - called repeatedly
 */
void loop() {
    // LVGL task handler - must be called periodically
    lv_timer_handler();

    // Small delay to prevent CPU hogging
    delay(5);

    // TODO: Update StackChan avatar animations here
    // Example:
    // stackchan_avatar_update();
}

/**
 * Main entry point (for desktop emulator)
 */
#ifndef ARDUINO
int main() {
    setup();
    while (true) {
        loop();
    }
    return 0;
}
#endif
