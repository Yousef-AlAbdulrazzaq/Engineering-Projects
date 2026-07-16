// ============================================================
// CE/EE 270 - Top-Level Module
// Connects Robotic Sensor Processing to 7-Segment Display
// ============================================================

module top_level (
    input  [2:0] G,      // SW[2:0]  - Front sensor
    input  [2:0] Y,      // SW[5:3]  - Side sensor
    input  [2:0] S,      // SW[8:6]  - Select lines
    output [6:0] seg,    // HEX0     - 7-segment display
    output       overflow_led  // LEDR[0] - Overflow LED
);

    wire [3:0] result;
    wire       overflow, eq_flag, u_flag, sys_off;

    // Instantiate Robotic Sensor Processing
    robotic_sensor u_sensor (
        .G        (G),
        .Y        (Y),
        .S        (S),
        .result   (result),
        .overflow (overflow),
        .eq_flag  (eq_flag),
        .u_flag   (u_flag),
        .sys_off  (sys_off)
    );

    // Instantiate 7-Segment Display
    seg7_display u_display (
        .result   (result),
        .overflow (overflow),
        .eq_flag  (eq_flag),
        .u_flag   (u_flag),
        .sys_off  (sys_off),
        .seg      (seg)
    );

    assign overflow_led = overflow;

endmodule
