module PE_array(
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
    output PE_array_complete
);

reg [15:0] filter_col_con [13:0];       //connection for filter for each column from filter bank
wire [15:0] ifilter_PE_con [11:0][13:0]; //connection for each PE filter
wire [15:0] ofilter_PE_con [11:0][13:0]; //connection for each PE filter

reg [15:0] ifmap_row_con [11:0];       //connection for ifmap for each row from ifmap bank
wire [15:0] iifmap_PE_con [11:0][13:0]; //connection for each PE ifmap
wire [15:0] oifmap_PE_con [11:0][13:0]; //connection for each PE ifmap

wire [15:0] ipsum_PE_con [13:0][11:0]; //connection for each PE ipsum
wire [15:0] opsum_PE_con [13:0][11:0]; //connection for each PE opsum

reg [15:0] out_psum [13:0][168:0]; // each row holds 169 opsums

//wire complete_PE_con [11:0][13:0]; //connection for each PE complete signal

reg [13:0] load_f;
reg [11:0] load_i;
reg [13:0] load_o;
wire [11:0] load_i_in_con [13:0] ;
wire [11:0] load_i_out_con [13:0] ;
reg start;
reg PE_pass_complete;

PE_array_ctrl PE_array_ctrl(
    .clk(clk),
    .rst(rst),
    .M(M),
    .C(C), 
    .R(R),
    .S(S), 
    .E(E),
    .F(F),
    .H(H),
    .W(W),
    .P(P),
    .Q(Q),
    .begin_layer(begin_layer),
    .continue_layer(continue_layer),
    //.complete(complete_PE_con[0][0]), 
    .start(start), 
    .load_f(load_f),
    .load_i(load_i),
    .load_o(load_o),
    .PE_pass_complete(PE_pass_complete),
    .PE_array_complete(PE_array_complete)
);
genvar x, y;
generate
    for (y=0; y<12; y=y+1) begin
        for (x=0; x<14; x=x+1) begin
            PE pe_x_y (
                .clk(clk),
                .rst(rst),
                .in_ifmap(iifmap_PE_con[y][x]),
                .in_filt(ifilter_PE_con[y][x]),
                .in_psum(ipsum_PE_con[x][y]),
                .out_ifmap(oifmap_PE_con[y][x]),
                .out_filt(ofilter_PE_con[y][x]),
                .out_psum(opsum_PE_con[x][y]),
                .start(start),
                .load_f(load_f[x]),
                .load_i_in(load_i_in_con[x][y]),
                .load_i_out(load_i_out_con[x][y])
                //.complete(complete_PE_con[y][x])
                );

            if (x == 0) begin
                assign load_i_in_con[x][y] = load_i[y];
                assign iifmap_PE_con[y][x] = ifmap_row_con[y];
            end else begin
                assign load_i_in_con[x][y] = load_i_out_con[x-1][y];
                assign iifmap_PE_con[y][x] = oifmap_PE_con[y][x-1];
            end

            if (y == 0) begin
                assign ipsum_PE_con[x][y] = 16'b0;
                //assign ifilter_PE_con[y] = filter_col_con;
            end else begin 
                assign ipsum_PE_con[x][y] = opsum_PE_con[x][y-1];
            end
            
            if (y == 11) begin
                assign ifilter_PE_con[y][x] = filter_col_con[x];
            end else begin
                assign ifilter_PE_con[y][x] = ofilter_PE_con[y+1][x];
            end
            
        end
    end
endgenerate

filter_bank filter_bank(
    .clk(clk),
    .rst(rst),
    .P(P),
    .Q(Q),
    .S(S),
    .R(R),
    .M(M),
    .C(C),
    .en(load_f[0]), 
    .filter_out0(filter_col_con[0]),
    .filter_out1(filter_col_con[1]),
    .filter_out2(filter_col_con[2]),
    .filter_out3(filter_col_con[3]),
    .filter_out4(filter_col_con[4]),
    .filter_out5(filter_col_con[5]),
    .filter_out6(filter_col_con[6]),
    .filter_out7(filter_col_con[7]),
    .filter_out8(filter_col_con[8]),
    .filter_out9(filter_col_con[9]),
    .filter_out10(filter_col_con[10]),
    .filter_out11(filter_col_con[11]),
    .filter_out12(filter_col_con[12]),
    .filter_out13(filter_col_con[13])
    
);

ifmap_bank ifmap_bank(
    .clk(clk),
    .rst(rst),
    .P(P),
    .Q(Q),
    .S(S),
    .R(R),
    .H(H),
    .W(W),
    .M(M),
    .C(C),
    .en(start), 
    .ifmap_out0(ifmap_row_con[0]),
    .ifmap_out1(ifmap_row_con[1]),
    .ifmap_out2(ifmap_row_con[2]),
    .ifmap_out3(ifmap_row_con[3]),
    .ifmap_out4(ifmap_row_con[4]),
    .ifmap_out5(ifmap_row_con[5]),
    .ifmap_out6(ifmap_row_con[6]),
    .ifmap_out7(ifmap_row_con[7]),
    .ifmap_out8(ifmap_row_con[8]),
    .ifmap_out9(ifmap_row_con[9]),
    .ifmap_out10(ifmap_row_con[10]),
    .ifmap_out11(ifmap_row_con[11])
);

//collect output results in ofmap bank
integer i,j;
always @(posedge clk) begin
    for (i = 0; i < 14; i=i+1) begin
        if (load_o[i]) begin
            out_psum[i][0] <= opsum_PE_con[i][Q-1];
        end else begin
            out_psum[i][0] <= out_psum[i][0];
        end
        for (j= 1; j < 169; j=j+1) begin
            if (rst) begin
                out_psum[i][j] <= 16'h0000;
            end else if (load_o[i]) begin
                out_psum[i][j] <= out_psum[i][j-1];
            end
        end
    end
    
end

endmodule