module PE_array(
    input clk,
    input rst,
    input [4:0] P, //# filters processed by PE set
    input [2:0] Q, // # channels of a particular filter processed by PE set
    input [3:0] S, // filter width
    input [4:0] R, // filter heigh
    input [4:0] r, //# PE sets in array proc diff channels of a filter
    input [4:0] t, //# PE sets in array proc different filters
    input [7:0] H, W, //height and width of input feature map
    input begin_layer,
    output PE_array_complete
);

wire [15:0] filter_row_con [11:0]; //connection for filter shared by each row
//wire [15:0] filter_PE_con [11:0][13:0]; //connection for each PE filter

wire [15:0] ifmap_diag_con [24:0]; //connection for ifmap shared by each diagonal
wire [15:0] ifmap_PE_con [11:0][13:0]; //connection for each PE ifmap

wire [15:0] ipsum_PE_con [11:0][13:0]; //connection for each PE ipsum
wire [15:0] opsum_PE_con [11:0][13:0]; //connection for each PE opsum

wire complete_PE_con [11:0][13:0]; //connection for each PE complete signal
wire output_done[11:0][13:0];


wire [15:0] q0  [11:0][13:0];            // Connections of output shift reg
wire [15:0] q1  [11:0][13:0];
wire [15:0] q2  [11:0][13:0];
wire [15:0] q3  [11:0][13:0];
wire [15:0] q4  [11:0][13:0];
wire [15:0] q5  [11:0][13:0];
wire [15:0] q6  [11:0][13:0];
wire [15:0] q7  [11:0][13:0];
wire [15:0] q8  [11:0][13:0];
wire [15:0] q9  [11:0][13:0];
wire [15:0] q10 [11:0][13:0];
wire [15:0] q11 [11:0][13:0];
wire [15:0] q12 [11:0][13:0];
wire [15:0] q13 [11:0][13:0];
wire [15:0] q14 [11:0][13:0];
wire [15:0] q15 [11:0][13:0];
wire [15:0] q16 [11:0][13:0];
wire [15:0] q17 [11:0][13:0];
wire [15:0] q18 [11:0][13:0];
wire [15:0] q19 [11:0][13:0];
wire [15:0] q20 [11:0][13:0];
wire [15:0] q21 [11:0][13:0];
wire [15:0] q22 [11:0][13:0];
wire [15:0] q23 [11:0][13:0];

reg [15:0] out_psum [23:0][100:0];

reg [5:0] temp_t      = 6'b000000;
reg [5:0] count_t     = 6'b000000;
reg [5:0] count_p     = 6'b000000;
reg [5:0] count_base  = 6'd000000;
reg [5:0] count_col   = 6'b000000;

wire e_out_psum;
assign e_out_psum = output_done[0][0];
always @(negedge e_out_psum) begin
    count_base = count_base + 1;
    count_col = 0;
end
    

reg [11:0] load_f, load_i;
reg start;

reg [11:0] ipsum_mux_sel;

PE_array_ctrl PE_array_ctrl(
    .clk(clk),
    .rst(rst),
    .P(P),
    .Q(Q), 
    .S(S), 
    .R(R),
    .r(r),
    .t(t),
    .H(H),
    .W(W),
    .begin_layer(begin_layer),
    .complete(complete_PE_con[0][0]), 
    .start(start), 
    .load_f(load_f),
    .load_i(load_i),
    .ipsum_mux_sel(ipsum_mux_sel), 
    .PE_array_complete(PE_array_complete)
);

genvar x, y;

