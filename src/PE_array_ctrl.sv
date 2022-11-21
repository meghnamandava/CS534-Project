module PE_array_ctrl (
    input clk,
    input [4:0] P, //# filters processed by PE set
    input [2:0] Q, // # channels of a particular filter processed by PE set
    input [3:0] S, // filter width
    input [4:0] R, // filter heigh
    input [4:0] r, //# PE sets in array proc diff channels of a filter
    input [4:0] t, //# PE sets in array proc different filters
    input [7:0] H, W, //height and width of input feature map
    input begin_layer,
    input complete, //inputs from PEs indicating psums are ready

    output reg start,
    output reg [11:0] load_f, load_i,
    output reg [11:0] ipsum_mux_sel,
    output reg PE_array_complete
);

    reg ready_ld_i;

    reg [9:0] filter_loads;
    reg rst_filt_lds;
    wire [9:0] pqs_1;
    assign pqs_1 = P*Q*S+1;
    counter filter_vals_counter (.clk(clk), .rst(rst_filt_lds), .size(pqs_1), .out(filter_loads)); //time for loading P*Q*S filter values

    reg [9:0] ifmap_loads;
    reg rst_ifmap_lds;
    //wire start_ifmap_lds;
    wire [9:0] qs_1;
    assign qs_1 = Q*S+1;
    counter ifmap_vals_counter (.clk(clk), .rst(rst_ifmap_lds), .size(qs_1), .out(ifmap_loads)); //time for loading Q*S ifmap values

    reg [1:0] count_sets = 4'h0;
    reg [7:0] count_windows = 8'h00;

    always@(posedge clk) begin
        rst_ifmap_lds <= ~ready_ld_i; //TODOMAYBE
    end

    always@(posedge begin_layer) begin
        //start loading filters 
        load_f = 12'hfff;
        rst_filt_lds = 1'b0;
        load_i = 12'h000;
    end

    always@(*) begin
        //if we have loaded all filters
        if (filter_loads == S*P*Q) begin 
            rst_filt_lds = 1'b1;
            load_f = 12'h000;
            ready_ld_i = 1'b1;
        end
        //if we have loaded all ifmap values
        if (ifmap_loads == S*Q) begin
            count_sets = count_sets + 1;
            load_i = load_i << R;
            rst_ifmap_lds = 1'b1;
            if (count_sets == r*t) begin
                load_i = 12'h000;
                //start_ifmap_lds = 1'b0;
                start = 1'b1;
                ready_ld_i = 1'b0;
                count_sets = 0;
                // do we need to reset load_f as well? prob not
            end
        end
    end

    always@(posedge ready_ld_i) begin
        load_i = 12'hFFF >> (12-R);
        //start_ifmap_lds = 1'b1;
    end
    
    always @(posedge complete) begin
        start = 1'b0;
        count_windows = count_windows + 1;
        count_sets = 0;
        ready_ld_i = 1'b1;
        
        if (count_windows == (W - S + 1)) begin //complete all sliding windows, PE array pass done
            PE_array_complete = 1'b1;
        end
    end

    wire [10:0] Rr;
    assign Rr = R*r;
    //ipsum mux sel 1 when a row should get 0s as ipsum
    always @(*) begin
        if ((Rr)-1 < 12) begin
            ipsum_mux_sel[Rr-1] = 1'b1;
        end else begin
            ipsum_mux_sel[Rr-1] = 1'b0;
        end

        if ((2*Rr)-1 < 12) begin
            ipsum_mux_sel[(2*Rr)-1] = 1'b1;
        end else begin
            ipsum_mux_sel[(2*Rr)-1] = 1'b0;
        end
        
        if ((3*Rr)-1 < 12) begin
            ipsum_mux_sel[(3*Rr)-1] = 1'b1;
        end else begin
            ipsum_mux_sel[(3*Rr)-1] = 1'b0;
        end

        if ((4*Rr)-1 < 12) begin
            ipsum_mux_sel[(4*Rr)-1] = 1'b1;
        end else begin
            ipsum_mux_sel[(4*Rr)-1] = 1'b0;
        end

        if ((5*Rr)-1 < 12) begin
            ipsum_mux_sel[(5*Rr)-1] = 1'b1;
        end else begin
            ipsum_mux_sel[(5*Rr)-1] = 1'b0;
        end

        if ((6*Rr)-1 < 12) begin
            ipsum_mux_sel[(6*Rr)-1] = 1'b1;
        end else begin
            ipsum_mux_sel[(6*Rr)-1] = 1'b0;
        end

        if ((7*Rr)-1 < 12) begin
            ipsum_mux_sel[(7*Rr)-1] = 1'b1;
        end else begin
            ipsum_mux_sel[(7*Rr)-1] = 1'b0;
        end

        if ((8*Rr)-1 < 12) begin
            ipsum_mux_sel[(8*Rr)-1] = 1'b1;
        end else begin
            ipsum_mux_sel[(8*Rr)-1] = 1'b0;
        end

        if ((9*Rr)-1 < 12) begin
            ipsum_mux_sel[(9*Rr)-1] = 1'b1;
        end else begin
            ipsum_mux_sel[(9*Rr)-1] = 1'b0;
        end

        if ((10*Rr)-1 < 12) begin
            ipsum_mux_sel[(10*Rr)-1] = 1'b1;
        end else begin
            ipsum_mux_sel[(10*Rr)-1] = 1'b0;
        end

        if ((11*Rr)-1 < 12) begin
            ipsum_mux_sel[(11*Rr)-1] = 1'b1;
        end else begin
            ipsum_mux_sel[(11*Rr)-1] = 1'b0;
        end

        if ((12*Rr)-1 < 12) begin
            ipsum_mux_sel[(12*Rr)-1] = 1'b1;
        end else begin
            ipsum_mux_sel[(12*Rr)-1] = 1'b0;
        end

        




    end
endmodule