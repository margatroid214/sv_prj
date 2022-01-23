class uart_agent extends uvm_agent;

  `uvm_component_utils(uart_agent)

  uvm_analysis_port #(uart_seq_item) ap;

  uart_driver    driver;
  uart_sequencer sequencer;
  uart_monitor   monitor;
  apbuart_cfg    cfg;

  extern function new (string name, uvm_component parent);
  extern function void build_phase (uvm_phase phase);
  extern function void connect_phase (uvm_phase phase);

endclass

function uart_agent::new (string name = "uart_agent", uvm_component parent);
  super.new(name, parent);
endfunction

function void uart_agent::build_phase (uvm_phase phase);
  if (!uvm_config_db#(apbuart_cfg)::get(this, "*", "cfg", cfg))
    `uvm_error(get_type_name(), "did not get global config handle")
  monitor = uart_monitor::type_id::create("monitor", this);
  if (is_active == UVM_ACTIVE) begin
    driver = uart_driver::type_id::create("driver", this);
    sequencer = uart_sequencer::type_id::create("sequencer", this);
  end
endfunction

function void uart_agent::connect_phase (uvm_phase phase);
  if (is_active)
    driver.seq_item_port.connect(sequencer.seq_item_export);
  ap = monitor.ap;
endfunction