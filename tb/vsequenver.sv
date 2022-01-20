class vsequencer extends uvm_sequencer;

  `uvm_component_utils(vsequencer)

  apb_sequencer apb_sqr;

  uart_reg_block rm;

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction

endclass