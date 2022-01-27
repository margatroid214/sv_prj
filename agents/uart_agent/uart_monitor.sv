`define UARTMON_IF uart_vif.MONITOR.monitor_cb

class uart_monitor extends uvm_component;

  `uvm_component_utils(uart_monitor)

  virtual uart_if uart_vif;

  apbuart_cfg cfg;

  uvm_analysis_port #(uart_seq_item) ap_scb;  // tlm port for sending transactions out to scoreboard
  uvm_analysis_port #(uart_seq_item) ap_mdl; // tlm port for sending transactions out to reference model

  extern function new (string name = "uart_monitor", uvm_component parent);
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

function void uart_monitor::build_phase (uvm_phase phase);
  super.build_phase(phase);
  if (!uvm_config_db#(virtual uart_if)::get(this, "*", "uart_vif", uart_vif))
    `uvm_error(get_type_name(), "did not get virtual bus handle")
  if (!uvm_config_db#(apbuart_cfg)::get(this, "", "cfg", cfg))
    `uvm_error(get_type_name(), "did not get global config handle")
endfunction

task uart_monitor::run_phase(uvm_phase phase);
  wait(uart_vif.rstn);
  fork
    forever get_rx_pkg();
    forever get_tx_pkg();
  join
endtask

task uart_monitor::get_rx_pkg();
  int inter_frames = 0;  // number of inter-frames
  bit [31:0] bit_cycles;  // cycles for one bit in a transfer
  uart_seq_item trans;
  trans = uart_seq_item::type_id::create("trans");

  bit_cycles = 16 * (cfg.baud_div + 1);

  fork
    @(negedge uart_vif.urxd);  // waiting for next start bit
    begin
      // extract frame interval
      while(1) begin
        repeat(bit_cycles) @(posedge uart_vif.clk);
        ++inter_frames;
      end
    end
  join_any
  disable fork;

  // sample data in the middle
  repeat(bit_cycles * 3 / 2) @(posedge uart_vif.clk);
  for (int i = 0; i < 8; i++) begin
    trans.data[i] = uart_vif.urxd;
    repeat(bit_cycles) @(posedge uart_vif.clk);
  end
  // extract parity 
  if (cfg.rx_has_parity) begin
    trans.parity = uart_vif.urxd;
    repeat(bit_cycles) @(posedge uart_vif.clk);
  end
  // extract stop bit
  if (cfg.rx_has_stop_bit) begin
    trans.stop_bit = uart_vif.urxd;
  end

  trans.frame_interval = inter_frames;
  ap_mdl.write(trans);        
endtask

task uart_monitor::get_tx_pkg();
  bit [31:0] bit_cycles;  // cycles for one bit in a transfer
  int inter_frames = 0;  // number of inter-frames
  uart_seq_item trans;
  trans = uart_seq_item::type_id::create("trans");

  bit_cycles = 16 * (cfg.baud_div + 1);

  fork
    @(negedge uart_vif.utxd);  // waiting for next start bit
    begin
      // extract frame interval
      while(1) begin
        uart_vif.needle <= 1;
        @(posedge uart_vif.clk) uart_vif.needle <= 0;
        repeat(bit_cycles) @(posedge uart_vif.clk);
        ++inter_frames;
      end
    end
  join_any
  disable fork;

  // sample data in the middle
  repeat(bit_cycles * 3 / 2) @(posedge uart_vif.clk);
  for (int i = 0; i < 8; i++) begin
    trans.data[i] = uart_vif.utxd;
    repeat(bit_cycles) @(posedge uart_vif.clk);
  end
  // extract parity 
  if (cfg.tx_has_parity) begin
    trans.parity = uart_vif.utxd;
    repeat(bit_cycles) @(posedge uart_vif.clk);
  end else begin
    trans.parity = 'b0;   //don't care
  end
  // extract stop bit
  if (cfg.tx_has_stop_bit) begin
    trans.stop_bit = uart_vif.utxd;
    //repeat(bit_cycles) @(posedge uart_vif.clk);
  end

  trans.frame_interval = inter_frames;
  ap_scb.write(trans);        
endtask