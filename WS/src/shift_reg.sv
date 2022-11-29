
//Shift reg that holds 12 values

module shift_reg (
    input clk,complete,
    input [15:0] D_in,
    output [15:0] D_out,
    output reg output_done 
);

    wire [15:0] data [11:0];

    register r0(.clk(clk),.en(en),.d(D_in),.q(data[0]));

    genvar r;
    generate
        for (r=1;r<12;r=r+1) begin
            register rx (.clk(clk),.en(en),.d(data[r-1]),.q(data[r]));
        end
    endgenerate

endmodule