package uart_agent_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

import uart_reg_pkg::*;
import uart_cfg_pkg::*;
`include "uart_seq_item.sv"
`include "uart_driver.sv"
`include "uart_monitor.sv"
`include "uart_agent.sv"
`include "uart_seq_item.sv"
`include "uart_sequencer.sv"

endpackage