module filter_bank (
    input clk,
    input rst,
    input [8:0] M,    // # filters / # ofmap channels
    input [8:0] C,    // # ifmap/filter channels
    input [3:0] R, S, // height and width of filter
    input [3:0] P,    // # filters processed by array
    input [3:0] Q,    // # filter elems processed by column
    input en,
    output [15:0] filter_out0, filter_out1, filter_out2, filter_out3, filter_out4, filter_out5, filter_out6, filter_out7, filter_out8, filter_out9, filter_out10, filter_out11, filter_out12, filter_out13
);

    reg [15:0] filter_out [13:0];

    assign filter_out0 = filter_out[0];
    assign filter_out1 = filter_out[1];
    assign filter_out2 = filter_out[2];
    assign filter_out3 = filter_out[3];
    assign filter_out4 = filter_out[4];
    assign filter_out5 = filter_out[5];
    assign filter_out6 = filter_out[6];
    assign filter_out7 = filter_out[7];
    assign filter_out8 = filter_out[8];
    assign filter_out9 = filter_out[9];
    assign filter_out10 = filter_out[10];
    assign filter_out11 = filter_out[11];
    assign filter_out12 = filter_out[12];
    assign filter_out13 = filter_out[13];

    wire [6:0] filter_size; //max size 121
    assign filter_size = R*S;
    wire [9:0] channels_in_pass;
    assign channels_in_pass = (filter_size > Q) ? 1 : Q/filter_size;

    reg [15:0] filter [1023:0];

    reg [9:0] count_P = 10'd0; // until P
    //reg [9:0] count_Q = 10'd0; // until Q
    reg [9:0] count_C = 10'd0; // until channels_in_pass
    reg [9:0] count_filtsize = 10'd0;

    integer i;

    always @(posedge clk) begin
        if (rst) begin
            count_P = 0;
            //count_Q = 0;
            count_C = 0; 
            count_filtsize = 0;
            for (i = 0; i < 14; i=i+1) begin
                filter_out[i] <= 16'h0000;
            end
        end else if (en) begin
            // for each column output first elem of each filter until P in a single channel
            // next elem until reach R*S, en (load_f) should count until Q
            count_P = 0;
            
            for (i = 0; i < 14; i=i+1) begin
                //if (i >= 14-Q) begin
                    if (count_P < P) begin
                        filter_out[i] <= filter[count_C*P*filter_size+count_P*filter_size+count_filtsize];
                    end
                    count_P = count_P + 1;
                //end
            end
            /*if (count_P < P) 
                filter_out[0] <= filter[count_C*P*filter_size+count_P*filter_size+count_filtsize];
            count_P = count_P + 1;
            if (count_P < P) 
                filter_out[1] <= filter[count_C*P*filter_size+count_P*filter_size+count_filtsize];
            count_P = count_P + 1;
            if (count_P < P) 
                filter_out[2] <= filter[count_C*P*filter_size+count_P*filter_size+count_filtsize];
            count_P = count_P + 1;
            if (count_P < P) 
                filter_out[3] <= filter[count_C*P*filter_size+count_P*filter_size+count_filtsize];
            count_P = count_P + 1;
            if (count_P < P) 
                filter_out[4] <= filter[count_C*P*filter_size+count_P*filter_size+count_filtsize];
            count_P = count_P + 1;
            if (count_P < P) 
                filter_out[5] <= filter[count_C*P*filter_size+count_P*filter_size+count_filtsize];
            count_P = count_P + 1;
            if (count_P < P) 
                filter_out[6] <= filter[count_C*P*filter_size+count_P*filter_size+count_filtsize];
            count_P = count_P + 1;
            if (count_P < P) 
                filter_out[7] <= filter[count_C*P*filter_size+count_P*filter_size+count_filtsize];
            count_P = count_P + 1;
            if (count_P < P) 
                filter_out[8] <= filter[count_C*P*filter_size+count_P*filter_size+count_filtsize];
            count_P = count_P + 1;
            if (count_P < P) 
                filter_out[9] <= filter[count_C*P*filter_size+count_P*filter_size+count_filtsize];
            count_P = count_P + 1;
            if (count_P < P) 
                filter_out[10] <= filter[count_C*P*filter_size+count_P*filter_size+count_filtsize];
            count_P = count_P + 1;
            if (count_P < P) 
                filter_out[11] <= filter[count_C*P*filter_size+count_P*filter_size+count_filtsize];
            count_P = count_P + 1;
            if (count_P < P) 
                filter_out[12] <= filter[count_C*P*filter_size+count_P*filter_size+count_filtsize];
            count_P = count_P + 1;
            if (count_P < P) 
                filter_out[13] <= filter[count_C*P*filter_size+count_P*filter_size+count_filtsize];
            count_P = count_P + 1;*/
         
            if (count_filtsize == filter_size-1) begin
                count_filtsize = 0;
                if (count_C == channels_in_pass - 1) begin
                    count_C = 0;
                end else begin
                    count_C = count_C + 1;
                end
            end else begin
                count_filtsize = count_filtsize+1;
            end
        end
        
    end  

endmodule