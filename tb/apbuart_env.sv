class apbuart_env extends uvm_env;

  `uvm_component_utils(apbuart_env)

  apb_agent           apb_agent;
  uart_agent          uart_agent;
  vsequencer          v_sqr;
  apbuart_model       mdl;
  apbuart_scoreboard  scb;

  uvm_tlm_analysis_fifo #(apb_seq_item) agt_scb_apb_fifo;
  uvm_tlm_analysis_fifo #(uart_seq_item) agt_scb_uart_fifo;
  uvm_tlm_analysis_fifo #(irq_t) agt_scb_irq_fifo;

  uvm_tlm_analysis_fifo #(apb_seq_item) agt_mdl_apb_fifo;
  uvm_tlm_analysis_fifo #(uart_seq_item) agt_mdl_uart_fifo;

  uvm_tlm_analysis_fifo #(apb_seq_item) mdl_scb_apb_fifo;
  uvm_tlm_analysis_fifo #(uart_seq_item) mdl_scb_uart_fifo;
  uvm_tlm_analysis_fifo #(irq_t) mdl_scb_irq_fifo;

  function new (string name = "apbuart_env", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    apb_agent = apb_agent::type_id::create("apb_agent", this);
    uart_agent = uart_agent::type_id::create("uart_agent", this);
    v_sqr = vsequencer::type_id::create("v_sqr", this);
    mdl = apbuart_model::type_id::create("mdl", this);
    scb = apbuart_model::type_id::create("scb", this);

    apb_agent.is_active = UVM_ACTIVE;
    uart_agent.is_active = UVM_ACTIVE;

    agt_scb_apb_fifo = new("agt_scb_apb_fifo", this);
    agt_scb_uart_fifo = new("agt_scb_uart_fifo", this);
    agt_scb_irq_fifo = new("agt_scb_irq_fifo", this);
    agt_mdl_apb_fifo = new("agt_mdl_apb_fifo", this);
    agt_mdl_uart_fifo = new("agt_mdl_uart_fifo", this);
    mdl_scb_apb_fifo = new("mdl_scb_apb_fifo", this);
    mdl_scb_uart_fifo = new("mdl_scb_uart_fifo", this);
    mdl_scb_irq_fifo = new("mdl_scb_irq_fifo", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // agent to scoreboard
    apb_agent.monitor.ap_scb_apb.connect(agt_scb_apb_fifo.analysis_export);
    scb.act_bgp_apb.connect(agt_scb_apb_fifo.blocking_get_export);

    uart_agent.monitor.ap_scb.connect(agt_scb_uart_fifo.analysis_export);
    scb.act_bgp_uart.connect(agt_scb_uart_fifo.blocking_get_export);

    apb_agent.monitor.ap_scb_irq.connect(agt_scb_irq_fifo.analysis_export);
    scb.act_bgp_irq.connect(agt_scb_irq_fifo.blocking_get_export);

    // agent to monitor
    apb_agent.monitor.ap_mdl.connect(agt_mdl_apb_fifo.analysis_export);
    mdl.exp_bgp_apb.connect(agt_mdl_apb_fifo.blocking_get_export);

    uart_agent.monitor.ap_mdl.connect(agt_mdl_uart_fifo.analysis_export);
    mdl.exp_bgp_uart.connect(agt_mdl_uart_fifo.blocking_get_export);

    // monitor to scoreboard
    mdl.ap_apb.connect(mdl_scb_apb_fifo.analysis_export);
    scb.act_bgp_apb.connect(mdl_scb_apb_fifo.blocking_get_export);

    mdl.ap_uart.connect(mdl_scb_uart_fifo.analysis_export);
    scb.act_bgp_uart.connect(mdl_scb_uart_fifo.blocking_get_export);

    mdl.ap_irq.connect(mdl_scb_irq_fifo.analysis_export);
    scb.act_bgp_irq.connect(mdl_scb_irq_fifo.blocking_get_export);

    uvm_config_db#(apb_sequencer)::set(this, "*", "apb_sqr", apb_agent.sequencer);
    uvm_config_db#(uart_sequencer)::set(this, "*", "uart_sqr", uart_agent.sequencer);
  endfunction

endclass