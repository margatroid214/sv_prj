`timescale 1ns/1ps
`include "uvm_pkg.sv"
`include "../interfaces/apb_if.sv"
`include "../interfaces/uart_if.sv"
`include "../config/uart_cfg_pkg.sv"
`include "../agents/apb_agent/apb_agent_pkg.sv"
`include "../agents/uart_agent/uart_agent_pkg.sv"
`include "../env/apbuart_env_pkg.sv"
`include "apbuart_property.sv"

module top_tb;

  import uvm_pkg::*;
  import apb_agent_pkg::*;
  import uart_agent_pkg::*;
  import uart_cfg_pkg::*;
  import apbuart_env_pkg::*;

  bit pclk, presetn;
  bit uclk, uresetn;

  apb_if APB(.pclk(pclk), .presetn(presetn));
  uart_if UART(.clk(uclk), .rstn(uresetn));

  UART_TOP DUT (
    .clk        (pclk),
    .clk26m     (uclk),
    .rst_       (presetn),
    .rst26m_    (uresetn),
    .paddr_i    (APB.paddr),
    .pwdata_i   (APB.pwdata),
    .psel_i     (APB.psel),
    .penable_i  (APB.penable),
    .pwrite_i   (APB.pwrite),
    .urxd_i     (UART.urxd),
    .prdata_o   (APB.prdata),
    .utxd_o     (UART.utxd),
    .uart_int_o (APB.uart_int)
  );

  bind DUT apbuart_prop topP(.*);

  // set virtual interface handling and run test
  initial begin
    uvm_config_db #(virtual apb_if)::set(uvm_root::get(), "*", "apb_vif", APB);
    uvm_config_db #(virtual uart_if)::set(uvm_root::get(), "*", "uart_vif", UART);
    run_test();
  end

  // clock and reset gen
  initial begin
    pclk = 0;
    forever #5 pclk = ~pclk;
  end

  initial begin
    presetn = 0;
    repeat(40) @(negedge pclk);
    presetn = 1;
  end

  initial begin
    uclk = 0;
    forever #19 uclk = ~uclk;
  end

  initial begin
    uresetn = 0;
    repeat(10) @(negedge uclk);
    uresetn = 1;
  end

endmodule