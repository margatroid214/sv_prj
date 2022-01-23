package uart_cfg_pkg;

// macros if didnt use register model
`define UART_TXD 32'h0000
`define UART_RXD 32'h0004
`define UART_DIV 32'h0008
`define UART_CFG 32'h000c
`define UART_RXTD 32'h0010
`define UART_TXTD 32'h0014
`define UART_IFS 32'h0018
`define UART_SR 32'h001c
`define UART_RDL 32'h0020
`define UART_TDL 32'h0024

// apbuart global config; mainly for monitor to parse data pack
class apbuart_cfg extends uvm_object;
  uvm_active_passive_enum is_tx_active = UVM_ACTIVE;
  uvm_active_passive_enum is_rx_active = UVM_PASSIVE;

  rand bit tx_has_parity;
  rand bit rx_has_parity;

  rand bit [31:0] baud_rate;

  rand bit [1:0] tx_stop_bits;
  rand bit [1:0] rx_stop_bits;

  `uvm_object_utils_begin(apbuart_cfg)
    `uvm_field_int(tx_has_parity, UVM_ALL_ON);
    `uvm_field_int(tx_has_parity, UVM_ALL_ON);
    `uvm_field_int(baud_rate, UVM_ALL_ON);
  `uvm_object_utils_end

  function new (string name = "apbuart_cfg");
    super.new(name);
  endfunction
endclass

endpackage