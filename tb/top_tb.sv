module top_tb;

  import uvm_pkg::*;
  import apb_agent_pkg::*;
  import uart_agent_pkg::*;
  import uart_cfg_pkg::*;

  bit pclk, presetn;
  bit uclk, uresetn;

  apb_if APB(.pclk(pclk), presetn(presetn));
  uart_if UART(.clk(uclk), rstn(uresetn));

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

  // set virtual interface handling and run test
  initial begin
    uvm_config_db #(virtual apb_if)::set(null, "uvm_test_top", "APB", APB);
    uvm_config_db #(virtual uart_if)::set(null, "uvm_test_top", "UART", UART);
    run_test();
  end

  // clock and reset gen
  initial begin
    pclk = 0;
    forever #5 pclk = ~pclk;
  end

  initial begin
    presetn = 0;
    repeat(10) @(negedge pclk);
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