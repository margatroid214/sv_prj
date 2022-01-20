package uart_reg_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

// macros if didnt use register model
`define UART_TXD 32'h0000
`define UART_RXD 32'h0004
`define UART_DIV 32'h0008
`define UART_CFG 32'h000c
`define UART_RXTD 32'h0010
`define UART_TXTD 32'h0014
`define UART_IFS 32'h0018
`define UART_SR 32'h001c
`define UART RDL 32'h0020
`define UART_TDL 32'h0024

// tx data reg
class reg_txd extends uvm_reg;
  `uvm_object_utils(reg_txd)

  rand uvm_reg_field tx_data;
  
  function new (string name = "reg_txd");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  function void build ();
    tx_data = uvm_reg_field::type_id::create("tx_data");
    tx_data.configure(this, 8, 0, "RW", 0, 8'h0, 0, 1, 0);
  endfunction
endclass

// rx data reg
class reg_rxd extends uvm_reg;
  `uvm_object_utils(reg_rxd)

  uvm_reg_field rx_data;
  
  function new (string name = "reg_rxd");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  function void build ();
    tx_data = uvm_reg_field::type_id::create("rx_data");
    tx_data.configure(this, 8, 0, "RW", 0, 8'h0, 0, 0, 0);
  endfunction
endclass

// baud rate reg 
// frequency division range : (13 , 676)
class reg_div extends uvm_reg;
  `uvm_object_utils(reg_div)

  uvm_reg_field div;
  
  function new (string name = "reg_div");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  function void build ();
    tx_data = uvm_reg_field::type_id::create("div");
    tx_data.configure(this, 10, 0, "RW", 0, 10'd13, 1, 1, 0);
  endfunction
endclass

// uart reg block
class uart_reg_block extends uvm_reg_block;
  `uvm_object_utils(uart_reg_block)

  rand reg_txd TXD;
  rand reg_rxd RXD;
  rand reg_div DIV;

  uvm_reg_map reg_map;

  function new (string name = "uart_reg_block");
    super.new(name, UVM_NO_COVERAGE);
  endfunction

  function void build();
    reg_map = create_map("reg_map", 0, 4, UVM_LITTLE_ENDIAN);

    TXD = reg_txd::type_id::create("TXD");
    TXD.configure(this);
    TXD.build();
    reg_map.add_reg(TXD, 32'h0, "RW");

    RXD = reg_txd::type_id::create("RXD");
    RXD.configure(this);
    RXD.build();
    reg_map.add_reg(RXD, 32'h4, "RW");

    DIV = reg_txd::type_id::create("DIV");
    DIV.configure(this);
    DIV.build();
    reg_map.add_reg(DIV, 32'h8, "RW");

    lock_model();
  endfunction
endclass

endpackage