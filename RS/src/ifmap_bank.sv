module ifmap_bank (
    input clk,
    input [2:0] Q, // # channels of a particular filter processed by PE set
    input [3:0] S, // filter width
    input [4:0] R, // filter height
    input [4:0] r, //# PE sets in array proc diff channels of a filter
    input [7:0] H, W, //height and width of filter
    input en,
    output reg [15:0] ifmap_out [24:0]
);

    reg [15:0] ifmap [51528:0]; //max H/W is 227

    reg [9:0] count   = 10'd0; // base value of the sliding window of the ifmap
    reg [9:0] count2  = 10'd0;
    reg [9:0] count_q = 10'd0; // to keep record of parameter Q traversed
    reg [9:0] count_s = 10'd0; // to keep record of parameter s traversed
    reg [9:0] count_r = 10'd0; // to keep record of parameter r traversed
    reg [9:0] temp    = 10'd0;

    reg [3:0]   pe_set_base = 4'b0000; // PE set base value which gets incremented by r after each Q*s cycles

    always @(posedge en) begin

        count       = count + 1;
        pe_set_base = 4'b0000;

        if (count == W-S+1)
            count = 0;
    end

    always @(posedge clk) begin
        if (en) begin

            // we assign all the 25 wires according to the division of different PE sets
            // declare temp and count2
            count2  = 4'b0000;
            temp    = pe_set_base;

            if (temp == 0) begin
                if (count2<H) begin

                    ifmap_out[0]      = ifmap[count_r*Q*H*W + count_q*W*H + count2*W + count_s + count];
                    count2  = count2+1;
                    temp    = temp+1;
                end
                else
                    ifmap_out[0]      = 0;
            end
            else begin
                ifmap_out[0] = 0;
            end

            if (temp == 1) begin
                if (count2<H) begin
                    ifmap_out[1]      = ifmap[count_r*Q*H*W + count_q*W*H + count2*W + count_s + count];
                    count2  = count2+1;
                    temp    = temp+1;
                end
                else
                    ifmap_out[1]      = 0;
            end
            else begin
                ifmap_out[1] = 0;
            end

            if (temp == 2) begin
                if (count2<H) begin
                    ifmap_out[2]     = ifmap[count_r*Q*H*W + count_q*W*H + count2*W + count_s + count];
                    count2  = count2+1;
                    temp    = temp+1;
                end
                else
                    ifmap_out[2]      = 0;
            end
            else begin
                ifmap_out[2] = 0;
            end

            if (temp == 3) begin
                if (count2<H) begin
                    ifmap_out[3]      = ifmap[count_r*Q*H*W + count_q*W*H + count2*W + count_s + count];
                    count2  = count2+1;
                    temp    = temp+1;
                end
                else
                    ifmap_out[3]      = 0;
            end
            else begin
                ifmap_out[3] = 0;
            end

            if (temp == 4) begin
                if (count2<H) begin
                    ifmap_out[4]      = ifmap[count_r*Q*H*W + count_q*W*H + count2*W + count_s + count];
                    count2  = count2+1;
                    temp    = temp+1;
                end
                else
                    ifmap_out[4]      = 0;
            end
            else begin
                ifmap_out[4] = 0;
            end

            if (temp == 5) begin
                if (count2<H) begin
                    ifmap_out[5]      = ifmap[count_r*Q*H*W + count_q*W*H + count2*W + count_s + count];
                    count2  = count2+1;
                    temp    = temp+1;
                end
                else
                    ifmap_out[5]      = 0;
            end
            else begin
                ifmap_out[5] = 0;
            end

            if (temp == 6) begin
                if (count2<H) begin
                    ifmap_out[6]      = ifmap[count_r*Q*H*W + count_q*W*H + count2*W + count_s + count];
                    count2  = count2+1;
                    temp    = temp+1;
                end
                else
                    ifmap_out[6]      = 0;
            end
            else begin
                ifmap_out[6] = 0;
            end

            if (temp == 7) begin
                if (count2<H) begin
                    ifmap_out[7]      = ifmap[count_r*Q*H*W + count_q*W*H + count2*W + count_s + count];
                    count2  = count2+1;
                    temp    = temp+1;
                end
                else
                    ifmap_out[7]      = 0;
            end
            else begin
                ifmap_out[7] = 0;
            end

            if (temp == 8) begin
                if (count2<H) begin
                    ifmap_out[8]      = ifmap[count_r*Q*H*W + count_q*W*H + count2*W + count_s + count];
                    count2  = count2+1;
                    temp    = temp+1;
                end
                else
                    ifmap_out[8]      = 0;
            end
            else begin
                ifmap_out[8] = 0;
            end

            if (temp == 9) begin
                if (count2<H) begin
                    ifmap_out[9]      = ifmap[count_r*Q*H*W + count_q*W*H + count2*W + count_s + count];
                    count2  = count2+1;
                    temp    = temp+1;
                end
                else
                    ifmap_out[9]      = 0;
            end
            else begin
                ifmap_out[9] = 0;
            end

            if (temp == 10) begin
                if (count2<H) begin
                    ifmap_out[10]     = ifmap[count_r*Q*H*W + count_q*W*H + count2*W + count_s + count];
                    count2  = count2+1;
                    temp    = temp+1;
                end
                else
                    ifmap_out[10] = 0;
            end
            else begin
                ifmap_out[10] = 0;
            end

            if (temp == 11) begin
                if (count2<H) begin
                    ifmap_out[11]     = ifmap[count_r*Q*H*W + count_q*W*H + count2*W + count_s + count];
                    count2  = count2+1;
                    temp    = temp+1;
                end
                else
                    ifmap_out[11] = 0;
            end
            else begin
                ifmap_out[11] = 0;
            end

            if (temp == 12) begin
                if (count2<H) begin
                    ifmap_out[12]     = ifmap[count_r*Q*H*W + count_q*W*H + count2*W + count_s + count];
                    count2  = count2+1;
                    temp    = temp+1;
                end
                else
                    ifmap_out[12]     = 0;
            end
            else begin
                ifmap_out[12] = 0;
            end

            if (temp == 13) begin
                if (count2<H) begin
                    ifmap_out[13]     = ifmap[count_r*Q*H*W + count_q*W*H + count2*W + count_s + count];
                    count2  = count2+1;
                    temp    = temp+1;
                end
                else
                    ifmap_out[13]     = 0;
            end
            else begin
                ifmap_out[13] = 0;
            end

            if (temp == 14) begin
                if (count2<H) begin
                    ifmap_out[14]     = ifmap[count_r*Q*H*W + count_q*W*H + count2*W + count_s + count];
                    count2  = count2+1;
                    temp    = temp+1;
                end
                else
                    ifmap_out[14]     = 0;
            end
            else begin
                ifmap_out[14] = 0;
            end

            if (temp == 15) begin
                if (count2<H) begin
                    ifmap_out[15]     = ifmap[count_r*Q*H*W + count_q*W*H + count2*W + count_s + count];
                    count2  = count2+1;
                    temp    = temp+1;
                end
                else
                    ifmap_out[15]     = 0;
            end
            else begin
                ifmap_out[15] = 0;
            end

            if (temp == 16) begin
                if (count2<H) begin
                    ifmap_out[16]     = ifmap[count_r*Q*H*W + count_q*W*H + count2*W + count_s + count];
                    count2  = count2+1;
                    temp    = temp+1;
                end
                else
                    ifmap_out[16]     = 0;
            end
            else begin
                ifmap_out[16] = 0;
            end

            if (temp == 17) begin
                if (count2<H) begin
                    ifmap_out[17]     = ifmap[count_r*Q*H*W + count_q*W*H + count2*W + count_s + count];
                    count2  = count2+1;
                    temp    = temp+1;
                end
                else
                    ifmap_out[17]     = 0;
            end
            else begin
                ifmap_out[17] = 0;
            end

            if (temp == 18) begin
                if (count2<H) begin
                    ifmap_out[18]     = ifmap[count_r*Q*H*W + count_q*W*H + count2*W + count_s + count];
                    count2  = count2+1;
                    temp    = temp+1;
                end
                else
                    ifmap_out[18]     = 0;
            end
            else begin
                ifmap_out[18] = 0;
            end

            if (temp == 19) begin
                if (count2<H) begin
                    ifmap_out[19]     = ifmap[count_r*Q*H*W + count_q*W*H + count2*W + count_s + count];
                    count2  = count2+1;
                    temp    = temp+1;
                end
                else
                    ifmap_out[19]     = 0;
            end
            else begin
                ifmap_out[19] = 0;
            end

            if (temp == 20) begin
                if (count2<H) begin
                    ifmap_out[20]     = ifmap[count_r*Q*H*W + count_q*W*H + count2*W + count_s + count];
                    count2  = count2+1;
                    temp    = temp+1;
                end
                else
                    ifmap_out[20]     = 0;
            end
            else begin
                ifmap_out[20]         = 0;
            end

            if (temp == 21) begin
                if (count2<H) begin
                    ifmap_out[21]     = ifmap[count_r*Q*H*W + count_q*W*H + count2*W + count_s + count];
                    count2  = count2+1;
                    temp    = temp+1;
                end
                else
                    ifmap_out[21]     = 0;
            end
            else begin
                ifmap_out[21] = 0;
            end

            if (temp == 22) begin
                if (count2<H) begin
                    ifmap_out[22]     = ifmap[count_r*Q*H*W + count_q*W*H + count2*W + count_s + count];
                    count2  = count2+1;
                    temp    = temp+1;
                end
                else
                    ifmap_out[22]     = 0;
            end
            else begin
                ifmap_out[22] = 0;
            end

            if (temp == 23) begin
                if (count2<H) begin
                    ifmap_out[23]     = ifmap[count_r*Q*H*W + count_q*W*H + count2*W + count_s + count];
                    count2  = count2+1;
                    temp    = temp+1;
                end
                else
                    ifmap_out[23]     = 0;
            end
            else begin
                ifmap_out[23] = 0;
            end

            if (temp == 24) begin
                if (count2<H) begin
                    ifmap_out[24]     = ifmap[count_r*Q*H*W + count_q*W*H + count2*W + count_s + count];
                    count2  = count2+1;
                    temp    = temp+1;
                end
                else
                    ifmap_out[24] = 0;
            end
            else begin
                ifmap_out[24] = 0;
            end

            count_q = count_q+1;
            if (count_q == Q) begin
                count_q = 0;
                count_s = count_s+1;
            end

            if (count_s == S) begin
                count_s = 0;
                count_r = count_r+1;
                pe_set_base = pe_set_base+R;
            end

            if (count_r == r) begin
                count_r = 0;
            end

        end

        else begin
            count_q = 4'b0000; // reset all these parameters when enable is turned off.
            count_r = 4'b0000;
            count_s = 4'b0000;
        end
    end
    
endmodule