// PA2 Sample Testbench

`timescale 1ns / 1ps

module tb_top;

    parameter SYS_PERIOD = 10;    //clk 100M, 10ns (fixed)
    
    reg clk, rst;
    reg [127:0] state, key;
    reg [4:0] counter;
    reg [4:0] counter1;
    wire [127:0] out;
    
    //clock generation (fixed)
    initial begin
        clk = 0;
        forever
        #(SYS_PERIOD/2) clk = ~clk;
    end
    
    AES_top DUT (.clk(clk), .state(state), .key(key), .out(out), .rst(rst));
    
    initial begin
        rst = 1;
        #5
            rst = 0;
        #5
            rst = 1;
    end 
    
    always@(posedge clk or negedge rst)begin
        if(!rst)begin
            counter <= 5'd0; 
            counter1 <= 5'd0;
        end
        else begin
            if(counter == 5'd31)begin
                counter <= 5'd0; 
                counter1 <= counter1 + 1;
            end
            else begin
                counter <= counter + 1; 
                counter1 <= counter1;
            end
        end
    end

    always@(*)begin
       case(counter1)
            5'd1: begin
                key = 128'h0000_0000_ffff_0000_0000_ffff_0000_ffff;
                state = 128'h0000_1111_2222_3333_4444_5555_6666_7777;
                end
            5'd0: begin
                key = 128'h0000_1111_ffff_0000_2222_ffff_3333_ffff;
                state = 128'h0000_1111_2222_3333_4444_5555_6666_7777;
                end
            5'd2: begin
                key = 128'h0000_0000_ffff_0000_0000_ffff_0000_ffff;
                state = 128'h0000_0000_0000_0000_0000_0000_0000_0000;
                end
            5'd3: begin
                key = 128'h0000_1111_ffff_0000_2222_ffff_3333_ffff;
                state = 128'h0000_0000_0000_0000_0000_0000_0000_0001;
                end
            default: begin
                key = 128'h0000_0000_0000_0000_0000_0000_0000_0000;
                state = 128'h0000_0000_0000_0000_0000_0000_0000_0000;
                end
       endcase
    end
    
    // Display key, state and out
    always @(posedge clk) begin
        if(counter == 5'd31)begin
            $display("key: %h", key);
            $display("State: %h", state);
            $display("Out: %h", out);
        end
    end

endmodule
