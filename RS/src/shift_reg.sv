/*
    shift_reg has been implemented which loads value one by one and stores in different outputs
    It takes data from single line and has 24 output ports because 24 is the maximum value that p can take
    clk : input clock load_signal
    complete : input to indicating to stop reading values
    output_done :
    D : input line which brings data into the module
    p : input, no of different filters processes by a PE
    q0,q1 ..... q23 : 24 output wires, which store the values of different filters calculated by the PE
*/
module shift_reg (
  input clk,complete,
  input [15:0] D,
  input [4:0] p,
  output [15:0] q [23:0],
  output reg output_done = 1'b0
);


  //reg [3:0] d [23:0]; // input wire of the 24 registers
  wire [15:0] q [23:0]; // output wire of the 24 registers

  reg en = 0;
  //wire en;
  reg [4:0] count = 5'd0;

  always@(negedge complete)
  begin

    en = 1'b1;
  end

  always@(posedge complete)
  begin
     count = 0 ;
  end

  always@(posedge clk)
  begin
    if(en == 1 )
    begin
        count = count + 1;
        if (count ==  p+1)
            en = 0;
    end

  end
  reg [3:0] count2 = 4'b0;

  always@(negedge en)
  begin
    output_done=1'b1;
  end

  always@(posedge clk)
  begin
    if(output_done ==1)
    begin
      if(count2<p)
          count2= count2+1;
      else
      begin
          count2=0;
          output_done = 0;
      end
    end
  end



  register r0(.clk(clk),.en(en),.d(D),.q(q[0]));


  genvar r;
  generate
    for (r=1;r<24;r=r+1) begin
      register rx (.clk(clk),.en(en),.d(q[r-1]),.q(q[r]));
    end
  endgenerate

endmodule