module PE (
    input clk,
    input rst,
    input [15:0] ifmap,
    input [15:0] filt,
    input [15:0] in_psum,
    output [15:0] out_psum,

    input start,
    input load_f,
    input load_i,
    input [4:0] P, //# filters processed by PE set
    input [2:0] Q, // # channels of a particular filter processed by PE set
    input [3:0] S, // filter width
    output complete 

) ;

    wire [15:0] adder_out, psum_out, ifmap_out, filt_out;
                   
   
    wire [3:0] ifmap_spad_addr;
    wire [7:0] filt_spad_addr;
    wire [4:0] psum_spad_addr;

    wire ifmap_spad_we, filt_spad_we, psum_spad_we; 

    wire [31:0] mult_out;

    //mux outputs
    wire [15:0] mux1_out, mux2_out; //mux 1 is mult, mux2 is psum\

    //mux selects 
    wire acc_in_psum_sel;
    wire reset_acc;

    scratchpad #(.ADDR(4), .SPADSIZE(12)) ifmap_spad (.clk(clk), .rst(rst), .addr(ifmap_spad_addr), .we(ifmap_spad_we), .data_in(ifmap), .data_out(ifmap_out));
    scratchpad #(.ADDR(8), .SPADSIZE(224)) filt_spad (.clk(clk), .rst(rst), .addr(filt_spad_addr), .we(filt_spad_we), .data_in(filt), .data_out(filt_out));
    scratchpad #(.ADDR(5), .SPADSIZE(24)) psum_spad (.clk(clk), .rst(rst), .addr(psum_spad_addr), .we(psum_spad_we), .data_in(adder_out), .data_out(psum_out));
    
    //flopped outputs of spads and mux
    reg [15:0] psum_out_d, ifmap_out_d, filt_out_d;
    reg [15:0] mux2_out_d;
    reg [15:0] mult_out_d; 

    always@(posedge clk) begin
        psum_out_d <= psum_out;
        ifmap_out_d <= ifmap_out;
        filt_out_d <= filt_out;
        mux2_out_d <= mux2_out;
        mult_out_d <= mult_out[15:0]; //might need to change this
    end

    //FAKE TWO STAGE multiplier TODOMAYBE
    assign mult_out = ifmap_out_d*filt_out_d;

    //muxes
    assign mux2_out = (reset_acc) ? 16'b0 : psum_out_d;
    assign mux1_out = (acc_in_psum_sel) ? in_psum : mult_out_d;

    //adder
    assign adder_out = mux2_out_d+mux1_out;

    assign out_psum = adder_out;

    PE_ctrl pe_ctrl (
        .clk(clk),
        .rst(rst),
        .start(start),
        .load_f(load_f),
        .load_i(load_i),
        .P(P),
        .Q(Q),
        .S(S),
        .ifmap_spad_addr(ifmap_spad_addr),
        .filt_spad_addr(filt_spad_addr),
        .psum_spad_addr(psum_spad_addr),
        .ifmap_spad_we(ifmap_spad_we),
        .filt_spad_we(filt_spad_we),
        .psum_spad_we(psum_spad_we),
        .acc_in_psum_sel(acc_in_psum_sel),
        .reset_acc(reset_acc),
        .compute_complete(complete)
    );

endmodule