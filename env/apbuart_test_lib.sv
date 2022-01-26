class apbuart_base_test extends uvm_test;
  `uvm_component_utils(apbuart_base_test)

  apbuart_env env;
  apbuart_cfg cfg;

  function new (string name = "apbuart_base_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    env = apbuart_env::type_id::create("env", this);
    cfg = apbuart_cfg::type_id::create("cfg", this);
    uvm_config_db#(apbuart_cfg)::set(this, "*", "cfg", cfg);
  endfunction

  function void report_phase (uvm_phase phase);
    uvm_report_server server;
    int err_num;
    super.report_phase(phase);

    server = uvm_report_server::get_server();
    err_num = server.get_severity_count(UVM_ERROR);

    if (err_num == 0) begin
      $display("###########################################");
      $display("############    TEST PASSED    ############");
      $display("###########################################");
    end else begin
      $display("###########################################");
      $display("############    TEST FAILED    ############");
      $display("###########################################");
    end
  endfunction  
endclass

class apbuart_wr_rd_test extends apbuart_base_test;
  `uvm_component_utils(apbuart_wr_rd_test)

  apbuart_wr_rd_seq wr_rd_sq;

  function new (string name = "apbuart_wr_rd_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    wr_rd_sq = apbuart_wr_rd_seq::type_id::create("wr_rd_sq", this);
  endfunction

  task run_phase (uvm_phase phase);
    cfg.baud_div = 'd13;
    phase.raise_objection(this);
    wr_rd_sq.start(env.v_sqr);
    phase.drop_objection(this);
  endtask
endclass

class apbuart_tx_basic_test extends apbuart_base_test;
  `uvm_component_utils(apbuart_tx_basic_test)

  apbuart_tx_seq basic_sq;
  function new (string name = "apbuart_tx_basic_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    basic_sq = apbuart_tx_seq::type_id::create("basic_sq", this);
  endfunction

  task run_phase (uvm_phase phase);
  // set config
    cfg.baud_div = 'd13;
    cfg.tx_has_parity = 'b0;
    cfg.rx_has_parity = 'b0;
    cfg.tx_has_stop_bit = 'b1;
    cfg.rx_has_stop_bit = 'b1;
    cfg.parity_type = ODD;
    cfg.tx_trig_depth = 'h0;
    cfg.rx_trig_depth = 'h1;
    cfg.tx_ifs = 'h2;

    phase.raise_objection(this);
    basic_sq.start(env.v_sqr);
    while(1) begin
      #1;
    end
    phase.drop_objection(this);
  endtask
endclass

class apbuart_illegal_test extends apbuart_base_test;
  `uvm_component_utils(apbuart_illegal_test)

  uart_cfg_seq cfg_sq;    
  illegal_op_seq illegal_sq;

  function new (string name = "apbuart_wr_rd_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    cfg_sq = uart_cfg_seq::type_id::create("cfg_sq", this);
    illegal_sq = illegal_op_seq::type_id::create("illegal_sq", this);
  endfunction

  task run_phase (uvm_phase phase);
  // set config
    cfg.baud_div = 'd13;
    cfg.tx_has_parity = 'b0;
    cfg.rx_has_parity = 'b0;
    cfg.tx_has_stop_bit = 'b1;
    cfg.rx_has_stop_bit = 'b1;
    cfg.parity_type = ODD;
    cfg.tx_trig_depth = 'h0;
    cfg.rx_trig_depth = 'h1;
    cfg.tx_ifs = 'h2;

    phase.raise_objection(this);
    cfg_sq.start(env.v_sqr.apb_sqr);
    illegal_sq.start(env.v_sqr.apb_sqr);
    phase.drop_objection(this);
  endtask
endclass

class apbuart_random_test extends apbuart_base_test;
  `uvm_component_utils(apbuart_illegal_test)

  uart_cfg_seq cfg_sq;    
  uart_tx_seq tx_sq;

  function new (string name = "apbuart_wr_rd_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    cfg_sq = uart_cfg_seq::type_id::create("cfg_sq", this);
    tx_sq = uart_tx_seq::type_id::create("tx_sq", this);
  endfunction

  task run_phase (uvm_phase phase);
    // set config randomly
    cfg.randomize() with {
      tx_has_parity == rx_has_parity;
      baud_div inside {168, 84, 41, 13};
      tx_has_stop_bit == rx_has_stop_bit;
    };

    phase.raise_objection(this);
    cfg_sq.start(env.v_sqr.apb_sqr);
    repeat(16)
      tx_sq.start(env.v_sqr.apb_sqr);
    phase.drop_objection(this);
  endtask
endclass