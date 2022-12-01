module filter_bank (
    input clk,
    input [4:0] P, //# filters Processed by PE set
    input [2:0] Q, // # channels of a Particular filter Processed by PE set
    input [3:0] S, // filter width
    input [4:0] R, // filter height
    input [4:0] r, //# PE sets in array Proc diff channels of a filter
    input [4:0] t, //# PE sets in array Proc different filters
    input en,
    output reg [15:0] filter_out [11:0]
);

    wire [6:0] filter_size; //max size 121
    assign filter_size = R*S;

    reg [15:0] filter [1023:0];

    reg [9:0] count_P = 10'd0;
    reg [9:0] count_Q = 10'd0;
    reg [9:0] count_S = 10'd0;
    reg [9:0] count_R = 10'd0;
    reg [9:0] count_r = 10'd0;
    reg [9:0] count_t = 10'd0;  

    always @(posedge clk) begin
        if (en) begin
            count_t = 0;
            count_r = 0;
            count_R = 0;

            if (count_R == R) begin
                count_r = count_r + 1;
                count_R = 0;
            end
            if (count_r == r) begin
                count_t = count_t+1;
                count_r = 0;
            end
            if (count_t*r + count_r < t*r) begin
                filter_out[0] = filter[count_t*P*Q*r*filter_size+count_P*Q*r*filter_size+count_r*Q*filter_size+count_Q*filter_size+count_R*S+count_S]; // 0
            end
            count_R = count_R + 1;

            if (count_R == R) begin
                count_r = count_r + 1;
                count_R = 0;
            end
            if (count_r == r) begin
                count_t = count_t+1;
                count_r = 0;
            end
            if (count_t*r + count_r < t*r) begin
                filter_out[1] = filter[count_t*P*Q*r*filter_size+count_P*Q*r*filter_size+count_r*Q*filter_size+count_Q*filter_size+count_R*S+count_S]; // 1
            end
            count_R = count_R + 1;

            if (count_R == R) begin
                count_r = count_r + 1;
                count_R = 0;
            end
            if (count_r == r) begin
                count_t = count_t+1;
                count_r = 0;
            end
            if (count_t*r + count_r < t*r) begin
                filter_out[2] = filter[count_t*P*Q*r*filter_size+count_P*Q*r*filter_size+count_r*Q*filter_size+count_Q*filter_size+count_R*S+count_S]; // 2
            end
            count_R = count_R + 1;

            if (count_R == R) begin
                count_r = count_r + 1;
                count_R = 0;
            end
            if (count_r == r) begin
                count_t = count_t+1;
                count_r = 0;
            end
            if (count_t*r + count_r < t*r) begin
                filter_out[3] = filter[count_t*P*Q*r*filter_size+count_P*Q*r*filter_size+count_r*Q*filter_size+count_Q*filter_size+count_R*S+count_S]; // 3
            end
            count_R = count_R + 1;

            if (count_R == R) begin
                count_r = count_r + 1;
                count_R = 0;
            end
            if (count_r == r) begin
                count_t = count_t+1;
                count_r = 0;
            end
            if (count_t*r + count_r < t*r) begin
                filter_out[4] = filter[count_t*P*Q*r*filter_size+count_P*Q*r*filter_size+count_r*Q*filter_size+count_Q*filter_size+count_R*S+count_S]; // 4
            end
            count_R = count_R + 1;

            if (count_R == R) begin
                count_r = count_r + 1;
                count_R = 0;
            end
            if (count_r == r) begin
                count_t = count_t+1;
                count_r = 0;
            end
            if (count_t*r + count_r < t*r) begin
                filter_out[5]= filter[count_t*P*Q*r*filter_size+count_P*Q*r*filter_size+count_r*Q*filter_size+count_Q*filter_size+count_R*S+count_S]; // 5
            end
            count_R = count_R + 1;

            if (count_R == R) begin
                count_r = count_r + 1;
                count_R = 0;
            end
            if (count_r == r) begin
                count_t = count_t+1;
                count_r = 0;
            end
            if (count_t*r + count_r < t*r) begin
                filter_out[6]= filter[count_t*P*Q*r*filter_size+count_P*Q*r*filter_size+count_r*Q*filter_size+count_Q*filter_size+count_R*S+count_S]; // 6
            end
            count_R = count_R + 1;

            if (count_R == R) begin
                count_r = count_r + 1;
                count_R = 0;
            end
            if (count_r == r) begin
                count_t = count_t+1;
                count_r = 0;
            end
            if (count_t*r + count_r < t*r) begin
                filter_out[7] = filter[count_t*P*Q*r*filter_size+count_P*Q*r*filter_size+count_r*Q*filter_size+count_Q*filter_size+count_R*S+count_S]; // 7
            end
            count_R = count_R + 1;

            if (count_R == R) begin
                count_r = count_r + 1;
                count_R = 0;
            end
            if (count_r == r) begin
                count_t = count_t+1;
                count_r = 0;
            end
            if (count_t*r + count_r < t*r) begin
                filter_out[8] = filter[count_t*P*Q*r*filter_size+count_P*Q*r*filter_size+count_r*Q*filter_size+count_Q*filter_size+count_R*S+count_S]; // 8
            end
            count_R = count_R + 1;

            if (count_R == R) begin
                count_r = count_r + 1;
                count_R = 0;
            end
            if (count_r == r) begin
                count_t = count_t+1;
                count_r = 0;
            end
            if (count_t*r + count_r < t*r) begin
                filter_out[9] = filter[count_t*P*Q*r*filter_size+count_P*Q*r*filter_size+count_r*Q*filter_size+count_Q*filter_size+count_R*S+count_S]; // 9
            end
            count_R = count_R + 1;

            if (count_R == R) begin
                count_r = count_r + 1;
                count_R = 0;
            end
            if (count_r == r) begin
                count_t = count_t+1;
                count_r = 0;
            end
            if (count_t*r + count_r < t*r) begin
                filter_out[10]= filter[count_t*P*Q*r*filter_size+count_P*Q*r*filter_size+count_r*Q*filter_size+count_Q*filter_size+count_R*S+count_S]; // 10
            end
            count_R = count_R + 1;

            if (count_R == R) begin
                count_r = count_r + 1;
                count_R = 0;
            end
            if (count_r == r) begin
                count_t = count_t+1;
                count_r = 0;
            end
            if (count_t*r + count_r < t*r) begin
                filter_out[11] = filter[count_t*P*Q*r*filter_size+count_P*Q*r*filter_size+count_r*Q*filter_size+count_Q*filter_size+count_R*S+count_S]; // 11
            end
            count_R = count_R + 1;

            if (count_R == R) begin
                count_r = count_r + 1;
                count_R = 0;
            end
            if (count_r == r) begin
                count_t = count_t+1;
                count_r = 0;
            end

            count_P = count_P+1;
            if (count_P == P) begin
                count_P = 0;
                count_Q = count_Q+1;
            end
            if (count_Q ==  Q) begin
                count_Q = 0;
                count_S = count_S+1;
            end
        end
        else begin
            count_P = 0;
            count_Q = 0;
            count_S = 0;
        end
    end  

endmodule