module scratchpad #(parameter ADDR=4, 
    parameter DATA_WIDTH=16,
    parameter SPADSIZE=12) 
    
    (
    input                   clk,
    input                   rst,
    input [ADDR-1:0]        addr,
    input                   we,
    input [DATA_WIDTH-1:0]  data_in,
    output [DATA_WIDTH-1:0] data_out;
    );

    reg [DATA_WIDTH-1:0] spad_mem [SPADSIZE-1:0];

    always @ (posedge clk) begin
        if (rst) begin
            data_out <= 0;
        end
        else if (we) begin
            spad_mem[addr] <= data_in;
        end
        else begin
            data_out <= spad_mem[addr];
        end
    end

endmodule