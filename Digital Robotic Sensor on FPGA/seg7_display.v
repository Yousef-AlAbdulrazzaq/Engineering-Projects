// ============================================================
// CE/EE 270 - 7-Segment Display Decoder
// Module: seg7_display
// Inputs:  result[3:0], overflow, eq_flag, u_flag, sys_off
// Output:  seg[6:0]  → segments a,b,c,d,e,f,g  (active LOW)
//
//   Segment layout:
//       _
//      |_|   a=top, b=top-right, c=bot-right
//      |_|   d=bottom, e=bot-left, f=top-left, g=middle
//
//   seg[6]=a  seg[5]=b  seg[4]=c  seg[3]=d
//   seg[2]=e  seg[1]=f  seg[0]=g
// ============================================================

module seg7_display (
    input  [3:0] result,
    input        overflow,   // Show '='
    input        eq_flag,    // Show 'E'
    input        u_flag,     // Show 'U'
    input        sys_off,    // Blank display
    output reg [6:0] seg     // active LOW
);

    always @(*) begin
        if (sys_off)
            seg = 7'b1111111;          // All segments OFF (blank)

        else if (overflow)
            // '=' sign: middle + bottom segments  (g and d)
            seg = 7'b1110111;          // segments d and g only

        else if (eq_flag)
            // 'E': a, f, g, e, d  → seg = a,b,c,d,e,f,g
            seg = 7'b0000110;          // 0b_abcdefg → E

        else if (u_flag)
            // 'U': f, e, d, c, b  (no top)
            seg = 7'b1000001;          // U shape

        else begin
            // BCD 0..9 display (active LOW)
            case (result)
                4'd0: seg = 7'b0000001; // 0
                4'd1: seg = 7'b1001111; // 1
                4'd2: seg = 7'b0010010; // 2
                4'd3: seg = 7'b0000110; // 3
                4'd4: seg = 7'b1001100; // 4
                4'd5: seg = 7'b0100100; // 5
                4'd6: seg = 7'b0100000; // 6
                4'd7: seg = 7'b0001111; // 7
                4'd8: seg = 7'b0000000; // 8
                4'd9: seg = 7'b0000100; // 9
                default: seg = 7'b1111111; // Blank
            endcase
        end
    end

endmodule
