
package apb_agent_pkg;

typedef enum bit {ROSE, FELL} irq_t;

import uvm_pkg::*;
`include "uvm_macros.svh"

import uart_cfg_pkg::*;
`include "apb_seq_item.sv"
`include "apb_driver.sv"
`include "apb_monitor.sv"
`include "apb_seq_lib.sv"
`include "apb_sequencer.sv"
`include "apb_agent.sv"

endpackage