class apbuart_vseq_base extends uvm_sequence;
  `uvm_object_utils(apbuart_vseq_base)
  `uvm_declare_p_sequencer(vsequencer)

  apb_sequencer apb_sqr;
  uart_sequencer uart_sqr;

  function new (string name = "apbuart_vseq_base");
    super.new(name);
  endfunction

  task body();
    apb_sqr = p_sequencer.apb_sqr;
    uart_sqr = p_sequencer.uart_sqr;
  endtask
endclass

class apbuart_wr_rd_seq extends apbuart_vseq_base;
  `uvm_object_utils(apbuart_wr_rd_seq)

  function new (string name = "apbuart_wr_rd_seq");
    super.new(name);
  endfunction

  task body ();
    reg_wr_rd_seq apbuart_seq;
    super.body();
    apbuart_seq = reg_wr_rd_seq::type_id::create("apbuart_seq");
    apbuart_seq.cfg = p_sequencer.cfg;
    apbuart_seq.start(apb_sqr);
  endtask
endclass

class apbuart_tx_seq extends apbuart_vseq_base;
  `uvm_object_utils(apbuart_tx_seq)

  function new (string name = "apbuart_tx_seq");
    super.new(name);
  endfunction

  task body ();
    uart_cfg_seq cfg_seq;
    uart_tx_seq  tx_seq;
    super.body();
    cfg_seq = uart_cfg_seq::type_id::create("cfg_seq");
    tx_seq = uart_tx_seq::type_id::create("tx_seq");
    cfg_seq.cfg = p_sequencer.cfg;
    tx_seq.cfg = p_sequencer.cfg;
    cfg_seq.start(apb_sqr);
    repeat(8) begin
      tx_seq.start(apb_sqr);
    end
  endtask
endclass

class apbuart_cont_seq extends apbuart_vseq_base;
  `uvm_object_utils(apbuart_cont_seq)

  function new (string name = "apbuart_cont_seq");
    super.new(name);
  endfunction

  task body ();
    uart_cfg_seq cfg_seq;
    uart_tx_seq  tx_seq;
    super.body();
    cfg_seq = uart_cfg_seq::type_id::create("cfg_seq");
    tx_seq = uart_tx_seq::type_id::create("tx_seq");
    cfg_seq.cfg = p_sequencer.cfg;
    tx_seq.cfg = p_sequencer.cfg;
    cfg_seq.start(apb_sqr);
    repeat(16) begin
      tx_seq.start(apb_sqr);
    end
  endtask
endclass

class apbuart_irq_handle_seq extends apbuart_vseq_base;
  `uvm_object_utils(apbuart_irq_handle_seq)

  function new (string name = "apbuart_irq_handle_seq");
    super.new(name);
  endfunction

  task body ();
    check_irq_seq irq_chk_seq;
    clear_irq_seq irq_clr_seq;
    super.body();
    irq_chk_seq = check_irq_seq::type_id::create("irq_chk_seq");
    irq_clr_seq = clear_irq_seq::type_id::create("irq_clr_seq");
    irq_chk_seq.start(apb_sqr);
    irq_clr_seq.start(apb_sqr);
  endtask
endclass

class apbuart_illegal_seq extends apbuart_vseq_base;
  `uvm_object_utils(apbuart_illegal_seq)

  function new (string name = "apbuart_illegal_seq");
    super.new(name);
  endfunction

  task body ();
    illegal_op_seq illegal_seq;
    super.body();
    illegal_seq = illegal_op_seq::type_id::create("illegal_seq");
    illegal_seq.cfg = p_sequencer.cfg;
    illegal_seq.start(apb_sqr);
  endtask
endclass