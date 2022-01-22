`define UARTMON_IF uart_vif.MONITOR.monitor_cb

class uart_monitor extends uvm_component;

  `uvm_component_utils(uart_monitor)

  virtual uart_if uart_vif;

  apbuart_cfg cfg;

  uvm_analysis_port #(uart_seq_item) ap;  // tlm port for sending transactions out to scoreboard

  extern function new (string name = "apb_monitor", uvm_component parent);
  extern function void build_phase (uvm_phase phase);
  extern task run_phase (uvm_phase phase);
  extern task get_tx_pkg();
  extern task get_rx_pkg();

endclass

function uart_monitor::new (string name = "uart_monitor", uvm_component parent);
  super.new(name, parent);
  ap = new("ap", this);
endfunction

function uart_monitor::build_phase (uvm_phase phase);
  super.build_phase(phase);
  if (!uvm_config_db#(virtual uart_if)::get(this, "*", "uart_vif", uart_vif))
    `uvm_error(get_type_name(), "did not get virtual bus handle")
  if (!uvm_config_db#(apbuart_cfg)::get(this, "*", "cfg", cfg))
    `uvm_error(get_type_name(), "did not get global config handle")
endfunction

function uart_monitor::run_phase(uvm_phase phase);

endfunction

task uart_monitor::get_rx_pkg();
  uart_seq_item trans;

  int bit_cycles;  // cycles for one bit in a transfer
  bit_cycles = 26000000 / cfg.baud_rate;

  // waiting for start bit
  @(negedge `UARTMON_IF.urxd);

  // sample data in the middle
  repeat(bit_cycles * 3 / 2) @`UARTMON_IF;
  for (int i = 0; i < 8; i++) begin
    
  end
endtask