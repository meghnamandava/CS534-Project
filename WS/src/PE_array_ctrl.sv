module PE_array_ctrl(
    input clk,
    input rst,
    input [8:0] M,    // # filters / # ofmap channels
    input [8:0] C,    // # ifmap/filter channels
    input [3:0] R, S, // height and width of filter
    input [6:0] E, F, // height and width of ofmap
    input [7:0] H, W, // height and width of input feature map
    input [3:0] P,    // # filters processed by array
    input [3:0] Q,    // # filter elems processed by column
    input begin_layer,
    input continue_layer,
    output reg start,
    output reg [13:0] load_f, 
    output reg [11:0] load_i,
    output reg [13:0] load_o,
    output reg PE_pass_complete,
    output reg PE_array_complete
);
    wire [6:0] filter_size; //max size 121
    assign filter_size = R*S;
    wire [9:0] channels_in_pass;
    assign channels_in_pass = (filter_size > Q) ? 1 : Q/filter_size;

    reg [9:0] filter_loads;
    reg rst_filt_lds;
    wire [9:0] Q_size ;
    assign Q_size = 13;
    counter filter_vals_counter (.clk(clk), .rst(rst_filt_lds||rst), .size(Q_size), .out(filter_loads)); //time for loading Q filter values

    reg [9:0] ifmap_loads;
    reg rst_ifmap_lds;
    wire [9:0] t_ld_ifmaps; 
    assign t_ld_ifmaps = ((W-S+1)*(W-S+1)*2)*channels_in_pass; //CHECK
    counter ifmap_vals_counter (.clk(clk), .rst(rst_ifmap_lds||rst), .size(t_ld_ifmaps), .out(ifmap_loads)); //time for loading Q ifmap values
    
    reg [9:0] ofmap_loads;
    reg rst_ofmap_lds;
    wire [9:0] t_ld_ofmaps; 
    assign t_ld_ofmaps = Q+P;
    counter ofmap_vals_counter (.clk(clk), .rst(rst_ofmap_lds||rst), .size(t_ld_ofmaps), .out(ofmap_loads)); //time for loading Q ofmap values
    
    /*reg [9:0] ofmap_loads2;
    reg rst_ofmap_lds2;
    wire [9:0] t_ld_ofmaps2; 
    assign t_ld_ofmaps2 = P;
    counter ofmap_vals_counter (.clk(clk), .rst(rst_ofmap_lds2||rst), .size(t_ld_ofmaps2), .out(ofmap_loads2)); //time for loading P ofmap values*/

    reg [9:0] filter_comps;
    reg rst_filter_cmps;
    wire [9:0] P_size ;
    assign P_size = P;
    counter filter_comps_counter (.clk(clk), .rst(rst_filter_cmps||rst), .size(P_size), .out(filter_comps)); //time for complete P filters

    reg done_loading_ifmaps;

    integer i;

    always @(posedge clk) begin
        if (rst) begin
            rst_filt_lds <= 1'b1;
            rst_ifmap_lds <= 1'b1;
            rst_filter_cmps <= 1'b1;
            rst_ofmap_lds <= 1'b1;
            //rst_ofmap_lds2 <= 1'b1;
            start <= 1'b0;
            load_f <= 14'h0000;
            load_i <= 12'h000;
            load_o <= 14'h0000;
            done_loading_ifmaps <= 1'b0;
        end else begin
            if (begin_layer) begin
                rst_filt_lds <= 1'b0;
                load_f <= 14'hffff;
            end
            if ((~start && filter_loads == Q_size-1) || continue_layer) begin
                //rst_filt_lds <= 1'b1;
                load_f <= 14'h0000;
                start <= 1'b1;
                rst_ifmap_lds <= 1'b0;
            end
            if (start && ofmap_loads < t_ld_ofmaps) begin
                for (i=0;i<14;i=i+1) begin
                    if (ofmap_loads < Q+i) begin
                        load_o[i] <= 1'b1;
                    end
                end
                //load_o <= 14'b1;
            end
            if (start && ofmap_loads == t_ld_ofmaps-1) begin
                rst_ofmap_lds <= 1'b1;
                load_o <= 14'h000;
            end
            if (start && filter_loads == Q-1) begin
                rst_filt_lds <= 1'b1;
                rst_ofmap_lds <= 1'b0;
                //rst_ofmap_lds2 <= 1'b0;
            end else if (start && ifmap_loads == t_ld_ifmaps-1) begin
                //start <= 1'b0;
                load_i <= 12'h000;
                done_loading_ifmaps <= 1'b1;
                rst_ifmap_lds <= 1'b1;
                rst_filter_cmps <= 1'b0;
            end else if (start && done_loading_ifmaps && filter_comps == P_size-1) begin
                PE_pass_complete <= 1'b1;
                done_loading_ifmaps <= 1'b0;
                start <= 1'b0;
                rst_filter_cmps <= 1'b1;
            end else if (start && ifmap_loads < t_ld_ifmaps) begin
                load_i <= 12'hFFF; 
            end 
        end
    

        //TODO these bitshifts are sketchy
        /*if (start && ifmap_loads <= Q) begin
            load_i <= 12'hFFF >> (12-ifmap_loads);//{(Q-ifmap_loads){1'b0},ifmap_loads{1'b1}};
        end else if (start && ifmap_loads > Q) begin
            load_i <= (12'hFFF << (ifmap_loads-Q)) & (12'hFFF >> (12-Q)); //{(Q+Q-ifmap_loads){1'b1},(ifmap_loads-Q){1'b0}};
        end*/

        
    end

endmodule