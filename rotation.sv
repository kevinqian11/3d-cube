`default_nettype none

module rotation
    (input logic signed [2:0][7:0] A,
    input logic signed [7:0] cos, sin,
    input logic [1:0] axis,
    output logic signed [2:0][7:0] X);

    logic signed [16:0] sum0, sum1;

    // Axis Rotation Multiply Values
    logic signed [7:0] U, V;
    always_comb begin
        U = 0; V = 0;
        case(axis)
            2'b00: begin
                U = A[2]; V = A[1];
            end
            2'b01: begin
                U = A[0]; V = A[2];
            end
            2'b10: begin
                U = A[1]; V = A[0];
            end
            default: begin
                U = 0; V = 0;
            end
        endcase
    end

    // Rotation Multiplys Q2.6
    assign sum0 = (U * cos) - (V * sin);
    assign sum1 = (V * cos) + (U * sin);

    // Axis Rotation Outputs
    always_comb begin
        case(axis)
            2'b00: begin // x-axis rotation
                X[0] = A[0];
                X[1] = 8'(sum1 >>> 6);
                X[2] = 8'(sum0 >>> 6);
            end
            2'b01: begin // y-axis rotation
                X[0] = 8'(sum0 >>> 6);
                X[1] = A[1];
                X[2] = 8'(sum1 >>> 6);
            end
            2'b10: begin // z-axis rotation
                X[0] = 8'(sum1 >>> 6);
                X[1] = 8'(sum0 >>> 6);
                X[2] = A[2];
            end
            default: begin
                X = A;
            end
        endcase
    end
endmodule
