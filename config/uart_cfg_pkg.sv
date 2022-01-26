`include "uvm_pkg.sv"

package uart_cfg_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

// apbuart global config; mainly for monitor to parse data pack
class apbuart_cfg extends uvm_object;
  uvm_active_passive_enum is_tx_active = UVM_ACTIVE;
  uvm_active_passive_enum is_rx_active = UVM_ACTIVE;

  rand bit tx_has_parity;
  rand bit rx_has_parity;

  rand bit [31:0] baud_rate;

  rand bit [1:0] tx_has_stop_bit;
  rand bit [1:0] rx_has_stop_bit;

  // extension
  rand bit parity_type;
  rand bit [3:0] tx_trig_depth;
  rand bit [3:0] rx_trig_depth;
  rand bit [3:0] tx_ifs;

  `uvm_object_utils(apbuart_cfg)

  function new (string name = "apbuart_cfg");
    super.new(name);
  endfunction
endclass

endpackage