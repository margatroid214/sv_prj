class vsequencer extends uvm_sequencer;

  `uvm_component_utils(vsequencer)

  apb_sequencer   apb_sqr;
  uart_sequencer  uart_sqr;
  apbuart_cfg     cfg;

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void end_of_elaboration_phase (uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    if (!uvm_config_db#(apb_sequencer)::get(this, "", "apb_sqr", apb_sqr))
        `uvm_fatal(get_type_name(), "no apb_sqr specified for this instance");
    if (!uvm_config_db#(uart_sequencer)::get(this, "", "uart_sqr", uart_sqr))
        `uvm_fatal(get_type_name(), "No uart_sqr specified for this instance");
    if (!uvm_config_db#(apbuart_cfg)::get(this, "", "cfg", cfg))
        `uvm_fatal(get_type_name(), "no cfg specified for this instance");
  endfunction

endclass