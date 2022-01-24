class apbuart_base_test extends uvm_test;
  `uvm_component_utils(apbuart_base_test)

  apbuart_env env;
  apbuart_cfg cfg;

  function new (string name = "apbuart_base_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase (uvm_phase phase);
    super.build_phase();
    env = apbuart_env::type_id::create("env", this);
    cfg = apbuart_cfg::type_id::create("cfg", this);
    uvm_config_db#(apbuart_cfg)::set(this, "*", "cfg", cfg);
  endfunction

  function void report_phase (uvm_phase phase);
    uvm_report_server server;
    int err_num;
    super.report_phase(phase);

    server = get_reporter_server();
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