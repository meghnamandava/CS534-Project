module ifmap_bank (
    input clk,
    input rst,
    input [8:0] M,    // # filters / # ofmap channels
    input [8:0] C,    // # ifmap/filter channels
    input [7:0] H, W, // height and width of ifmap
    input [3:0] R, S, // height and width of filter
    input [3:0] P,    // # filters processed by array
    input [3:0] Q,    // # filter elems processed by column
    input en,
    output [15:0] ifmap_out0, ifmap_out1, ifmap_out2, ifmap_out3, ifmap_out4, ifmap_out5, ifmap_out6, ifmap_out7, ifmap_out8, ifmap_out9, ifmap_out10, ifmap_out11
);

    reg [15:0] ifmap_out [11:0];
 
    assign ifmap_out0 = ifmap_out[0];
    assign ifmap_out1 = ifmap_out[1];
    assign ifmap_out2 = ifmap_out[2];
    assign ifmap_out3 = ifmap_out[3];
    assign ifmap_out4 = ifmap_out[4];
    assign ifmap_out5 = ifmap_out[5];
    assign ifmap_out6 = ifmap_out[6];
    assign ifmap_out7 = ifmap_out[7];
    assign ifmap_out8 = ifmap_out[8];
    assign ifmap_out9 = ifmap_out[9];
    assign ifmap_out10 = ifmap_out[10];
    assign ifmap_out11 = ifmap_out[11];

    wire [6:0] filter_size; //max size 121
    assign filter_size = R*S;
    wire [9:0] channels_in_pass;
    assign channels_in_pass = (filter_size > Q) ? 1 : Q/filter_size;
    wire [9:0] num_windows;
    assign num_windows = W-S+1;

    reg [15:0] ifmap [1023:0];

    reg [7:0] count_H = 0;
    reg [7:0] count_W = 0;
    reg [7:0] count_H_temp = 0;
    reg [7:0] count_W_temp = 0;
    reg [3:0] count_R = 0;
    reg [3:0] count_S = 0;
    reg [8:0] count_C = 0;

    //registers to stagger outputs
    reg [15:0] ifmap_out_reg [11:0][11:0];

    integer i,j;

    always @(posedge clk) begin
        if (rst) begin
            count_H = 0;
            count_W = 0;
            count_H_temp = 0;
            count_W_temp = 0;
            count_R = 0;
            count_S = 0;
            count_C = 0;
            for (i=0;i<12;i=i+1) begin
                for (j=0;j<12;j=j+1) begin
                    ifmap_out_reg[i][i] = 16'h0000;
                end
                ifmap_out[i] <= ifmap_out_reg[i][i];
            end
        end else if (en) begin
            //elem num in filter window, en should stop at Q and bank will continue when en goes high again
            
            
            //row 0

            count_H_temp = count_H;
            count_W_temp = count_W;

            for (i=0;i<12;i=i+1) begin
                //if (i > (12-Q)) begin
                    
                    ifmap_out_reg[0][i] = ifmap[count_C*(H*W)+(count_H+count_R)*W + (count_W+count_S)];

                    if (count_W == num_windows-1) begin
                        count_W = 0;
                        if (count_H == num_windows-1) begin
                            count_H = 0;
                        end else begin
                            count_H = count_H + 1;
                        end
                    end else begin
                        count_W = count_W + 1;
                    end
                //end

            end

            count_H = count_H_temp;
            count_W = count_W_temp;
            /*ifmap_out_reg[0][0] = ifmap[count_C*(H*W)+(count_H+count_R)*W + (count_W+count_S)];

            if (count_W == num_windows-1) begin
                count_W = 0;
                if (count_H == num_windows-1) begin
                    count_H = 0;
                end else begin
                    count_H = count_H + 1;
                end
            end

            //row 1
            ifmap_out_reg[0][1] = ifmap[count_C*(H*W)+(count_H+count_R)*W + (count_W+count_S)];

            if (count_W == num_windows-1) begin
                count_W = 0;
                if (count_H == num_windows-1) begin
                    count_H = 0;
                end else begin
                    count_H = count_H + 1;
                end
            end

            //row 2
            ifmap_out_reg[0][2] = ifmap[count_C*(H*W)+(count_H+count_R)*W + (count_W+count_S)];

            if (count_W == num_windows-1) begin
                count_W = 0;
                if (count_H == num_windows-1) begin
                    count_H = 0;
                end else begin
                    count_H = count_H + 1;
                end
            end

            //row 3
            ifmap_out_reg[0][3] = ifmap[count_C*(H*W)+(count_H+count_R)*W + (count_W+count_S)];

            if (count_W == num_windows-1) begin
                count_W = 0;
                if (count_H == num_windows-1) begin
                    count_H = 0;
                end else begin
                    count_H = count_H + 1;
                end
            end

            //row 4
            ifmap_out_reg[0][4] = ifmap[count_C*(H*W)+(count_H+count_R)*W + (count_W+count_S)];

            if (count_W == num_windows-1) begin
                count_W = 0;
                if (count_H == num_windows-1) begin
                    count_H = 0;
                end else begin
                    count_H = count_H + 1;
                end
            end


            //row 5
            ifmap_out_reg[0][5] = ifmap[count_C*(H*W)+(count_H+count_R)*W + (count_W+count_S)];

            if (count_W == num_windows-1) begin
                count_W = 0;
                if (count_H == num_windows-1) begin
                    count_H = 0;
                end else begin
                    count_H = count_H + 1;
                end
            end


            //row 6
            ifmap_out_reg[0][6] = ifmap[count_C*(H*W)+(count_H+count_R)*W + (count_W+count_S)];

            if (count_W == num_windows-1) begin
                count_W = 0;
                if (count_H == num_windows-1) begin
                    count_H = 0;
                end else begin
                    count_H = count_H + 1;
                end
            end


            //row 7
            ifmap_out_reg[0][7] = ifmap[count_C*(H*W)+(count_H+count_R)*W + (count_W+count_S)];

            if (count_W == num_windows-1) begin
                count_W = 0;
                if (count_H == num_windows-1) begin
                    count_H = 0;
                end else begin
                    count_H = count_H + 1;
                end
            end


            //row 8
            ifmap_out_reg[0][8] = ifmap[count_C*(H*W)+(count_H+count_R)*W + (count_W+count_S)];

            if (count_W == num_windows-1) begin
                count_W = 0;
                if (count_H == num_windows-1) begin
                    count_H = 0;
                end else begin
                    count_H = count_H + 1;
                end
            end


            //row 9
            ifmap_out_reg[0][9] = ifmap[count_C*(H*W)+(count_H+count_R)*W + (count_W+count_S)];

            if (count_W == num_windows-1) begin
                count_W = 0;
                if (count_H == num_windows-1) begin
                    count_H = 0;
                end else begin
                    count_H = count_H + 1;
                end
            end


            //row 10
            ifmap_out_reg[0][10] = ifmap[count_C*(H*W)+(count_H+count_R)*W + (count_W+count_S)];

            if (count_W == num_windows-1) begin
                count_W = 0;
                if (count_H == num_windows-1) begin
                    count_H = 0;
                end else begin
                    count_H = count_H + 1;
                end
            end


            //row 11
            ifmap_out_reg[0][11] = ifmap[count_C*(H*W)+(count_H+count_R)*W + (count_W+count_S)];

            if (count_W == num_windows-1) begin
                count_W = 0;
                if (count_H == num_windows-1) begin
                    count_H = 0;
                end else begin
                    count_H = count_H + 1;
                end
            end*/

            if (count_C == C-1) begin
                count_C = 0;
            end else begin
                count_C = count_C + 1;
            end

            for (i = 0; i < 12; i=i+1) begin
                for (j = 1; j < 12; j=j+1) begin
                    ifmap_out_reg[j][i] = ifmap_out_reg[j-1][i];
                end 
                ifmap_out[i] <= ifmap_out_reg[i][i];
            end

            if (count_S == S-1) begin
                count_S = 0;
                if (count_R == R-1) begin
                    count_R = 0;
                end else begin
                    count_R = count_R + 1;
                end
            end else begin 
                count_S = count_S + 1;
            end
            
        end else begin
            for (i = 0; i < 12; i =i+ 1) begin
                ifmap_out_reg[0][i] = 16'b0;
            end
        end
        
    end  

endmodule