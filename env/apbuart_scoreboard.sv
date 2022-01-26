class apbuart_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(apbuart_scoreboard)

  uvm_blocking_get_port #(apb_seq_item) exp_bgp_apb;
  uvm_blocking_get_port #(apb_seq_item) act_bgp_apb;

  uvm_blocking_get_port #(uart_seq_item) exp_bgp_uart;
  uvm_blocking_get_port #(uart_seq_item) act_bgp_uart;

  function new (string name = "apbuart_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    exp_bgp_apb = new("exp_bgp_apb", this);
    act_bgp_apb = new("act_bgp_apb", this);
    exp_bgp_uart = new("exp_bgp_uart", this);
    act_bgp_uart = new("act_bgp_uart", this);
  endfunction

  task run_phase (uvm_phase phase);
    fork
      eval_apb;
      eval_uart;
    join
  endtask

  task eval_apb ();
    apb_seq_item exp_tr, act_tr;

    while (1) begin
      exp_bgp_apb.get(exp_tr);
      act_bgp_apb.get(act_tr);
      if (act_tr.compare(exp_tr)) begin
        `uvm_info(get_type_name(), "compare passed", UVM_LOW);
      end else begin
        `uvm_error(get_type_name(), "compare failed");
        $display("expected apb pkt is");
        exp_tr.print();
        $display("actual apb pkt is");
        act_tr.print();
      end
    end
  endtask

  task eval_uart ();
    uart_seq_item exp_tr, act_tr;
    bit com_result;

    while (1) begin
      exp_bgp_uart.get(exp_tr);
      act_bgp_uart.get(act_tr);
      com_result = act_tr.compare(exp_tr);
      // compare frame_interval 
      //if (exp_tr.frame_interval != -1)
      //  com_result = 0;
      if (com_result) begin
        `uvm_info(get_type_name(), "compare passed", UVM_LOW);
      end else begin
        `uvm_error(get_type_name(), "compare failed");
        $display("expected uart pkt is");
        exp_tr.print();
        $display("actual uart pkt is");
        act_tr.print();
      end
    end
  endtask

endclass