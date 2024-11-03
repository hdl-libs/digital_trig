// ---------------------------------------------------------------------------------------
// Copyright (c) 2024 john_tito All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// ---------------------------------------------------------------------------------------
// +FHEADER-------------------------------------------------------------------------------
// Author        : john_tito
// Module Name   : trig8_tb
// ---------------------------------------------------------------------------------------
// Revision      : 1.0
// Description   : File Created
// ---------------------------------------------------------------------------------------
// Synthesizable : Yes
// Clock Domains : clk
// Reset Strategy: sync reset
// -FHEADER-------------------------------------------------------------------------------

// verilog_format: off
`resetall
`timescale 1ns / 1ps
`default_nettype none
// verilog_format: on

module trig8_tb;

    // Parameters
    localparam real TIMEPERIOD = 10;

    // Inputs
    reg        clk = 0;
    reg        rstn = 0;
    reg        above_upper_threshold = 0;
    reg        above_lower_threshold = 0;
    reg  [1:0] trig_pol = 2'b00;

    // Output
    wire       trig_out;

    // Instantiate the module under test
    trig8 uut (
        .clk                  (clk),
        .rst                  (~rstn),
        .above_upper_threshold(above_upper_threshold),
        .above_lower_threshold(above_lower_threshold),
        .trig_pol             (trig_pol),
        .trig_out             (trig_out)
    );

    reg [2:0] cnt_0;
    reg [2:0] cnt_1;
    reg [2:0] cnt_2;
    reg [2:0] cnt_3;

    // Test vector
    initial begin

        // Initialize inputs

        cnt_0                 = 3'b000;
        cnt_1                 = 3'b000;
        cnt_2                 = 3'b000;
        cnt_3                 = 3'b000;

        above_upper_threshold = 0;
        above_lower_threshold = 0;
        trig_pol              = 2'b00;

        // Wait for reset to be released
        wait (rstn);
        #(TIMEPERIOD * 32);

        trig_pol = 2'b11;

        repeat (4) begin
            repeat (4) begin
                repeat (4) begin
                    repeat (4) begin
                        #100;
                        above_upper_threshold = cnt_0[1];
                        above_lower_threshold = cnt_0[0];
                        #100;
                        above_upper_threshold = cnt_1[1];
                        above_lower_threshold = cnt_1[0];
                        #100;
                        above_upper_threshold = cnt_2[1];
                        above_lower_threshold = cnt_2[0];
                        #100;
                        above_upper_threshold = cnt_3[1];
                        above_lower_threshold = cnt_3[0];
                        #100;
                        cnt_3 = cnt_3 + 3'b001;
                    end
                    cnt_2 = cnt_2 + 3'b001;
                end
                cnt_1 = cnt_1 + 3'b001;
            end
            cnt_0 = cnt_0 + 3'b001;
        end

        // Finish simulation
        #(TIMEPERIOD * 2);
        $finish;
    end

    // Clock generation
    always #(TIMEPERIOD / 2) clk = !clk;

    // Reset generation
    initial begin
        rstn = 1'b0;
        #(TIMEPERIOD * 32);
        rstn = 1'b1;
    end

    // Waveform recording
    initial begin
        $dumpfile("sim/test_tb.vcd");
        $dumpvars(0, trig8_tb);
    end

endmodule

// verilog_format: off
`resetall
// verilog_format: on
