module scratchpad #(parameter ADDR=4, 
    parameter DATA_WIDTH=16,
    parameter SPADSIZE=12) 
    
    (
    input                   clk,
    input                   rst,
    input [ADDR-1:0]        addr,
    input                   we,
    input [DATA_WIDTH-1:0]  data_in,
    output reg [DATA_WIDTH-1:0] data_out
    );

    reg [DATA_WIDTH-1:0] spad_mem [SPADSIZE-1:0];
    integer i;
    always @ (posedge clk) begin
        if (rst) begin
            begin
                for (i=0; i<SPADSIZE; i=i+1) spad_mem[i] <= {DATA_WIDTH{1'b0}};
            end
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