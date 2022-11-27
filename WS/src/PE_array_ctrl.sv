module PE_array(
    input clk,
    input rst,
    input [8:0] M,    // # filters / # ofmap channels
    input [8:0] C,    // # ifmap/filter channels
    input [3:0] R, S, // height and width of filter
    input [6:0] E, F, // height and width of ofmap
    input [7:0] H, W, // height and width of input feature map
    input [3:0] P,    // # filters processed by array
    input [3:0] Q,    // # filter channels processed by column
    input begin_layer,
    output reg [13:0] load_f, 
    output reg [11:0] load_i,
    output PE_array_complete
);

    reg [9:0] filter_loads;
    reg rst_filt_lds;
    counter filter_vals_counter (.clk(clk), .rst(rst_filt_lds||rst), .size(Q), .out(filter_loads)); //time for loading Q values

    always @(posedge clk) begin
        if (rst) begin
            rst_filt_lds <= 1'b1;
        end
        if (begin_layer) begin
            rst_filt_lds <= 1'b0;
            load_f <= 12'hfff;
        end
        if (filter_loads == Q-1) begin
            rst_filt_lds <= 1'b1;
            load_f <= 12'h000;
        end

    end

endmodule