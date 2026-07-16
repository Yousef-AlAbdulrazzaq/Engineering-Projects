// ============================================================
// CE/EE 270 - Testbench for robotic_sensor module
// Tests all 8 operations with representative input values
// ============================================================

`timescale 1ns/1ps

module tb_robotic_sensor;

    // Inputs
    reg [2:0] G, Y, S;

    // Outputs
    wire [3:0] result;
    wire       overflow, eq_flag, u_flag, sys_off;

    // Instantiate DUT
    robotic_sensor uut (
        .G(G), .Y(Y), .S(S),
        .result(result), .overflow(overflow),
        .eq_flag(eq_flag), .u_flag(u_flag), .sys_off(sys_off)
    );

    initial begin
        $display("=== CE270 Robotic Sensor Testbench ===");
        $display("Time | G   Y   S   | result | OVF EQ  U  OFF");
        $display("-----|-------------|--------|----------------");

        // S=000 Motor Speed Mapping: 2*G
        G=3'd3; Y=3'd0; S=3'b000; #10;
        $display("%4t | %b %b %b | %4d   | %b   %b   %b   %b  -- Expect result=6", $time, G, Y, S, result, overflow, eq_flag, u_flag, sys_off);

        G=3'd5; Y=3'd0; S=3'b000; #10;
        $display("%4t | %b %b %b | %4d   | %b   %b   %b   %b  -- Expect overflow (10>9)", $time, G, Y, S, result, overflow, eq_flag, u_flag, sys_off);

        // S=001 Turning Angle Mapping: 3*Y
        G=3'd0; Y=3'd2; S=3'b001; #10;
        $display("%4t | %b %b %b | %4d   | %b   %b   %b   %b  -- Expect result=6", $time, G, Y, S, result, overflow, eq_flag, u_flag, sys_off);

        G=3'd0; Y=3'd4; S=3'b001; #10;
        $display("%4t | %b %b %b | %4d   | %b   %b   %b   %b  -- Expect overflow (12>9)", $time, G, Y, S, result, overflow, eq_flag, u_flag, sys_off);

        // S=010 Sensor Comparison
        G=3'd3; Y=3'd3; S=3'b010; #10;
        $display("%4t | %b %b %b | %4d   | %b   %b   %b   %b  -- Expect eq_flag=1 (E)", $time, G, Y, S, result, overflow, eq_flag, u_flag, sys_off);

        G=3'd3; Y=3'd5; S=3'b010; #10;
        $display("%4t | %b %b %b | %4d   | %b   %b   %b   %b  -- Expect u_flag=1 (U)", $time, G, Y, S, result, overflow, eq_flag, u_flag, sys_off);

        // S=011 Forward Adjustment: G+3
        G=3'd4; Y=3'd0; S=3'b011; #10;
        $display("%4t | %b %b %b | %4d   | %b   %b   %b   %b  -- Expect result=7", $time, G, Y, S, result, overflow, eq_flag, u_flag, sys_off);

        // S=100 Clearance Check: 7-Y
        G=3'd0; Y=3'd3; S=3'b100; #10;
        $display("%4t | %b %b %b | %4d   | %b   %b   %b   %b  -- Expect result=4", $time, G, Y, S, result, overflow, eq_flag, u_flag, sys_off);

        // S=101 Path Average: (G+Y)/2
        G=3'd6; Y=3'd4; S=3'b101; #10;
        $display("%4t | %b %b %b | %4d   | %b   %b   %b   %b  -- Expect result=5", $time, G, Y, S, result, overflow, eq_flag, u_flag, sys_off);

        // S=110 Difference: G-Y
        G=3'd7; Y=3'd3; S=3'b110; #10;
        $display("%4t | %b %b %b | %4d   | %b   %b   %b   %b  -- Expect result=4", $time, G, Y, S, result, overflow, eq_flag, u_flag, sys_off);

        G=3'd2; Y=3'd5; S=3'b110; #10;
        $display("%4t | %b %b %b | %4d   | %b   %b   %b   %b  -- Expect overflow (negative)", $time, G, Y, S, result, overflow, eq_flag, u_flag, sys_off);

        // S=111 System Off
        G=3'd7; Y=3'd7; S=3'b111; #10;
        $display("%4t | %b %b %b | %4d   | %b   %b   %b   %b  -- Expect sys_off=1", $time, G, Y, S, result, overflow, eq_flag, u_flag, sys_off);

        $display("=== Testbench Complete ===");
        $finish;
    end

endmodule
