`timescale 1ns/1ps

module testbench;

    reg clk;
    reg rst;
   	reg [4:0] p   = 5'd1;
   	reg [2:0] q   = 5'd1;
   	reg [3:0] S   = 5'd3;
   	reg [4:0] R   = 5'd3;
   	reg [4:0] r   = 5'd1;
   	reg [4:0] t   = 5'd1;
   	reg [7:0] H  = 16'd5;
   	reg [7:0] W  = 16'd5;

    reg begin_layer = 1'b0;

    wire PE_array_complete;

    reg [15:0]  sum   = 16'd0;

    reg test = 1'b0;

    reg [15:0] filter[][][][];
    reg [15:0] ifmap[][][];
    reg [15:0] out_sum[][][];

    initial begin

      filter = new [p*t];

      for (int i=0;i<p*t;i=i+1) begin
        filter[i] = new [q*r];
        for (int j=0;j<q*r;j=j+1) begin
          filter[i][j] = new [R];
          for (int k=0;k<R;k=k+1) begin
            filter[i][j][k] = new [S];
          end
        end
      end

      ifmap = new [q*r];

      for (int i=0;i<q*r;i=i+1) begin
        ifmap[i] = new [H];
        for (int j=0;j<H;j=j+1) begin
          ifmap[i][j] = new [W];
        end
      end

      out_sum = new [p*t];

      for (int i=0;i<p*t;i=i+1) begin
        out_sum[i] = new [H-R+1];
        for (int j=0;j<(H-R+1);j=j+1) begin
          out_sum[i][j] = new [W-S+1];
        end
      end

    end

    PE_array dut(.clk(clk), .rst(rst), .S(S) ,.R(R),.P(p),.Q(q),.r(r),.t(t), .H(H), .W(W),.begin_layer(begin_layer), .PE_array_complete(PE_array_complete));

    integer k = 0;
    initial begin
        rst=1'b1;
        #5
        clk=1'b1;
        #20
        rst=1'b0;
        #5
        begin_layer = 1;
        #10 
        begin_layer = 0;

        #3000 $finish;
    end

    // To toggle the clock
    always begin
        #5 clk=1'b0;#5 clk = 1'b1;
    end

    reg d = 0;

    initial begin
        #1    // To help the size init to be done


        // We will create Random Values for Filter and input, then place it
        // at the right location inside the DUT Memory For it to access
        for (int i=0;i<150;i=i+1) begin
            dut.filter_bank.filter[i] = $random%50;
            $display("filter[%d] = %h", i, dut.filter_bank.filter[i]);
        end

        for (int i=0;i<100;i=i+1) begin
            dut.ifmap_bank.ifmap[i] = $random%50;
            $display("ifmap[%d] = %h", i, dut.ifmap_bank.ifmap[i]);
        end

        for (int i=0;i<p*t;i=i+1) begin
            for (int j=0;j<q*r;j=j+1) begin
                for (int k=0;k<R;k=k+1) begin
                    for (int l=0;l<S;l=l+1) begin
                        filter[i][j][k][l] = dut.filter_bank.filter[i*(q*r*R*S)+j*(R*S) + k*S + l];
                    end
                end
            end
        end

        for (int i=0;i<q*r;i=i+1) begin
            for (int j=0;j<H;j=j+1) begin
                for (int k=0;k<W;k=k+1) begin
                ifmap[i][j][k] = dut.ifmap_bank.ifmap[i*(H*W)+j*(W)+k];
                end
            end
        end

        #2 // Verification result calculation
        // Get the expected result and store it in the out_sum variable
        // Nornal For loop Implementation of Convolution
        for (int i=0;i<p*t;i=i+1) begin
            for (int j=0;j<(H-R+1);j=j+1) begin
                for (int k=0;k<(W-S+1);k=k+1) begin
                sum = 0;
                    for (int d=0;d<q*r;d=d+1) begin
                        for (int e=j;e<j+R;e=e+1) begin
                            for (int f=k;f<k+S;f=f+1) begin
                                //$display(ifmap[d][e-j][f-k]* filter[i][d][e-j][f-k]);
                                sum = sum + ifmap[d][e][f]* filter[i][d][e-j][f-k];
                            end
                        end
                    end
                out_sum [i][j][k] = sum;
                end
            end
        end

    #2500 ;

    // Compare the two results
    for (int i=0;i<p*t;i=i+1) begin
        for (int j=0;j<(H-R+1);j=j+1) begin
            for (int k=0;k<(W-S+1);k=k+1) begin
                d = (i/t)*p;
                //$display( i ,j,k, d+p-1-i );
                //$display(out_sum[i][j][k]);
                //$display(dut.out_psum[d+p-1-i][j*(W-S+1)+k]);
                if (out_sum[i][j][k] != dut.out_psum[d+p-1-i][j*(W-S+1)+k])  begin
                    $display("Incorrect Result:i[%d]j[%d]k[%d] %h, correct Result %h", i, j, k, dut.out_psum[d+p-1-i][j*(W-S+1)+k], out_sum[i][j][k]);
                    test = 1'b1;
                end else begin
                    $display("CORRECT! Incorrect Result:i[%d]j[%d]k[%d] %h, correct Result %h", i, j, k, dut.out_psum[d+p-1-i][j*(W-S+1)+k], out_sum[i][j][k]);
                end

            end
        end
    end
    if(test == 0 )
    $display("ALL Values Match !!!");
    end

endmodule