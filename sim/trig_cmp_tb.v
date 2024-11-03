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
// Module Name   : trig_cmp_tb
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

module trig_cmp_tb;

    // Parameters
    localparam real TIMEPERIOD = 5;
    localparam SAMPLE_RES = 16;
    localparam SAMPLE_NUM = 1;

    // Ports
    reg                                clk = 0;
    reg                                rstn = 0;

    reg  [SAMPLE_RES * SAMPLE_NUM-1:0] data = 16'h0000;
    reg  [             SAMPLE_RES-1:0] upper_threshold_upper_hystersis = 16'h0003;
    reg  [             SAMPLE_RES-1:0] upper_threshold_lower_hystersis = 16'h0002;
    reg  [             SAMPLE_RES-1:0] lower_threshold_upper_hystersis = 16'h0001;
    reg  [             SAMPLE_RES-1:0] lower_threshold_lower_hystersis = 16'h0000;
    wire [             SAMPLE_NUM-1:0] above_upper_threshold;
    wire [             SAMPLE_NUM-1:0] above_lower_threshold;

    trig_cmp #(
        .SAMPLE_RES(SAMPLE_RES),
        .SAMPLE_NUM(SAMPLE_NUM)
    ) dut (
        .clk                            (clk),
        .rstn                           (rstn),
        .data                           (data),
        .upper_threshold_upper_hystersis(upper_threshold_upper_hystersis),
        .upper_threshold_lower_hystersis(upper_threshold_lower_hystersis),
        .lower_threshold_upper_hystersis(lower_threshold_upper_hystersis),
        .lower_threshold_lower_hystersis(lower_threshold_lower_hystersis),
        .above_upper_threshold          (above_upper_threshold),
        .above_lower_threshold          (above_lower_threshold)
    );

    initial begin
        begin
            data = 16'h0000;
            wait (rstn);

            repeat (65536) begin
                data = data + 16'h0002;
                #10;
            end

            $finish;
        end
    end

    always #(TIMEPERIOD / 2) clk = !clk;

    // reset block
    initial begin
        rstn = 1'b0;
        #(TIMEPERIOD * 2);
        rstn = 1'b1;
    end

    // record block
    initial begin
        $dumpfile("sim/test_tb.lxt");
        $dumpvars(0, trig_cmp_tb);
    end

endmodule

// verilog_format: off
`resetall
// verilog_format: on
