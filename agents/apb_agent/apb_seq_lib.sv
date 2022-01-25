// base class for apb sequence
class apb_base_seq extends uvm_sequence #(apb_seq_item);
  `uvm_object_utils(apb_base_seq)
  `uvm_object_p_sequencer(vsequencer)

  apb_seq_item apb_trans;

  function new (string name = "apb_base_seq");
    super.new(name);
  endfunction

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

class uart_cfg_seq extends apb_base_seq;
  `uvm_object_utils(uart_cfg_seq)

  function new (string name = "uart_cfg_seq")
    super.new(name);
  endfunction

  task body ();
    super.body();
    apb_trans = apb_seq_item::type_id::create("apb_trans");

    bit [31:0] tx_data;
    apbuart_cfg cfg = p_sequencer.cfg;

    // config baud rate
    `uvm_do_with(apb_trans, {
                              apb_trans.wren == 'b1;
                              apb_trans.addr == `UART_DIV;
                              apb_trans.data == 1625000 / cfg.baud_rate;
                            }); 
    // config uart function
    tx_data = {28'h0, cfg.rx_has_stop_bit, cfg.tx_has_stop_bit, cfg.parity_type, cfg.tx_has_parity};
    `uvm_do_with(apb_trans, {
                              apb_trans.wren == 'b1;
                              apb_trans.addr == `UART_DIV;
                              apb_trans.data == tx_data;
                            }); 
    // config trigger depth                        
    `uvm_do_with(apb_trans, {
                              apb_trans.wren == 'b1;
                              apb_trans.addr == `UART_RXTD;
                              apb_trans.data == cfg.rx_trig_depth;
                            }); 
    `uvm_do_with(apb_trans, {
                              apb_trans.wren == 'b1;
                              apb_trans.addr == `UART_TXTD;
                              apb_trans.data == cfg.tx_trig_depth;
                            }); 
    // config frame interval
    `uvm_do_with(apb_trans, {
                              apb_trans.wren == 'b1;
                              apb_trans.addr == `UART_IFS;
                              apb_trans.data == cfg.tx_ifs;
                            }); 
  endtask
endclass

class uart_tx_seq extends apb_base_seq;
  `uvm_object_utils(reg_robust_test_seq)

  function new (string name = "uart_tx_seq")
    super.new(name);
  endfunction

  task body ();
    super.body();
    apb_trans = apb_seq_item::type_id::create("apb_trans");
    `uvm_do_with(apb_trans, {
                              apb_trans.wren == 'b1;
                              apb_trans.addr == `UART_TXD;
                            }); 
  endtask
endclass


class check_status_seq extends apb_base_seq;
  `uvm_object_utils(reg_robust_test_seq)

  function new (string name = "check_status_seq")
    super.new(name);
  endfunction

  task body ();
    super.body();
    apb_trans = apb_seq_item::type_id::create("apb_trans");
    `uvm_do_with(apb_trans, {
                              apb_trans.wren == 'b0;
                              apb_trans.addr == `UART_CFG;
                            }); 
    `uvm_do_with(apb_trans, {
                              apb_trans.wren == 'b0;
                              apb_trans.addr == `UART_SR;
                            }); 
    `uvm_do_with(apb_trans, {
                              apb_trans.wren == 'b0;
                              apb_trans.addr == `UART_RDL;
                            }); 
    `uvm_do_with(apb_trans, {
                              apb_trans.wren == 'b0;
                              apb_trans.addr == `UART_TDL;
                            }); 
  endtask
endclass

class clear_irq_seq extends apb_base_seq;
  `uvm_object_utils(reg_robust_test_seq)

  function new (string name = "clear_irq_seq")
    super.new(name);
  endfunction

  task body ();
    super.body();
    apb_trans = apb_seq_item::type_id::create("apb_trans");
    `uvm_do_with(apb_trans, {
                              apb_trans.wren == 'b1;
                              apb_trans.addr == `UART_SR;
                              apb_trans.data == 'h000f;
                            }); 
  endtask
endclass

class illegal_op_seq extends apb_base_seq;
  `uvm_object_utils(reg_robust_test_seq)

  function new (string name = "illegal_op_seq")
    super.new(name);
  endfunction

  task body ();
    super.body();
    apb_trans = apb_seq_item::type_id::create("apb_trans");
    /*** illegal addr ***/
    `uvm_do_with(apb_trans, {
                              apb_trans.wren == 'b1;
                              !(apb_trans.addr inside {32'h0000, 32'h0004, 32'h0008, 32'h000c, 32'h0010,32'h0014, 32'h0018, 32'h001c, 32'h0020, 32'h0024});
                              apb_trans.data == 'h000f;
                            }); 
    `uvm_do_with(apb_trans, {
                              apb_trans.wren == 'b0;
                              !(apb_trans.addr inside {32'h0000, 32'h0004, 32'h0008, 32'h000c, 32'h0010,32'h0014, 32'h0018, 32'h001c, 32'h0020, 32'h0024});
                              apb_trans.data == 'h000f;
                            }); 
    /*** reserved region ***/
    // write
    bit [31:0] tx_data;
    apbuart_cfg cfg = p_sequencer.cfg;
    `uvm_do_with(apb_trans, {
                              apb_trans.wren == 'b1;
                              apb_trans.addr == `UART_DIV;
                              apb_trans.data[9:0] == 1625000 / cfg.baud_rate;
                            }); 
    tx_data = {28'h0, cfg.rx_has_stop_bit, cfg.tx_has_stop_bit, cfg.parity_type, cfg.tx_has_parity};
    `uvm_do_with(apb_trans, {
                              apb_trans.wren == 'b1;
                              apb_trans.addr == `UART_DIV;
                              apb_trans.data[3:0] == tx_data[3:0];
                            }); 
    `uvm_do_with(apb_trans, {
                              apb_trans.wren == 'b1;
                              apb_trans.addr == `UART_RXTD;
                              apb_trans.data[3:0] == cfg.rx_trig_depth;
                            }); 
    `uvm_do_with(apb_trans, {
                              apb_trans.wren == 'b1;
                              apb_trans.addr == `UART_TXTD;
                              apb_trans.data[3:0] == cfg.tx_trig_depth;
                            }); 
    `uvm_do_with(apb_trans, {
                              apb_trans.wren == 'b1;
                              apb_trans.addr == `UART_IFS;
                              apb_trans.data[3:0] == cfg.tx_ifs;
                            }); 
    // read
    `uvm_do_with(apb_trans, {
                              apb_trans.wren == 'b0;
                              apb_trans.addr == `UART_DIV;
                            }); 
    `uvm_do_with(apb_trans, {
                              apb_trans.wren == 'b0;
                              apb_trans.addr == `UART_DIV;
                            }); 
    `uvm_do_with(apb_trans, {
                              apb_trans.wren == 'b0;
                              apb_trans.addr == `UART_RXTD;
                            }); 
    `uvm_do_with(apb_trans, {
                              apb_trans.wren == 'b0;
                              apb_trans.addr == `UART_TXTD;
                            }); 
    `uvm_do_with(apb_trans, {
                              apb_trans.wren == 'b0;
                              apb_trans.addr == `UART_IFS;
                            }); 
    /*** read-only write ***/                          
    `uvm_do_with(apb_trans, {
                              apb_trans.wren == 'b1;
                              apb_trans.addr == `UART_RXD;
                            }); 
    `uvm_do_with(apb_trans, {
                              apb_trans.wren == 'b1;
                              apb_trans.addr == `UART_RDL;
                            }); 
    `uvm_do_with(apb_trans, {
                              apb_trans.wren == 'b1;
                              apb_trans.addr == `UART_TDL;
                            }); 
  endtask
endclass