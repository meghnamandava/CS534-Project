module filter_bank (
    input clk,
    input rst,
    input [8:0] M,    // # filters / # ofmap channels
    input [8:0] C,    // # ifmap/filter channels
    input [3:0] R, S, // height and width of filter
    input [6:0] E, F, // height and width of ofmap
    input [7:0] H, W, // height and width of input feature map
    input [3:0] P,    // # filters processed by array
    input [3:0] Q,    // # filter elems processed by column
    input en,
    output reg [15:0] filter_out [13:0]
);

    wire [6:0] filter_size; //max size 121
    assign filter_size = R*S;

    reg [15:0] filter [1023:0];

    reg [9:0] count_P = 10'd0;
    reg [9:0] count_Q = 10'd0;
    reg [9:0] count_S = 10'd0;
    reg [9:0] count_R = 10'd0;

    always @(posedge clk) begin
        if (en) begin
            filter_out[0] = filter[]

        end
        
    end  

endmodule