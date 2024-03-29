class apbuart_env extends uvm_env;

  `uvm_component_utils(apbuart_env)

  apb_agent           apb_agt;
  uart_agent          uart_agt;
  vsequencer          v_sqr;
  apbuart_model       mdl;
  apbuart_scoreboard  scb;
  apb_cov             cov_apb;

  uvm_tlm_analysis_fifo #(apb_seq_item) agt_scb_apb_fifo;
  uvm_tlm_analysis_fifo #(uart_seq_item) agt_scb_uart_fifo;

  uvm_tlm_analysis_fifo #(apb_seq_item) agt_mdl_apb_fifo;
  uvm_tlm_analysis_fifo #(uart_seq_item) agt_mdl_uart_fifo;

  uvm_tlm_analysis_fifo #(apb_seq_item) mdl_scb_apb_fifo;
  uvm_tlm_analysis_fifo #(uart_seq_item) mdl_scb_uart_fifo;

  function new (string name = "apbuart_env", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    apb_agt = apb_agent::type_id::create("apb_agent", this);
    uart_agt = uart_agent::type_id::create("uart_agent", this);
    v_sqr = vsequencer::type_id::create("v_sqr", this);
    
    mdl = apbuart_model::type_id::create("mdl", this);
    scb = apbuart_scoreboard::type_id::create("scb", this);
    cov_apb = apb_cov::type_id::create("cov_apb", this);

    agt_scb_apb_fifo = new("agt_scb_apb_fifo", this);
    agt_scb_uart_fifo = new("agt_scb_uart_fifo", this);

    agt_mdl_apb_fifo = new("agt_mdl_apb_fifo", this);
    agt_mdl_uart_fifo = new("agt_mdl_uart_fifo", this);

    mdl_scb_apb_fifo = new("mdl_scb_apb_fifo", this);
    mdl_scb_uart_fifo = new("mdl_scb_uart_fifo", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // agent to coverage
    apb_agt.monitor.ap_mdl.connect(cov_apb.analysis_export);

    // agent to scoreboard
    apb_agt.monitor.ap_scb.connect(agt_scb_apb_fifo.analysis_export);
    scb.act_bgp_apb.connect(agt_scb_apb_fifo.blocking_get_export);

    uart_agt.monitor.ap_scb.connect(agt_scb_uart_fifo.analysis_export);
    scb.act_bgp_uart.connect(agt_scb_uart_fifo.blocking_get_export);

    // agent to monitor
    apb_agt.monitor.ap_mdl.connect(agt_mdl_apb_fifo.analysis_export);
    mdl.bgp_apb.connect(agt_mdl_apb_fifo.blocking_get_export);

    uart_agt.monitor.ap_mdl.connect(agt_mdl_uart_fifo.analysis_export);
    mdl.bgp_uart.connect(agt_mdl_uart_fifo.blocking_get_export);

    // monitor to scoreboard
    mdl.ap_apb.connect(mdl_scb_apb_fifo.analysis_export);
    scb.exp_bgp_apb.connect(mdl_scb_apb_fifo.blocking_get_export);

    mdl.ap_uart.connect(mdl_scb_uart_fifo.analysis_export);
    scb.exp_bgp_uart.connect(mdl_scb_uart_fifo.blocking_get_export);

    uvm_config_db#(apb_sequencer)::set(this, "*", "apb_sqr", apb_agt.sequencer);
    uvm_config_db#(uart_sequencer)::set(this, "*", "uart_sqr", uart_agt.sequencer);
  endfunction

endclass