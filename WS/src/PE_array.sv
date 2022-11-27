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
    output PE_array_complete
);

wire [15:0] ifilter_PE_con [11:0][13:0]; //connection for each PE filter
wire [15:0] ofilter_PE_con [11:0][13:0]; //connection for each PE filter

wire [15:0] iifmap_PE_con [11:0][13:0]; //connection for each PE ifmap
wire [15:0] iofmap_PE_con [11:0][13:0]; //connection for each PE ifmap

wire [15:0] ipsum_PE_con [11:0][13:0]; //connection for each PE ipsum
wire [15:0] opsum_PE_con [11:0][13:0]; //connection for each PE opsum

wire complete_PE_con [11:0][13:0]; //connection for each PE complete signal

reg [13:0] load_f;
reg [11:0] load_i;

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
    .complete(complete_PE_con[0][0]), 
    .start(start), 
    .load_f(load_f),
    .load_i(load_i),
    .PE_array_complete(PE_array_complete)
);

generate
    for (y=0; y<12; y=y+1) begin
        for (x=0; x<14; x=x+1) begin
            PE pe_x_y (
                .clk(clk),
                .rst(rst),
                .in_ifmap(iifmap_PE_con[y][x]),
                .in_filt(ifilter_row_con[y]),
                .in_psum(ipsum_PE_con[y][x]),
                .out_ifmap(oifmap_PE_con[y][x]),
                .out_filt(ofilter_row_con[y]),
                .out_psum(opsum_PE_con[y][x]),
                .start(start),
                .load_f(load_f[y]),
                .load_i(load_i[y]),
                .complete(complete_PE_con[y][x])
                );
            
        end
    end
endgenerate

endmodule