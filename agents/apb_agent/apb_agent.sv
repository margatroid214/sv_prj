class apb_agent extends uvm_agent;

  `uvm_component_utils(apb_agent)

  uvm_analysis_port #(apb_seq_item) ap;

  apb_driver    driver;
  apb_sequencer sequencer;
  apb_monitor   monitor;

  extern function new (string name = "apb_agent", uvm_component parent);
  extern function void build_phase (uvm_phase phase);
  extern function void connect_phase (uvm_phase phase);

endclass

function apb_agent::new (string name = "apb_agent", uvm_component parent);
  super.new(name, parent);
endfunction

function void apb_agent::build_phase (uvm_phase phase);
  monitor = apb_monitor::type_id::create("monitor", this);
  driver = apb_driver::type_id::create("driver", this);
  sequencer = apb_sequencer::type_id::create("sequencer", this);
endfunction

function void apb_agent::connect_phase (uvm_phase phase);
  driver.seq_item_port.connect(sequencer.seq_item_export);
endfunction