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


wire [15:0] q  [11:0][13:0][23:0];            // Connections of output shift reg

reg [15:0] out_psum [20:0][100:0];

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
                                  .q(q[y][x]));
            
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
    .filter_out(filter_row_con)
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
    .ifmap_out(ifmap_diag_con)
);


always @(posedge clk) begin
    if (e_out_psum) begin
      // at every posedge we will load one of the values of the q0,q1,q2 ..... so on
      temp_t = 0;
      count_t = 0;
      if (temp_t == 0) begin
        count_p = 6'b000000;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][0];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][1];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][2];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][3];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][4];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][5];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][6];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][7];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][8];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][9];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][10];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][11];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][12];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][13];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][14];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][15];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][16];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][17];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][18];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][19];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][20];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][21];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][22];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][23];
        count_p = count_p + 1;

        temp_t = temp_t + R*r;
        count_t = count_t + 1;
      end

      if (temp_t == 1) begin
        count_p = 6'b000000;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][0];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][1];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][2];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][3];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][4];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][5];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][6];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][7];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][8];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][9];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][10];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][11];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][12];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][13];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][14];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][15];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][16];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][17];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][18];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][19];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][20];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][21];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][22];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][23];
        count_p = count_p + 1;

        temp_t = temp_t + R*r;
        count_t = count_t + 1;
      end

      if (temp_t == 2) begin
        count_p = 6'b000000;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][0];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][1];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][2];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][3];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][4];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][5];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][6];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][7];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][8];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][9];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][10];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][11];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][12];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][13];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][14];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][15];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][16];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][17];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][18];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][19];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][20];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][21];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][22];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][23];
        count_p = count_p + 1;

        temp_t = temp_t + R*r;
        count_t = count_t + 1;
      end

      if (temp_t == 3) begin
        count_p = 6'b000000;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][0];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][1];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][2];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][3];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][4];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][5];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][6];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][7];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][8];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][9];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][10];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][11];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][12];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][13];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][14];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][15];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][16];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][17];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][18];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][19];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][20];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][21];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][22];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][23];
        count_p = count_p + 1;

        temp_t = temp_t + R*r;
        count_t = count_t + 1;
      end

      if (temp_t == 4) begin
        count_p = 6'b000000;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][0];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][1];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][2];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][3];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][4];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][5];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][6];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][7];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][8];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][9];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][10];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][11];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][12];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][13];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][14];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][15];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][16];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][17];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][18];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][19];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][20];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][21];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][22];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][23];
        count_p = count_p + 1;

        temp_t = temp_t + R*r;
        count_t = count_t + 1;
      end

      if (temp_t == 5) begin
        count_p = 6'b000000;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][0];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][1];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][2];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][3];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][4];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][5];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][6];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][7];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][8];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][9];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][10];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][11];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][12];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][13];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][14];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][15];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][16];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][17];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][18];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][19];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][20];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][21];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][22];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][23];
        count_p = count_p + 1;

        temp_t = temp_t + R*r;
        count_t = count_t + 1;
      end

      if (temp_t == 6) begin
        count_p = 6'b000000;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][0];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][1];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][2];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][3];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][4];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][5];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][6];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][7];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][8];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][9];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][10];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][11];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][12];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][13];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][14];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][15];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][16];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][17];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][18];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][19];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][20];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][21];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][22];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][23];
        count_p = count_p + 1;

        temp_t = temp_t + R*r;
        count_t = count_t + 1;
      end

      if (temp_t == 7) begin
        count_p = 6'b000000;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][0];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][1];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][2];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][3];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][4];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][5];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][6];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][7];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][8];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][9];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][10];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][11];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][12];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][13];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][14];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][15];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][16];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][17];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][18];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][19];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][20];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][21];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][22];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][23];
        count_p = count_p + 1;

        temp_t = temp_t + R*r;
        count_t = count_t + 1;
      end

      if (temp_t == 8) begin
        count_p = 6'b000000;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][0];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][1];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][2];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][3];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][4];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][5];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][6];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][7];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][8];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][9];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][10];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][11];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][12];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][13];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][14];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][15];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][16];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][17];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][18];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][19];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][20];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][21];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][22];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][23];
        count_p = count_p + 1;

        temp_t = temp_t + R*r;
        count_t = count_t + 1;
      end

      if (temp_t == 9) begin
        count_p = 6'b000000;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][0];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][1];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][2];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][3];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][4];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][5];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][6];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][7];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][8];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][9];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][10];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][11];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][12];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][13];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][14];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][15];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][16];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][17];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][18];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][19];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][20];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][21];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][22];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][23];
        count_p = count_p + 1;

        temp_t = temp_t + R*r;
        count_t = count_t + 1;
      end

      if (temp_t == 10) begin
        count_p = 6'b000000;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][0];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][1];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][2];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][3];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][4];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][5];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][6];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][7];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][8];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][9];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][10];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][11];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][12];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][13];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][14];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][15];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][16];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][17];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][18];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][19];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][20];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][21];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][22];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][23];
        count_p = count_p + 1;

        temp_t = temp_t + R*r;
        count_t = count_t + 1;
      end

      if (temp_t == 11) begin
        count_p = 6'b000000;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][0];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][1];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][2];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][3];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][4];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][5];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][6];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][7];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][8];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][9];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][10];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][11];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][12];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][13];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][14];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][15];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][16];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][17];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][18];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][19];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][20];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][21];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][22];
        count_p = count_p + 1;
        out_psum[count_t*P + count_p][count_col*(W-S+1) + count_base] = q[temp_t][count_col][23];
        count_p = count_p + 1;

        temp_t = temp_t + R*r;
        count_t = count_t + 1;
      end
      count_col = count_col + 1;
    end
end

endmodule