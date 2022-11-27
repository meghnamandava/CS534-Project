module PE (
    input clk,
    input rst,
    input [15:0] in_ifmap,
    input [15:0] in_filt,
    input [15:0] in_psum,
    output [15:0] out_ifmap,
    output [15:0] out_psum,
    output [15:0] out_filt,
    input start,
    input load_f,
    input load_i,
    output complete 

) ;

reg [15:0] filt_reg;
reg [15:0] ifmap_reg;
reg [15:0] psum_reg;

assign out_ifmap = ifmap_reg;
assign out_filt = filt_reg;
assign out_psum = psum_reg;

always @(posedge clk) begin
    if (rst) begin
        filt_reg <= 0;
        ifmap_reg <= 0;
        psum_reg <= 0;
    end
    if (load_f) begin
        filt_reg <= in_filt;
    end 
    else if (load_i && start) begin
        ifmap_reg <= in_ifmap;
        psum_reg <= in_psum + (filt_reg * in_ifmap);
    end 
    else begin
        //filt_reg <= 0;
        ifmap_reg <= 0;
        psum_reg <= 0;
    end
end

endmodule