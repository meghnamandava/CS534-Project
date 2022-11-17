module counter (
    input clk,
    input rst,
    input [9:0] size,
    output [9:0] out

);

reg [9:0] out = 10'b0000000000;
always @(posedge clk) begin
    if (rst) begin
        out <= 10'b0000000000;
    end
    else begin
        if (out==size) begin
            out <= 10'b0000000000
        end
        else begin
            out <= out + 1;
        end
    end
end


endmodule