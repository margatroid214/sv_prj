class apbuart_vseq_base extends uvm_sequence;
  `uvm_object_utils(apbuart_vseq_base)
  `uvm_declare_p_sequencer(vsequencer)

  apb_sequencer apb_sqr;

  function new (string name = "apbuart_vseq_base");
    super.new(name);
  endfunction
endclass

class apbuart_wr_rd_seq extends apbuart_vseq_base;
  `uvm_object_utils(apb_wr_rd_seq)

  function new (string name = "apb_wr_rd_seq");
    super.new(name);
  endfunction

  task body ();
    reg_wr_rd_seq apbuart_seq;
    `uvm_do_on(apbuart_seq, apb_sqr);
  endtask
endclass