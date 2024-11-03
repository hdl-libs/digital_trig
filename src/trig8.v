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
// Module Name   : trig8
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

module trig8 (
    input  wire       clk,                    // 时钟
    input  wire       rst,                    // 复位
    input  wire       above_upper_threshold,  // 高于阈值下限
    input  wire       above_lower_threshold,  // 高于阈值上限
    input  wire [1:0] trig_pol,               // 触发极性选择
    output reg        trig_out                // 触发输出
);

    localparam [5:0] FSM_IDLE = 6'b000000;
    localparam [5:0] FSM_R_S0 = 6'b000001;
    localparam [5:0] FSM_R_S1 = 6'b000010;
    localparam [5:0] FSM_R_S2 = 6'b000100;
    localparam [5:0] FSM_F_S0 = 6'b001000;
    localparam [5:0] FSM_F_S1 = 6'b010000;
    localparam [5:0] FSM_F_S2 = 6'b100000;

    reg [5:0] cstate;
    reg [5:0] nstate;

    reg       clr;
    reg [1:0] sel_l;

    // 如果触发极性改变则复位状态机
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sel_l <= 2'b00;
            clr   <= 1'b1;
        end else begin
            sel_l <= trig_pol;
            clr   <= |(trig_pol ^ sel_l);
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst | clr) begin
            cstate <= FSM_IDLE;
        end else begin
            cstate <= nstate;
        end
    end

    always @(*) begin
        if (rst | clr) begin
            nstate = FSM_IDLE;
        end else begin
            case (cstate)
                FSM_IDLE: begin
                    if (~above_upper_threshold & ~above_lower_threshold) begin
                        if (sel_l[0] == 1'b1) begin
                            nstate = FSM_R_S0;
                        end else begin
                            nstate = FSM_IDLE;
                        end
                    end else if (above_upper_threshold & above_lower_threshold) begin
                        if (sel_l[1] == 1'b1) begin
                            nstate = FSM_F_S0;
                        end else begin
                            nstate = FSM_IDLE;
                        end
                    end else begin
                        nstate = FSM_IDLE;
                    end
                end
                FSM_R_S0: begin
                    if (above_upper_threshold & above_lower_threshold) begin
                        nstate = FSM_R_S2;
                    end else if (~above_upper_threshold & above_lower_threshold) begin
                        nstate = FSM_R_S1;
                    end else if (~above_upper_threshold & ~above_lower_threshold) begin
                        nstate = FSM_R_S0;
                    end else begin
                        nstate = FSM_IDLE;
                    end
                end
                FSM_R_S1: begin
                    if (above_upper_threshold & above_lower_threshold) begin
                        nstate = FSM_R_S2;
                    end else if (~above_upper_threshold & above_lower_threshold) begin
                        nstate = FSM_R_S1;
                    end else begin
                        nstate = FSM_IDLE;
                    end
                end
                FSM_F_S0: begin
                    if (~above_upper_threshold & ~above_lower_threshold) begin
                        nstate = FSM_F_S2;
                    end else if (~above_upper_threshold & above_lower_threshold) begin
                        nstate = FSM_F_S1;
                    end else if (above_upper_threshold & above_lower_threshold) begin
                        nstate = FSM_F_S0;
                    end else begin
                        nstate = FSM_IDLE;
                    end
                end
                FSM_F_S1: begin
                    if (~above_upper_threshold & ~above_lower_threshold) begin
                        nstate = FSM_F_S2;
                    end else if (~above_upper_threshold & above_lower_threshold) begin
                        nstate = FSM_F_S1;
                    end else begin
                        nstate = FSM_IDLE;
                    end
                end
                FSM_F_S2: nstate = FSM_IDLE;
                FSM_R_S2: nstate = FSM_IDLE;
                default:  nstate = FSM_IDLE;
            endcase
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst | clr) begin
            trig_out <= 1'b0;
        end else begin
            case (nstate)
                FSM_F_S2: begin
                    trig_out <= 1'b1;
                end
                FSM_R_S2: begin
                    trig_out <= 1'b1;
                end
                default: trig_out <= 1'b0;
            endcase
        end
    end

endmodule

// verilog_format: off
`resetall
// verilog_format: on
