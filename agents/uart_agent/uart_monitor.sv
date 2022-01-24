`define UARTMON_IF uart_vif.MONITOR.monitor_cb

class uart_monitor extends uvm_component;

  `uvm_component_utils(uart_monitor)

  virtual uart_if uart_vif;

  apbuart_cfg cfg;

  uvm_analysis_port #(uart_seq_item) ap_scb;  // tlm port for sending transactions out to scoreboard
  uvm_analysis_port #(uart_seq_item) ap_mdl; // tlm port for sending transactions out to reference model

  extern function new (string name = "apb_monitor", uvm_component parent);
  extern function void build_phase (uvm_phase phase);
  extern task run_phase (uvm_phase phase);
  extern task get_tx_pkg();
  extern task get_rx_pkg();

endclass

function uart_monitor::new (string name = "uart_monitor", uvm_component parent);
  super.new(name, parent);
  ap_scb = new("ap_scb", this);
  ap_mdl = new("ap_mdl", this);
endfunction

function uart_monitor::build_phase (uvm_phase phase);
  super.build_phase(phase);
  if (!uvm_config_db#(virtual uart_if)::get(this, "*", "uart_vif", uart_vif))
    `uvm_error(get_type_name(), "did not get virtual bus handle")
  if (!uvm_config_db#(apbuart_cfg)::get(this, "*", "cfg", cfg))
    `uvm_error(get_type_name(), "did not get global config handle")
endfunction

function uart_monitor::run_phase(uvm_phase phase);
  wait(uart_vif.rstn);
  fork
    forever get_rx_pkg();
    forever get_tx_pkg();
  join
endfunction

task uart_monitor::get_rx_pkg();
  uart_seq_item trans;
  trans = uart_seq_item::type_id::create("trans");

  int bit_cycles;  // cycles for one bit in a transfer
  bit_cycles = 26000000 / cfg.baud_rate;

  int inter_frames = 0;  // number of inter-frames

  fork
    @(negedge `UARTMON_IF.urxd);  // waiting for next start bit
    begin
      // extract frame interval
      while(1) begin
        repeat(bit_cycles / 2) @`UARTMON_IF;
        ++inter_frames;
      end
    end
  join_any
  disable fork

  // sample data in the middle
  repeat(bit_cycles * 3 / 2) @`UARTMON_IF;
  for (int i = 0; i < 8; i++) begin
    trans.data[i] = `UARTMON_IF.urxd;
    repeat(bit_cycles) @`UARTMON_IF;
  end
  // extract parity 
  if (cfg.rx_has_parity) begin
    trans.parity = `UARTMON_IF.urxd;
    repeat(bit_cycles) @`UARTMON_IF;
  end
  // extract stop bit
  if (cfg.rx_has_stop_bit) begin
    trans.stop_bit = `UARTMON_IF.urxd;
    repeat(bit_cycles) @`UARTMON_IF;
  end

  trans.frame_interval = inter_frames;
  ap_mdl.write(trans);        
endtask

task uart_monitor::get_tx_pkg();
  uart_seq_item trans;
  trans = uart_seq_item::type_id::create("trans");

  int bit_cycles;  // cycles for one bit in a transfer
  bit_cycles = 26000000 / cfg.baud_rate;

  int inter_frames = 0;  // number of inter-frames

  fork
    @(negedge `UARTMON_IF.utxd);  // waiting for next start bit
    begin
      // extract frame interval
      while(1) begin
        repeat(bit_cycles / 2) @`UARTMON_IF;
        ++inter_frames;
      end
    end
  join_any
  disable fork

  // sample data in the middle
  repeat(bit_cycles * 3 / 2) @`UARTMON_IF;
  for (int i = 0; i < 8; i++) begin
    trans.data[i] = `UARTMON_IF.utxd;
    repeat(bit_cycles) @`UARTMON_IF;
  end
  // extract parity 
  if (cfg.tx_has_parity) begin
    trans.parity = `UARTMON_IF.utxd;
    repeat(bit_cycles) @`UARTMON_IF;
  end
  // extract stop bit
  if (cfg.tx_has_stop_bit) begin
    trans.stop_bit = `UARTMON_IF.utxd;
    repeat(bit_cycles) @`UARTMON_IF;
  end

  trans.frame_interval = inter_frames;
  ap_scb.write(trans);        
endtask