/* one AES round for every two clock cycles */
module one_round (clk, state_in, key, state_out);
    input              clk;
    input      [127:0] state_in, key;
    output reg [127:0] state_out;
    wire [127:0] shift_row_result;
    wire [7:0] byte_1, byte_2, byte_3, byte_4, byte_5, byte_6, byte_7, byte_8;
    wire [7:0] byte_9, byte_10, byte_11, byte_12, byte_13, byte_14, byte_15, byte_16;
    wire [31:0] w1 , w2 , w3 , w4;
    wire [31:0] sb_result_1 , sb_result_2 , sb_result_3 , sb_result_4;
    assign {byte_16, byte_15, byte_14, byte_13, byte_12, byte_11, byte_10, byte_9, byte_8, byte_7, byte_6, byte_5, byte_4, byte_3, byte_2, byte_1} = state_in;
    // sub bytes
    assign {w1} = {byte_16, byte_12, byte_8, byte_4};
    assign {w2} = {byte_15, byte_11, byte_7, byte_3};
    assign {w3} = {byte_14, byte_10, byte_6, byte_2};
    assign {w4} = {byte_13, byte_9, byte_5, byte_1};
    S4
        S4_0 (clk, w1, sb_result_1), // S4 (clk, in, out)
        S4_1 (clk, w2, sb_result_2),
        S4_2 (clk, w3, sb_result_3),
        S4_3 (clk, w4, sb_result_4);
    // shift rows

    assign shift_row_result = {sb_result_1, sb_result_2[23:0], sb_result_2[31:24],
    sb_result_3[15:0], sb_result_3[31:16], sb_result_4[7:0], sb_result_4[31:8]};
    // [127:96] , {[87:64],[95:88]} , {[47:32],[63:48]} , {[7:0],[31:8]})

    // mix columns
    wire [7:0] mc1, mc2, mc3, mc4, mc5, mc6, mc7, mc8;
    wire [7:0] mc9, mc10, mc11, mc12, mc13, mc14, mc15, mc16;
    xS
        mix_col1 (clk, shift_row_result[7:0], mc16),
        mix_col2 (clk, shift_row_result[15:8], mc15),
        mix_col3 (clk, shift_row_result[23:16], mc14),
        mix_col4 (clk, shift_row_result[31:24], mc13),
        mix_col5 (clk, shift_row_result[39:32], mc12),
        mix_col6 (clk, shift_row_result[47:40], mc11),
        mix_col7 (clk, shift_row_result[55:48], mc10),
        mix_col8 (clk, shift_row_result[63:56], mc9),
        mix_col9 (clk, shift_row_result[71:64], mc8),
        mix_col10 (clk, shift_row_result[79:72], mc7),
        mix_col11 (clk, shift_row_result[87:80], mc6),
        mix_col12 (clk, shift_row_result[95:88], mc5),
        mix_col13 (clk, shift_row_result[103:96], mc4),
        mix_col14 (clk, shift_row_result[111:104], mc3),
        mix_col15 (clk, shift_row_result[119:112], mc2),
        mix_col16 (clk, shift_row_result[127:120], mc1);

    wire [127:0] mix_col_result;
    assign mix_col_result = {mc1 , mc2 , mc3 , mc4 , mc5 , mc6 , mc7 , mc8 , mc9 , mc10 , mc11 , mc12 , mc13 , mc14 , mc15 , mc16};
    // add round key
    
    wire [127:0] add_key_result;
    assign add_key_result = {
        key ^ {
            mix_col_result[127:120], mix_col_result[95:88], mix_col_result[63:56], mix_col_result[31:24],
            mix_col_result[119:112], mix_col_result[87:80], mix_col_result[55:48], mix_col_result[23:16],
            mix_col_result[111:104], mix_col_result[79:72], mix_col_result[47:40], mix_col_result[15:8],
            mix_col_result[103:96], mix_col_result[71:64], mix_col_result[39:32], mix_col_result[7:0]
        }
    };

    always @ (posedge clk)
        state_out <= add_key_result;

endmodule

/* AES final round for every two clock cycles */
module final_round (clk, state_in, key_in, state_out);
    input              clk;
    input      [127:0] state_in;
    input      [127:0] key_in;
    output reg [127:0] state_out;
    
    wire [127:0] shift_row_result;
    wire [7:0] byte_1, byte_2, byte_3, byte_4, byte_5, byte_6, byte_7, byte_8;
    wire [7:0] byte_9, byte_10, byte_11, byte_12, byte_13, byte_14, byte_15, byte_16;
    wire [31:0] w1 , w2 , w3 , w4;
    wire [31:0] sb_result_1 , sb_result_2 , sb_result_3 , sb_result_4;
    assign {byte_16, byte_15, byte_14, byte_13, byte_12, byte_11, byte_10, byte_9, byte_8, byte_7, byte_6, byte_5, byte_4, byte_3, byte_2, byte_1}  =  state_in;
    // sub bytes 
    
    assign {w1} = (state_in & 10'b00_0110_1101 ) ? {byte_16, byte_12, byte_8, byte_4} : 32'h52_52_52_52;
    assign {w2} = (state_in & 10'b00_0110_1101 ) ? {byte_15, byte_11, byte_7, byte_3} : 32'h52_52_52_52;
    assign {w3} = (state_in & 10'b00_0110_1101 ) ? {byte_14, byte_10, byte_6, byte_2} : 32'h52_52_52_52;
    assign {w4} = (state_in & 10'b00_0110_1101 ) ? {byte_13, byte_9, byte_5, byte_1} : 32'h52_52_52_52;
    S4
        S4_0 (clk, w1, sb_result_1), // S4 (clk, in, out)
        S4_1 (clk, w2, sb_result_2),
        S4_2 (clk, w3, sb_result_3),
        S4_3 (clk, w4, sb_result_4);
    // shift rows

    assign shift_row_result = {sb_result_1, sb_result_2[23:0], sb_result_2[31:24],
    sb_result_3[15:0], sb_result_3[31:16], sb_result_4[7:0], sb_result_4[31:8]};
    // [127:96] , {[87:64],[95:88]} , {[47:32],[63:48]} , {[7:0],[31:8]})

    // add round key
    wire [127:0] add_key_result;
    assign add_key_result = {
        key_in ^ {
            shift_row_result[127:120], shift_row_result[95:88], shift_row_result[63:56], shift_row_result[31:24],
            shift_row_result[119:112], shift_row_result[87:80], shift_row_result[55:48], shift_row_result[23:16],
            shift_row_result[111:104], shift_row_result[79:72], shift_row_result[47:40], shift_row_result[15:8],
            shift_row_result[103:96], shift_row_result[71:64], shift_row_result[39:32], shift_row_result[7:0]
        }
    };

    always @ (posedge clk)
        state_out <= add_key_result;
endmodule