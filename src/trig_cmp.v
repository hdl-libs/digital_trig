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
// Module Name   : trig_cmp
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

module trig_cmp #(
    parameter SYMBOL_WIDTH = 16,
    parameter SYMBOL_NUM   = 16
) (
    input wire clk,  // 时钟
    input wire rst,  // 复位

    input  wire                                 s_tvalid,  //
    input  wire [SYMBOL_WIDTH * SYMBOL_NUM-1:0] s_tdata,   //
    output wire                                 s_tready,  //

    output wire                                 m_tvalid,  //
    output wire [SYMBOL_WIDTH * SYMBOL_NUM-1:0] m_tdata,   //
    input  wire                                 m_tready,  //

    input wire [SYMBOL_WIDTH-1:0] upper_threshold_upper_hystersis,  // 高阈值上限
    input wire [SYMBOL_WIDTH-1:0] upper_threshold_lower_hystersis,  // 高阈值下限
    input wire [SYMBOL_WIDTH-1:0] lower_threshold_upper_hystersis,  // 低阈值上限
    input wire [SYMBOL_WIDTH-1:0] lower_threshold_lower_hystersis,  // 低阈值下限

    output wire [SYMBOL_NUM-1:0] above_upper_threshold,  // 高于高阈值
    output wire [SYMBOL_NUM-1:0] above_lower_threshold   // 高于低阈值
);

    // a_u_u:above_upper_threshold_upper_hystersis
    // b_u_l:below_upper_threshold_lower_hystersis
    // a_l_u:above_lower_threshold_upper_hystersis
    // b_l_l:below_lower_threshold_lower_hystersis

    reg  [  SYMBOL_NUM-1:0] above_upper_threshold_i;
    reg  [  SYMBOL_NUM-1:0] above_lower_threshold_i;

    wire                    a_u_u_0;
    wire                    b_u_l_0;
    wire                    a_l_u_0;
    wire                    b_l_l_0;

    reg  [(SYMBOL_NUM-1):0] a_u_u;
    reg  [(SYMBOL_NUM-1):0] b_u_l;
    reg  [(SYMBOL_NUM-1):0] a_l_u;
    reg  [(SYMBOL_NUM-1):0] b_l_l;

    wire [SYMBOL_WIDTH-1:0] sample_point            [0:SYMBOL_NUM-1];

    assign s_tready = m_tready;
    assign m_tvalid = s_tvalid;
    assign m_tdata  = s_tdata;

    genvar ii;
    for (ii = 0; ii < SYMBOL_NUM; ii = ii + 1) begin
        assign sample_point[ii] = s_tdata[SYMBOL_WIDTH*ii+:SYMBOL_WIDTH];

        // 获取初步的阈值比较结果
        always @(posedge clk or posedge rst) begin
            if (rst) begin
                a_u_u[ii] <= 1'b0;
                b_u_l[ii] <= 1'b0;
                a_l_u[ii] <= 1'b0;
                b_l_l[ii] <= 1'b0;
            end else begin
                if (s_tvalid) begin
                    a_u_u[ii] <= (sample_point[ii] > upper_threshold_upper_hystersis);
                    b_u_l[ii] <= (sample_point[ii] < upper_threshold_lower_hystersis);
                    a_l_u[ii] <= (sample_point[ii] > lower_threshold_upper_hystersis);
                    b_l_l[ii] <= (sample_point[ii] < lower_threshold_lower_hystersis);
                end
            end
        end

        // 根据上面的比较结果处理迟滞输出，高于高阈值输出高，低于低阈值输出低，中间情况保持不变
        always @(posedge clk or posedge rst) begin
            if (rst) begin
                above_upper_threshold_i[ii] <= 1'b0;
                above_lower_threshold_i[ii] <= 1'b0;
            end else begin

                if (a_u_u[ii]) begin
                    above_upper_threshold_i[ii] <= 1'b1;
                end else if (b_u_l[ii]) begin
                    above_upper_threshold_i[ii] <= 1'b0;
                end

                if (a_l_u[ii]) begin
                    above_lower_threshold_i[ii] <= 1'b1;
                end else if (b_l_l[ii]) begin
                    above_lower_threshold_i[ii] <= 1'b0;
                end
            end
        end

        assign above_upper_threshold[ii] = above_upper_threshold_i[ii];
        assign above_lower_threshold[ii] = above_lower_threshold_i[ii];
    end

endmodule

// verilog_format: off
`resetall
// verilog_format: on
