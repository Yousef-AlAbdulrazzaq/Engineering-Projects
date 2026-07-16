// ============================================================
// CE/EE 270 - Digital Robotic Sensor Processing
// Module: robotic_sensor
// Inputs:  G[2:0], Y[2:0], S[2:0]
// Outputs: result[3:0], overflow, eq_flag, u_flag, sys_off
// ============================================================

module robotic_sensor (
    input  [2:0] G,       // Front sensor input (3-bit)
    input  [2:0] Y,       // Side sensor input  (3-bit)
    input  [2:0] S,       // Select lines S2,S1,S0
    output reg [3:0] result,   // Numeric result for 7-seg
    output reg overflow,       // 1 = sensor exceeded safe range (>7)
    output reg eq_flag,        // 1 = G==Y  (display 'E')
    output reg u_flag,         // 1 = G!=Y  (display 'U')
    output reg sys_off         // 1 = system off (blank display)
);

    // Internal wires for arithmetic (5-bit to catch overflow)
    wire [4:0] w_2G    = {1'b0, G} * 2;        // 000 : 2*G
    wire [4:0] w_3Y    = {1'b0, Y} * 3;        // 001 : 3*Y
    wire [4:0] w_Gp3   = {1'b0, G} + 3;        // 011 : G+3
    wire [4:0] w_7mY   = 7 - {1'b0, Y};        // 100 : 7-Y
    wire [4:0] w_avg   = ({1'b0, G} + {1'b0, Y}) >> 1; // 101 : (G+Y)/2
    wire [4:0] w_GmY   = {1'b0, G} - {1'b0, Y};// 110 : G-Y (may underflow)

    always @(*) begin
        // Default outputs
        result   = 4'd0;
        overflow = 1'b0;
        eq_flag  = 1'b0;
        u_flag   = 1'b0;
        sys_off  = 1'b0;

        case (S)
            3'b000: begin // Motor Speed Mapping: 2*G
                if (w_2G > 9)
                    overflow = 1'b1;
                else
                    result = w_2G[3:0];
            end

            3'b001: begin // Turning Angle Mapping: 3*Y
                if (w_3Y > 9)
                    overflow = 1'b1;
                else
                    result = w_3Y[3:0];
            end

            3'b010: begin // Sensor Comparison: G == Y ?
                if (G == Y)
                    eq_flag = 1'b1;   // Display 'E'
                else
                    u_flag  = 1'b1;   // Display 'U'
            end

            3'b011: begin // Forward Adjustment: G + 3
                if (w_Gp3 > 9)
                    overflow = 1'b1;
                else
                    result = w_Gp3[3:0];
            end

            3'b100: begin // Clearance Check: 7 - Y
                result = w_7mY[3:0];  // Y is max 7, so result is 0..7, always safe
            end

            3'b101: begin // Path Average: (G+Y)/2
                result = w_avg[3:0];  // max = (7+7)/2 = 7, always safe
            end

            3'b110: begin // Difference: G - Y
                if (G >= Y)
                    result = (G - Y);
                else
                    overflow = 1'b1;  // Negative result -> overflow indicator
            end

            3'b111: begin // System Off
                sys_off = 1'b1;
            end
        endcase
    end

endmodule
