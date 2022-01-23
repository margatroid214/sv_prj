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
  wait(uart_vif.rstn);
  fork
    begin
      @(negedge `UARTMON_IF.urxd);
      forever get_rx_pkg();
    end
    begin
      @(negedge `UARTMON_IF.utxd);
      forever get_tx_pkg();
    end
  join
endfunction

task uart_monitor::get_rx_pkg();
  uart_seq_item trans;
  trans = uart_seq_item::type_id::create("trans");

  int bit_cycles;  // cycles for one bit in a transfer
  bit_cycles = 26000000 / cfg.baud_rate;

  int inter_frames = 0;  // number of inter-frames

  // sample data in the middle
  repeat(bit_cycles * 3 / 2) @`UARTMON_IF;
  for (int i = 0; i < 8; i++) begin
    trans.data[i] = `UARTMON_IF.urxd;
    repeat(bit_cycles) @`UARTMON_IF;
  end
  // extract parity 
  if (cfg.rx_has_parity) begin
    trans.parity = `UARTMON_IF.urxd;
  end

  fork
    @(negedge `UARTMON_IF.urxd);  // waiting for next start bit
    begin
      // extract stop bits
      repeat(bit_cycles / 2) @`UARTMON_IF;
      repeat(cfg.rx_stop_bits) begin
        repeat(bit_cycles / 2) @`UARTMON_IF;
      end
      // extract frame interval
      while(1) begin
        repeat(bit_cycles / 2) @`UARTMON_IF;
        ++inter_frames;
      end
    end
  join_any
  disable fork

  trans.frame_interval = inter_frames;
  ap.write(trans);        
endtask

task uart_monitor::get_tx_pkg();
  uart_seq_item trans;
  trans = uart_seq_item::type_id::create("trans");

  int bit_cycles;  // cycles for one bit in a transfer
  bit_cycles = 26000000 / cfg.baud_rate;

  int inter_frames = 0;  // number of inter-frames

  // sample data in the middle
  repeat(bit_cycles * 3 / 2) @`UARTMON_IF;
  for (int i = 0; i < 8; i++) begin
    trans.data[i] = `UARTMON_IF.utxd;
    repeat(bit_cycles) @`UARTMON_IF;
  end
  // extract parity 
  if (cfg.tx_has_parity) begin
    trans.parity = `UARTMON_IF.utxd;
  end

  fork
    @(negedge `UARTMON_IF.utxd);  // waiting for next start bit
    begin
      // extract stop bits
      repeat(bit_cycles / 2) @`UARTMON_IF;
      repeat(cfg.tx_stop_bits) begin
        repeat(bit_cycles / 2) @`UARTMON_IF;
      end
      // extract frame interval
      while(1) begin
        repeat(bit_cycles / 2) @`UARTMON_IF;
        ++inter_frames;
      end
    end
  join_any
  disable fork

  trans.frame_interval = inter_frames;
  ap.write(trans);        
endtask