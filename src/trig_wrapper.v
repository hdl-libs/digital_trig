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
// Module Name   : trig_wrapper
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

module trig_wrapper #(
    parameter integer C_APB_ADDR_WIDTH = 16,
    parameter integer C_APB_DATA_WIDTH = 32,
    parameter integer C_S_BASEADDR     = 0,
    parameter integer C_S_HIGHADDR     = 255,
    parameter integer SYMBOL_WIDTH     = 16,
    parameter integer SYMBOL_NUM       = 16
) (
    //
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF s_apb:s_axis:m_axis , ASSOCIATED_RESET rst" *)
    input  wire                                 clk,          //  (required)
    //
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 rst RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *)
    input  wire                                 rst,          //  (required)
    //
    (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 s_apb PADDR" *)
    input  wire [       (C_APB_ADDR_WIDTH-1):0] s_paddr,      // Address (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 s_apb PSEL" *)
    input  wire                                 s_psel,       // Slave Select (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 s_apb PENABLE" *)
    input  wire                                 s_penable,    // Enable (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 s_apb PWRITE" *)
    input  wire                                 s_pwrite,     // Write Control (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 s_apb PWDATA" *)
    input  wire [       (C_APB_DATA_WIDTH-1):0] s_pwdata,     // Write Data (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 s_apb PREADY" *)
    output wire                                 s_pready,     // Slave Ready (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 s_apb PRDATA" *)
    output wire [       (C_APB_DATA_WIDTH-1):0] s_prdata,     // Read Data (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 s_apb PSLVERR" *)
    output wire                                 s_pslverr,    // Slave Error Response (required)
    //
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TVALID" *)
    input  wire                                 s_tvalid,     //
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TDATA" *)
    input  wire [SYMBOL_WIDTH * SYMBOL_NUM-1:0] s_tdata,      //
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TREADY" *)
    output wire                                 s_tready,     //
    //
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TVALID" *)
    output wire                                 m_tvalid,     //
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TDATA" *)
    output wire [SYMBOL_WIDTH * SYMBOL_NUM-1:0] m_tdata,      //
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TREADY" *)
    input  wire                                 m_tready,     //
    //
    output wire [               SYMBOL_NUM-1:0] trig_detail,
    output wire                                 trig_out      //
);

    wire                    soft_rst;
    wire [SYMBOL_WIDTH-1:0] upper_threshold_upper_hystersis;
    wire [SYMBOL_WIDTH-1:0] upper_threshold_lower_hystersis;
    wire [SYMBOL_WIDTH-1:0] lower_threshold_upper_hystersis;
    wire [SYMBOL_WIDTH-1:0] lower_threshold_lower_hystersis;
    wire [  SYMBOL_NUM-1:0] above_upper_threshold;
    wire [  SYMBOL_NUM-1:0] above_lower_threshold;
    wire [             1:0] trig8_pol;
    wire [  SYMBOL_NUM-1:0] trig8_detail_i;

    trig_apb_ui #(
        .C_APB_ADDR_WIDTH(C_APB_ADDR_WIDTH),
        .C_APB_DATA_WIDTH(C_APB_DATA_WIDTH),
        .C_S_BASEADDR    (C_S_BASEADDR),
        .C_S_HIGHADDR    (C_S_HIGHADDR),
        .SYMBOL_WIDTH    (SYMBOL_WIDTH),
        .SYMBOL_NUM      (SYMBOL_NUM)
    ) trig_apb_ui_inst (
        .clk            (clk),
        .rst            (rst),
        .s_paddr        (s_paddr),
        .s_psel         (s_psel),
        .s_penable      (s_penable),
        .s_pwrite       (s_pwrite),
        .s_pwdata       (s_pwdata),
        .s_pready       (s_pready),
        .s_prdata       (s_prdata),
        .s_pslverr      (s_pslverr),
        .soft_rst       (soft_rst),
        .cfg_ut_uh      (upper_threshold_upper_hystersis),
        .cfg_ut_lh      (upper_threshold_lower_hystersis),
        .cfg_lt_uh      (lower_threshold_upper_hystersis),
        .cfg_lt_lh      (lower_threshold_lower_hystersis),
        .cfg_trig_en    (),
        .cfg_trig8_pol  (trig8_pol),
        .trig_detail_in (trig8_detail_i),
        .trig_out       (trig_out),
        .trig_detail_out(trig_detail)
    );

    trig_cmp #(
        .SYMBOL_WIDTH(SYMBOL_WIDTH),
        .SYMBOL_NUM  (SYMBOL_NUM)
    ) trig_cmp_inst (
        .clk                            (clk),
        .rst                            (soft_rst),
        .s_tvalid                       (s_tvalid),
        .s_tdata                        (s_tdata),
        .s_tready                       (s_tready),
        .m_tvalid                       (m_tvalid),
        .m_tdata                        (m_tdata),
        .m_tready                       (m_tready),
        .upper_threshold_upper_hystersis(upper_threshold_upper_hystersis),
        .upper_threshold_lower_hystersis(upper_threshold_lower_hystersis),
        .lower_threshold_upper_hystersis(lower_threshold_upper_hystersis),
        .lower_threshold_lower_hystersis(lower_threshold_lower_hystersis),
        .above_upper_threshold          (above_upper_threshold),
        .above_lower_threshold          (above_lower_threshold)
    );

    genvar ii;
    for (ii = 0; ii < SYMBOL_NUM; ii = ii + 1) begin
        trig8 trig8_inst (
            .clk                  (clk),
            .rst                  (soft_rst),
            .above_upper_threshold(above_upper_threshold[ii]),
            .above_lower_threshold(above_lower_threshold[ii]),
            .trig_pol             (trig8_pol),
            .trig_out             (trig8_detail_i[ii])
        );
    end

endmodule

// verilog_format: off
`resetall
// verilog_format: on