generate
    for (y=0; y<12; y=y+1) begin
        for (x=0; x<14; x=x+1) begin
            PE pe_x_y (
                .clk(clk),
                .rst(rst),
                .ifmap(ifmap_PE_con[y][x]),
                .filt(filter_row_con[y]),
                .in_psum(ipsum_PE_con[y][x]),
                .out_psum(opsum_PE_con[y][x]),
                .start(start),
                .load_f(load_f[y]),
                .load_i(load_i[y]),
                .P(P),
                .Q(Q), 
                .S(S),
                .complete(complete_PE_con[y][x])
                );

            if (y<11) begin
                assign ipsum_PE_con[y][x] = (ipsum_mux_sel[y] == 1'b1) ? 16'd0 : opsum_PE_con[y+1][x];
            end else begin
                assign ipsum_PE_con[y][x] = 16'd0;
            end

             shift_reg shift_out ( .clk(clk),
                                  .complete(complete_PE_con[y][x]),
                                  .output_done(output_done[y][x]),
                                  .D(opsum_PE_con[y][x]),
                                  .p(P),
                                  .q0(q0[y][x]),
                                  .q1(q1[y][x]),
                                  .q2(q2[y][x]),
                                  .q3(q3[y][x]),
                                  .q4(q4[y][x]),
                                  .q5(q5[y][x]),
                                  .q6(q6[y][x]),
                                  .q7(q7[y][x]),
                                  .q8(q8[y][x]),
                                  .q9(q9[y][x]),
                                  .q10(q10[y][x]),
                                  .q11(q11[y][x]),
                                  .q12(q12[y][x]),
                                  .q13(q13[y][x]),
                                  .q14(q14[y][x]),
                                  .q15(q15[y][x]),
                                  .q16(q16[y][x]),
                                  .q17(q17[y][x]),
                                  .q18(q18[y][x]),
                                  .q19(q19[y][x]),
                                  .q20(q20[y][x]),
                                  .q21(q21[y][x]),
                                  .q22(q22[y][x]),
                                  .q23(q23[y][x]));
            
        end
    end
endgenerate



filter_bank filter_bank(
    .clk(clk),
    .P(P),
    .Q(Q),
    .S(S),
    .R(R),
    .r(r),
    .t(t),
    .en(load_f[0]), 
    .filter_out0(filter_row_con[0]),
    .filter_out1(filter_row_con[1]),
    .filter_out2(filter_row_con[2]),
    .filter_out3(filter_row_con[3]),
    .filter_out4(filter_row_con[4]),
    .filter_out5(filter_row_con[5]),
    .filter_out6(filter_row_con[6]),
    .filter_out7(filter_row_con[7]),
    .filter_out8(filter_row_con[8]),
    .filter_out9(filter_row_con[9]),
    .filter_out10(filter_row_con[10]),
    .filter_out11(filter_row_con[11])
);

genvar l, m;
generate
    for (l=0;l<12;l=l+1) begin
        for (m=l;m<l+14;m=m+1) begin
            assign ifmap_PE_con[l][m-l] = ifmap_diag_con[m];
        end
    end
endgenerate

ifmap_bank ifmap_bank (
    .clk(clk),
    .Q(Q),
    .S(S),
    .R(R),
    .r(r),
    .H(H),
    .W(W),
    .en(|load_i),
    .ifmap_out0(ifmap_diag_con[0]),
    .ifmap_out1(ifmap_diag_con[1]),
    .ifmap_out2(ifmap_diag_con[2]),
    .ifmap_out3(ifmap_diag_con[3]),
    .ifmap_out4(ifmap_diag_con[4]),
    .ifmap_out5(ifmap_diag_con[5]),
    .ifmap_out6(ifmap_diag_con[6]),
    .ifmap_out7(ifmap_diag_con[7]),
    .ifmap_out8(ifmap_diag_con[8]),
    .ifmap_out9(ifmap_diag_con[9]),
    .ifmap_out10(ifmap_diag_con[10]),
    .ifmap_out11(ifmap_diag_con[11]),
    .ifmap_out12(ifmap_diag_con[12]),
    .ifmap_out13(ifmap_diag_con[13]),
    .ifmap_out14(ifmap_diag_con[14]),
    .ifmap_out15(ifmap_diag_con[15]),
    .ifmap_out16(ifmap_diag_con[16]),
    .ifmap_out17(ifmap_diag_con[17]),
    .ifmap_out18(ifmap_diag_con[18]),
    .ifmap_out19(ifmap_diag_con[19]),
    .ifmap_out20(ifmap_diag_con[20]),
    .ifmap_out21(ifmap_diag_con[21]),
    .ifmap_out22(ifmap_diag_con[22]),
    .ifmap_out23(ifmap_diag_con[23]),
    .ifmap_out24(ifmap_diag_con[24])
);


always @(posedge clk) begin
    if (e_out_psum) begin
      // at every posedge we will load one of the values of the q0,q1,q2 ..... so on
      temp_t = 0;
      count_t = 0;
      if (temp_t == 0) begin
        count_p = 6'b000000;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q0[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q1[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q2[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q3[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q4[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q5[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q6[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q7[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q8[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q9[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q10[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q11[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q12[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q13[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q14[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q15[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q16[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q17[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q18[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q19[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q20[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q21[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q22[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q23[temp_t][count_col];
        count_p = count_p + 1;

        temp_t = temp_t + R*r;
        count_t = count_t + 1;
      end

      if (temp_t == 1) begin
        count_p = 6'b000000;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q0[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q1[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q2[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q3[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q4[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q5[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q6[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q7[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q8[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q9[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q10[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q11[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q12[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q13[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q14[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q15[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q16[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q17[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q18[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q19[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q20[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q21[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q22[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q23[temp_t][count_col];
        count_p = count_p + 1;

        temp_t = temp_t + R*r;
        count_t = count_t + 1;
      end

      if (temp_t == 2) begin
        count_p = 6'b000000;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q0[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q1[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q2[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q3[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q4[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q5[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q6[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q7[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q8[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q9[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q10[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q11[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q12[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q13[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q14[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q15[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q16[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q17[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q18[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q19[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q20[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q21[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q22[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q23[temp_t][count_col];
        count_p = count_p + 1;

        temp_t = temp_t + R*r;
        count_t = count_t + 1;
      end

      if (temp_t == 3) begin
        count_p = 6'b000000;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q0[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q1[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q2[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q3[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q4[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q5[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q6[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q7[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q8[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q9[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q10[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q11[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q12[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q13[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q14[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q15[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q16[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q17[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q18[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q19[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q20[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q21[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q22[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q23[temp_t][count_col];
        count_p = count_p + 1;

        temp_t = temp_t + R*r;
        count_t = count_t + 1;
      end

      if (temp_t == 4) begin
        count_p = 6'b000000;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q0[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q1[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q2[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q3[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q4[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q5[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q6[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q7[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q8[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q9[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q10[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q11[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q12[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q13[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q14[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q15[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q16[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q17[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q18[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q19[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q20[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q21[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q22[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q23[temp_t][count_col];
        count_p = count_p + 1;

        temp_t = temp_t + R*r;
        count_t = count_t + 1;
      end

      if (temp_t == 5) begin
        count_p = 6'b000000;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q0[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q1[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q2[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q3[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q4[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q5[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q6[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q7[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q8[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q9[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q10[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q11[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q12[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q13[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q14[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q15[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q16[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q17[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q18[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q19[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q20[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q21[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q22[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q23[temp_t][count_col];
        count_p = count_p + 1;

        temp_t = temp_t + R*r;
        count_t = count_t + 1;
      end

      if (temp_t == 6) begin
        count_p = 6'b000000;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q0[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q1[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q2[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q3[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q4[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q5[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q6[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q7[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q8[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q9[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q10[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q11[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q12[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q13[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q14[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q15[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q16[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q17[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q18[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q19[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q20[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q21[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q22[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q23[temp_t][count_col];
        count_p = count_p + 1;

        temp_t = temp_t + R*r;
        count_t = count_t + 1;
      end

      if (temp_t == 7) begin
        count_p = 6'b000000;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q0[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q1[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q2[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q3[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q4[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q5[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q6[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q7[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q8[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q9[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q10[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q11[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q12[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q13[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q14[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q15[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q16[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q17[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q18[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q19[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q20[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q21[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q22[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q23[temp_t][count_col];
        count_p = count_p + 1;

        temp_t = temp_t + R*r;
        count_t = count_t + 1;
      end

      if (temp_t == 8) begin
        count_p = 6'b000000;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q0[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q1[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q2[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q3[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q4[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q5[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q6[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q7[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q8[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q9[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q10[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q11[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q12[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q13[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q14[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q15[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q16[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q17[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q18[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q19[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q20[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q21[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q22[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q23[temp_t][count_col];
        count_p = count_p + 1;

        temp_t = temp_t + R*r;
        count_t = count_t + 1;
      end

      if (temp_t == 9) begin
        count_p = 6'b000000;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q0[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q1[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q2[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q3[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q4[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q5[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q6[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q7[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q8[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q9[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q10[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q11[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q12[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q13[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q14[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q15[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q16[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q17[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q18[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q19[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q20[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q21[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q22[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q23[temp_t][count_col];
        count_p = count_p + 1;

        temp_t = temp_t + R*r;
        count_t = count_t + 1;
      end

      if (temp_t == 10) begin
        count_p = 6'b000000;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q0[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q1[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q2[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q3[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q4[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q5[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q6[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q7[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q8[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q9[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q10[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q11[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q12[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q13[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q14[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q15[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q16[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q17[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q18[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q19[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q20[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q21[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q22[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q23[temp_t][count_col];
        count_p = count_p + 1;

        temp_t = temp_t + R*r;
        count_t = count_t + 1;
      end

      if (temp_t == 11) begin
        count_p = 6'b000000;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q0[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q1[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q2[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q3[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q4[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q5[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q6[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q7[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q8[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q9[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q10[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q11[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q12[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q13[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q14[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q15[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q16[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q17[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q18[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q19[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q20[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q21[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q22[temp_t][count_col];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q23[temp_t][count_col];
        count_p = count_p + 1;

        temp_t = temp_t + R*r;
        count_t = count_t + 1;
      end
      count_col = count_col + 1;
    end
end

endmodule