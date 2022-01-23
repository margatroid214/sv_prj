class apbuart_env extends uvm_env;

  `uvm_component_utils(apbuart_env)

  apb_agent   apb_agent;
  uart_agent  uart_agent;
  vsequencer  v_sqr;

  function new (string name = "apbuart_env", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase (uvm_phase phase);
  endfunction

endclass