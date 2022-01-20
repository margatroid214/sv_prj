// base class for apb sequence
class apb_base_seq extends uvm_sequence #(apb_seq_item);
  `uvm_object_utils(apb_base_seq)
  `uvm_object_p_sequencer(vsequencer)

  uart_reg_block rm;  // register model

  // register model related variables 
  uvm_status_e status;
  rand uvm_reg_data_t value;

  apb_seq_item apb_trans;

  function new (string name = "apb_base_seq");
    super.new(name);
  endfunction

  task body ();
    rm = vsequencer.rm;
  endtask

endclass

class reg_wr_rd_seq extends apb_base_seq;
  `uvm_object_utils(reg_wr_rd_seq)

  function new (string name = "reg_wr_rd_seq")
    super.new(name);
  endfunction

  task body ();
    super.body();
    apb_trans = apb_seq_item::type_id::create("apb_trans");

    // read all registers after write
    for (int i = 0; i < 40; i += 4) begin
      `uvm_do_with(apb_trans, {
                                apb_trans.wren == 'b1;
                                apb_trans.addr == i;
                              }); 
    end

    for (int i = 0; i < 40; i += 4) begin
      `uvm_do_with(apb_trans, {
                                apb_trans.wren == 'b0;
                                apb_trans.addr == i;
                              }); 
    end
  endtask
endclass

class reg_robust_test_seq extends apb_base_seq;
  `uvm_object_utils(reg_robust_test_seq)

  function new (string name = "reg_robust_test_seq")
    super.new(name);
  endfunction

  task body ();
    super.body();
    apb_trans = apb_seq_item::type_id::create("apb_trans");

  endtask
endclass