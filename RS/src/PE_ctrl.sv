module PE_ctrl (
    input clk,
    input rst,
    input start,
    input load_f,
    input load_i,
    input [4:0] P,
    input [2:0] Q, 
    input [3:0] S,

    output reg [3:0] ifmap_spad_addr,
    output reg [7:0] filt_spad_addr,
    output reg [4:0] psum_spad_addr,
    output reg ifmap_spad_we, 
    output reg filt_spad_we, 
    output psum_spad_we,
    output acc_in_psum_sel,
    output reg reset_acc,
    output reg compute_complete
);

reg [9:0] four_cycle_cntr;
reg [9:0] pass_cycle_cntr;
reg [9:0] filter_round_cntr;
reg [4:0] p_cntr;

reg complete, complete_d1, complete_d2, complete_d3;
reg start_d1;
// wire start_d1_pulse;

reg rst1, rst2, rst3;

//counters
counter PE_4_cycle (.clk(clk), .rst(rst1), .size(10'd4), .out(four_cycle_cntr)); //PE takes 4 cycles
wire [9:0] pqs4;
assign pqs4 = 4*P*Q*S;
counter PE_pass_counter (.clk(clk), .rst(rst2), .size(pqs4), .out(pass_cycle_cntr)); //PE pass calcs P*Q*S psums * 4 cycles
wire [9:0] p4;
assign p4 = 4*P;
counter PE_filter_round_counter (.clk(clk), .rst(rst3), .size(p4), .out(filter_round_cntr)); //calculate a psum for each filter, then do another round; counting cycles for one round

//we 
assign psum_spad_we = (four_cycle_cntr == 2'b11) ? start_d1 : 1'b0;

//reset certain values on start, loads
always@(posedge load_f, posedge load_i) begin
    ifmap_spad_addr <= 4'h0;
    filt_spad_addr <= 8'h00;
    psum_spad_addr <= 5'b00000;
    rst1 <= 1;
    rst2 <= 1;
    rst3 <= 1;
end

always@(posedge start_d1) begin
    ifmap_spad_addr <= 4'h0;
    filt_spad_addr <= 8'h00;
    psum_spad_addr <= 5'b00000;
    rst1 <= 0;
    rst2 <= 0;
    rst3 <= 0;
    p_cntr <= 5'b00000;
    complete <= 1'b0;
end

//address calculation
always @(posedge clk) begin
    start_d1 <= start;
    // start_d2 <= start_d1;
    /*if (rst) begin
        ifmap_spad_addr <= 4'h0;
        filt_spad_addr <= 8'h00;
        psum_spad_addr <= 5'b00000;
        rst1 <= 1;
        rst2 <= 1;
        rst3 <= 1;
        p_cntr <= 5'b00000;
        complete <= 1'b0;
    end*/
    // if(start_d1_pulse) begin
    //     ifmap_spad_addr <= 4'h0;
    //     filt_spad_addr <= 8'h00;
    // end
    //ld
    ifmap_spad_we <= load_i; // in bank en(load) is checked on posedge clk, so get proper filt value 1 cycle after
    filt_spad_we <= load_f;

    if (ifmap_spad_we) begin
        if (ifmap_spad_addr < 4'd11) begin
            ifmap_spad_addr <= ifmap_spad_addr + 1;
        end
    end
    if (filt_spad_we) begin
        filt_spad_addr <= filt_spad_addr + 1;
    end
    //calc
    if (filter_round_cntr == 4*P-1 && start_d1) begin
        ifmap_spad_addr <= ifmap_spad_addr + 1;
    end
    if (four_cycle_cntr == 2'b11 && start_d1) begin
        filt_spad_addr <= filt_spad_addr + 1;
        if (psum_spad_addr == P-1 && !complete) begin
            psum_spad_addr <= 5'b00000;
        end
        else if (!complete) begin
            psum_spad_addr <= psum_spad_addr + 1;
        end
    end
    if (pass_cycle_cntr == 4*P*Q*S-1) begin
        complete <= 1'b1;
        psum_spad_addr <= 5'b00000;
    end
    if (complete) begin
        if (psum_spad_addr < P-1) begin
            psum_spad_addr <= psum_spad_addr + 1;
        end else begin
            psum_spad_addr <= 5'b00000;
            complete <= 1'b0;
        end
    end

    complete_d1 <= complete;
    complete_d2 <= complete_d1;
    complete_d3 <= complete_d2;
    compute_complete <= complete_d2 && ~complete_d3;

    //mux2 selection
    if (four_cycle_cntr == 2'b10 && p_cntr < P) begin
        reset_acc = 1'b1;
        p_cntr = p_cntr + 1;
    end else if (filt_spad_we == 1'b1 || ifmap_spad_we == 1'b1) begin
        reset_acc = 1'b1;
        p_cntr = 0;
    end else begin
        reset_acc = 1'b0;
    end
end

//mux1 selection
assign acc_in_psum_sel = complete_d3;
always @(*) begin
    /*if (four_cycle_cntr == 2'b10 && p_cntr < P) begin
        reset_acc = 1'b1;
        p_cntr = p_cntr + 1;
    end else if (load_f == 1'b1 || load_i == 1'b1) begin
        reset_acc = 1'b1;
        p_cntr = 0;
    end else begin
        reset_acc = 1'b0;
    end*/

end

endmodule