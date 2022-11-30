module PE_array_ctrl(
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
    input continue_layer,
    output reg start,
    output reg [13:0] load_f, 
    output reg [11:0] load_i,
    output reg PE_pass_complete,
    output reg PE_array_complete
);

 

    reg [9:0] filter_loads;
    reg rst_filt_lds;
    wire [9:0] Q_size ;
    assign Q_size = Q;
    counter filter_vals_counter (.clk(clk), .rst(rst_filt_lds||rst), .size(Q_size), .out(filter_loads)); //time for loading Q filter values

    reg [9:0] ifmap_loads;
    reg rst_ifmap_lds;
    wire [9:0] t_ld_ifmaps; 
    assign t_ld_ifmaps = Q+Q-1;
    counter ifmap_vals_counter (.clk(clk), .rst(rst_ifmap_lds||rst), .size(t_ld_ifmaps), .out(ifmap_loads)); //time for loading Q ifmap values

    reg [9:0] filter_comps;
    reg rst_filter_cmps;
    wire [9:0] P_size ;
    assign P_size = P;
    counter filter_comps_counter (.clk(clk), .rst(rst_filter_cmps||rst), .size(P_size), .out(filter_comps)); //time for complete P filters

    always @(posedge clk) begin
        if (rst) begin
            rst_filt_lds <= 1'b1;
            rst_ifmap_lds <= 1'b1;
            rst_filter_cmps <= 1'b1;
        end
        if (begin_layer || continue_layer) begin
            rst_filt_lds <= 1'b0;
            load_f <= 12'hfff;
        end
        if (filter_loads == Q-1) begin
            rst_filt_lds <= 1'b1;
            load_f <= 12'h000;
            start <= 1'b1;
            rst_ifmap_lds <= 1'b0;
        end
        if (start && ifmap_loads == Q+Q-1) begin
            //start <= 1'b0;
            load_i <= 12'h000;
            rst_ifmap_lds <= 1'b1;
            rst_filter_cmps <= 1'b0;
        end
        if (filter_comps == P-1) begin
            PE_pass_complete <= 1'b1;
            start <= 1'b0;
            rst_filter_cmps <= 1'b1;
        end

        //TODO these bitshifts are sketchy
        if (start && ifmap_loads <= Q) begin
            load_i <= 12'hFFF >> (12-ifmap_loads);//{(Q-ifmap_loads){1'b0},ifmap_loads{1'b1}};
        end else if (start && ifmap_loads > Q) begin
            load_i <= (12'hFFF << (ifmap_loads-Q)) & (12'hFFF >> (12-Q)); //{(Q+Q-ifmap_loads){1'b1},(ifmap_loads-Q){1'b0}};
        end

    end

endmodule