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

wire [15:0] ipsum_PE_con [11:0][13:0]; //connection for each PE ipsum
wire [15:0] opsum_PE_con [11:0][13:0]; //connection for each PE opsum

//wire complete_PE_con [11:0][13:0]; //connection for each PE complete signal

reg [13:0] load_f;
reg [11:0] load_i;
reg [11:0] load_i_in_con [13:0] ;
reg [11:0] load_i_out_con [13:0] ;
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
                .in_psum(ipsum_PE_con[y][x]),
                .out_ifmap(oifmap_PE_con[y][x]),
                .out_filt(ofilter_PE_con[y][x]),
                .out_psum(opsum_PE_con[y][x]),
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
                assign ipsum_PE_con[y][x] = 16'b0;
                assign ifilter_PE_con[y] = filter_col_con;
            end else begin
                assign ipsum_PE_con[y] = opsum_PE_con[y-1];
                assign ifilter_PE_con[y] = ofilter_PE_con[y-1];
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
    .filter_out(filter_col_con)
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
    .ifmap_out(ifmap_row_con)
);

//TODO shift reg for outputs

endmodule