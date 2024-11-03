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
// Module Name   : trig_apb_ui
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

module trig_apb_ui #(
    parameter integer C_APB_ADDR_WIDTH = 16,
    parameter integer C_APB_DATA_WIDTH = 32,
    parameter integer C_S_BASEADDR     = 0,
    parameter integer C_S_HIGHADDR     = 255,
    parameter integer SYMBOL_WIDTH     = 16,
    parameter integer SYMBOL_NUM       = 16
) (
    input  wire                          clk,
    input  wire                          rst,
    //
    input  wire [(C_APB_ADDR_WIDTH-1):0] s_paddr,
    input  wire                          s_psel,
    input  wire                          s_penable,
    input  wire                          s_pwrite,
    input  wire [(C_APB_DATA_WIDTH-1):0] s_pwdata,
    output wire                          s_pready,
    output wire [(C_APB_DATA_WIDTH-1):0] s_prdata,
    output wire                          s_pslverr,
    //
    output wire                          soft_rst,
    output wire [      SYMBOL_WIDTH-1:0] cfg_ut_uh,       // 高阈值上限
    output wire [      SYMBOL_WIDTH-1:0] cfg_ut_lh,       // 高阈值下限
    output wire [      SYMBOL_WIDTH-1:0] cfg_lt_uh,       // 低阈值上限
    output wire [      SYMBOL_WIDTH-1:0] cfg_lt_lh,       // 低阈值下限
    output wire                          cfg_trig_en,     // 触发使能
    output wire [                   1:0] cfg_trig8_pol,   // 触发极性
    input  wire [        SYMBOL_NUM-1:0] trig_detail_in,
    output wire                          trig_out,
    output wire [        SYMBOL_NUM-1:0] trig_detail_out
);

    // verilog_format: off
    localparam [7:0] ADDR_ID            = C_S_BASEADDR;             // 0x0000
    localparam [7:0] ADDR_REVISION      = ADDR_ID           + 8'h4; // 0x0004
    localparam [7:0] ADDR_BUILDTIME     = ADDR_REVISION     + 8'h4; // 0x0008
    localparam [7:0] ADDR_TEST          = ADDR_BUILDTIME    + 8'h4; // 0x000C
    localparam [7:0] ADDR_SYMBOL_WIDTH  = ADDR_TEST         + 8'h4; // 0x0010
    localparam [7:0] ADDR_SYMBOL_NUM    = ADDR_SYMBOL_WIDTH + 8'h4; // 0x0014
    localparam [7:0] ADDR_CTRL          = ADDR_SYMBOL_NUM   + 8'h4; // 0x0018
    localparam [7:0] ADDR_STATE         = ADDR_CTRL         + 8'h4; // 0x001C
    localparam [7:0] ADDR_UT_UH         = ADDR_STATE        + 8'h4; // 0x0020
    localparam [7:0] ADDR_UT_LH         = ADDR_UT_UH        + 8'h4; // 0X0024
    localparam [7:0] ADDR_LT_UH         = ADDR_UT_LH        + 8'h4; // 0X0028
    localparam [7:0] ADDR_LT_LH         = ADDR_LT_UH        + 8'h4; // 0X002C
    // verilog_format: on

    reg                  rst_i = 1;
    reg                  soft_rst_i = 1;
    reg [          31:0] ctrl_reg;
    reg [          31:0] status_reg;
    reg [          31:0] ut_uh_reg;
    reg [          31:0] ut_lh_reg;
    reg [          31:0] lt_uh_reg;
    reg [          31:0] lt_lh_reg;

    reg                  trig_out_i;
    reg [SYMBOL_NUM-1:0] trig_detail_out_i;

    //------------------------------------------------------------------------------------

    localparam [31:0] IPIDENTIFICATION = 32'hF7DEC7A5;
    localparam [31:0] REVISION = "V1.1";
    localparam [31:0] BUILDTIME = 32'h20240106;

    reg  [                31:0] test_reg;
    wire                        wr_active;
    wire                        rd_active;

    wire                        user_reg_rreq;
    wire                        user_reg_wreq;
    reg                         user_reg_rack;
    reg                         user_reg_wack;
    wire [C_APB_ADDR_WIDTH-1:0] user_reg_raddr;
    reg  [C_APB_DATA_WIDTH-1:0] user_reg_rdata;
    wire [C_APB_ADDR_WIDTH-1:0] user_reg_waddr;
    wire [C_APB_DATA_WIDTH-1:0] user_reg_wdata;

    assign user_reg_rreq  = ~s_pwrite & s_psel & s_penable;
    assign user_reg_wreq  = s_pwrite & s_psel & s_penable;
    assign s_pready       = user_reg_rack | user_reg_wack;
    assign user_reg_raddr = s_paddr;
    assign user_reg_waddr = s_paddr;
    assign s_prdata       = user_reg_rdata;
    assign user_reg_wdata = s_pwdata;
    assign s_pslverr      = 1'b0;

    assign rd_active      = user_reg_rreq;
    assign wr_active      = user_reg_wreq & user_reg_wack;

    always @(posedge clk, posedge rst_i) begin
        if (rst_i) begin
            user_reg_rack <= 1'b0;
            user_reg_wack <= 1'b0;
        end else begin
            user_reg_rack <= user_reg_rreq & ~user_reg_rack;
            user_reg_wack <= user_reg_wreq & ~user_reg_wack;
        end
    end

    //------------------------------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            rst_i <= 1'b1;
        end else begin
            rst_i <= rst;
        end
    end

    //-------------------------------------------------------------------------------------------------------------------------------------------
    //Read Register
    //-------------------------------------------------------------------------------------------------------------------------------------------
    always @(posedge clk, posedge rst_i) begin
        if (rst_i) begin
            user_reg_rdata <= 32'd0;
        end else begin
            user_reg_rdata <= 32'd0;
            if (rd_active) begin
                case (user_reg_raddr)
                    ADDR_ID:           user_reg_rdata <= IPIDENTIFICATION;
                    ADDR_REVISION:     user_reg_rdata <= REVISION;
                    ADDR_BUILDTIME:    user_reg_rdata <= BUILDTIME;
                    ADDR_TEST:         user_reg_rdata <= test_reg;
                    ADDR_SYMBOL_WIDTH: user_reg_rdata <= SYMBOL_WIDTH;
                    ADDR_SYMBOL_NUM:   user_reg_rdata <= SYMBOL_NUM;
                    ADDR_CTRL:         user_reg_rdata <= ctrl_reg;
                    ADDR_STATE:        user_reg_rdata <= status_reg;
                    ADDR_UT_UH:        user_reg_rdata <= ut_uh_reg;
                    ADDR_UT_LH:        user_reg_rdata <= ut_lh_reg;
                    ADDR_LT_UH:        user_reg_rdata <= lt_uh_reg;
                    ADDR_LT_LH:        user_reg_rdata <= lt_lh_reg;
                    default:           user_reg_rdata <= 32'hdeadbeef;
                endcase
            end else begin
                ;
            end
        end
    end

    //-------------------------------------------------------------------------------------------------------------------------------------------
    //Write Register
    //-------------------------------------------------------------------------------------------------------------------------------------------
    assign soft_rst = soft_rst_i;
    always @(posedge clk, posedge rst_i) begin
        if (rst_i) begin
            soft_rst_i <= 1'b1;
        end else begin
            if (wr_active && (user_reg_waddr == ADDR_CTRL)) begin
                soft_rst_i <= user_reg_wdata[31];
            end else begin
                soft_rst_i <= 1'b0;
            end
        end
    end

    always @(posedge clk, posedge soft_rst_i) begin
        if (soft_rst_i) begin
            test_reg  <= 32'd0;
            ut_uh_reg <= 0;
            ut_lh_reg <= 0;
            lt_uh_reg <= 0;
            lt_lh_reg <= 0;
        end else begin
            test_reg  <= test_reg;
            ut_uh_reg <= ut_uh_reg;
            ut_lh_reg <= ut_lh_reg;
            lt_uh_reg <= lt_uh_reg;
            lt_lh_reg <= lt_lh_reg;
            if (wr_active) begin
                case (user_reg_waddr)
                    ADDR_TEST:  test_reg <= user_reg_wdata;
                    ADDR_UT_UH: ut_uh_reg <= user_reg_wdata;
                    ADDR_UT_LH: ut_lh_reg <= user_reg_wdata;
                    ADDR_LT_UH: lt_uh_reg <= user_reg_wdata;
                    ADDR_LT_LH: lt_lh_reg <= user_reg_wdata;
                    default:    ;
                endcase
            end else begin
                ;
            end
        end
    end

    always @(posedge clk, posedge soft_rst_i) begin
        if (soft_rst_i) begin
            status_reg <= 0;
        end else begin
            if (wr_active && (user_reg_waddr == ADDR_STATE)) begin
                status_reg <= status_reg & ~user_reg_wdata;
            end else begin
                status_reg[0]     <= (|trig_detail_in) | status_reg[0];
                status_reg[31:16] <= (|trig_detail_in) ? trig_detail_in : status_reg[31:16];
            end
        end
    end

    always @(posedge clk, posedge soft_rst_i) begin
        if (soft_rst_i) begin
            ctrl_reg <= 0;
        end else begin
            if (wr_active && (user_reg_waddr == ADDR_CTRL)) begin
                ctrl_reg <= user_reg_wdata;
            end
        end
    end

    always @(posedge clk, posedge soft_rst_i) begin
        if (soft_rst_i) begin
            trig_out_i        <= 0;
            trig_detail_out_i <= 0;
        end else begin
            trig_out_i        <= (|trig_detail_in);
            trig_detail_out_i <= trig_detail_in;
        end
    end

    assign trig_out        = trig_out_i;
    assign trig_detail_out = trig_detail_out_i;
    assign cfg_trig_en     = ctrl_reg[0];
    assign cfg_trig8_pol   = ctrl_reg[2:1];

    assign cfg_ut_uh       = ut_lh_reg;
    assign cfg_ut_lh       = ut_lh_reg;
    assign cfg_lt_uh       = lt_uh_reg;
    assign cfg_lt_lh       = lt_lh_reg;

endmodule

// verilog_format: off
`resetall
// verilog_format: on
