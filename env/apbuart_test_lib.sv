class apbuart_base_test extends uvm_test;
  `uvm_component_utils(apbuart_base_test)

  apbuart_env env;
  apbuart_cfg cfg;
  virtual uart_if uart_vif;
  virtual apb_if apb_vif;

  int test_run_cyc = 100000;

  function new (string name = "apbuart_base_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    env = apbuart_env::type_id::create("env", this);
    cfg = apbuart_cfg::type_id::create("cfg", this);
    uvm_config_db#(apbuart_cfg)::set(this, "*", "cfg", cfg);
    if (!uvm_config_db#(virtual uart_if)::get(this, "*", "uart_vif", uart_vif))
      `uvm_error(get_type_name(), "did not get virtual bus handle")
    if (!uvm_config_db#(virtual apb_if)::get(this, "*", "apb_vif", apb_vif))
      `uvm_error(get_type_name(), "did not get virtual bus handle")
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
    repeat(test_run_cyc) @(posedge uart_vif.clk);
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
    repeat(test_run_cyc) @(posedge uart_vif.clk);
    phase.drop_objection(this);
  endtask
endclass

class apbuart_stable_test extends apbuart_base_test;
  `uvm_component_utils(apbuart_stable_test)

  apbuart_tx_seq tx_sq;
  apbuart_illegal_seq perturb_sq;

  function new (string name = "apbuart_stable_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    tx_sq = apbuart_tx_seq::type_id::create("tx_sq", this);
    perturb_sq = apbuart_illegal_seq::type_id::create("perturb_sq", this);
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
    tx_sq.start(env.v_sqr);
    repeat(1000) @(posedge uart_vif.clk);
    perturb_sq.start(env.v_sqr);
    repeat(test_run_cyc) @(posedge uart_vif.clk);
    phase.drop_objection(this);
  endtask
endclass

class apbuart_random_test extends apbuart_base_test;
  `uvm_component_utils(apbuart_random_test)

  apbuart_tx_seq rand_sq;

  function new (string name = "apbuart_random_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    rand_sq = apbuart_tx_seq::type_id::create("rand_seq", this);
  endfunction

  task run_phase (uvm_phase phase);
    cfg.srandom(2);
    // set config randomly
    cfg.randomize() with {
      tx_has_parity == rx_has_parity;
      baud_div inside {168, 84, 41, 13};
      tx_has_stop_bit == rx_has_stop_bit;
    };

    phase.raise_objection(this);
    rand_sq.start(env.v_sqr);
    repeat(test_run_cyc) @(posedge uart_vif.clk);
    phase.drop_objection(this);
  endtask
endclass

class apbuart_irq_test extends apbuart_base_test;
  `uvm_component_utils(apbuart_irq_test)

  apbuart_cont_seq cont_sq;
  apbuart_irq_handle_seq irq_sq;

  function new (string name = "apbuart_irq_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    cont_sq = apbuart_cont_seq::type_id::create("cont_sq", this);
    irq_sq = apbuart_irq_handle_seq::type_id::create("irq_sq", this);
  endfunction

  task run_phase (uvm_phase phase);
    // set config
    cfg.baud_div = 'd13;
    cfg.tx_has_parity = 'b0;
    cfg.rx_has_parity = 'b0;
    cfg.tx_has_stop_bit = 'b1;
    cfg.rx_has_stop_bit = 'b1;
    cfg.parity_type = ODD;
    cfg.tx_trig_depth = 'h8;
    cfg.rx_trig_depth = 'h1;
    cfg.tx_ifs = 'h2;

    phase.raise_objection(this);
    cont_sq.start(env.v_sqr);
    fork
      begin
        @(posedge apb_vif.uart_int);
        repeat(5000) @(posedge uart_vif.clk);   // intense time for ref model to adapt to the real running scheme
        irq_sq.start(env.v_sqr);
      end
      begin
        repeat(test_run_cyc) @(posedge uart_vif.clk);
      end
    join
    phase.drop_objection(this);
  endtask
endclass