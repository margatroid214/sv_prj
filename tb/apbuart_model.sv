import uart_cfg_pkg::*

class apbuart_model extends uvm_component;

  `uvm_component_utils(apbuart_model)

  uvm_blocking_get_port #(apb_seq_item) bgp_apb;
  uvm_analysis_port #(apb_seq_item) ap_apb;

  uvm_blocking_get_port #(uart_seq_item) bgp_uart;
  uvm_analysis_port #(uart_seq_item) ap_uart;

  logic [31:0] apbuart_regs [10];   // apb-uart register list

  function new (string name = "apbuart_model", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase (uvm_phase phase);
    super.new(name, parent);
    bgp_apb   = new ("bgp_apb", this);
    ap_apb    = new ("ap_apb", this);
    bgp_uart  = new ("bgp_uart", this);
    ap_uart   = new ("ap_uart", this);
  endfunction

  task void main_phase (uvm_phase phase);
    apb_seq_item apb_wr_tr, apb_rd_tr;
    uart_seq_item uart_tx_tr, uart_rx_tr;

    super.main_phase(phase);
    
  endtask

  task void apb_handle;

endclass