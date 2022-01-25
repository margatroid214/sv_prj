class uart_base_seq extends uvm_sequence #(uart_seq_item);
  `uvm_object_utils(uart_base_seq)
  `uvm_declare_p_sequencer(vsequencer)

  uart_seq_item uart_trans;

  function new (string name = "uart_base_seq");
    super.new(name);
  endfunction
endclass

class uart_rx_seq extends uart_base_seq;
  `uvm_object_utils(uart_rx_seq)

  function new (string name = "uart_rx_seq");
    super.new(name);
  endfunction

  task body ();
    super.body();
    uart_trans = uart_seq_item::type_id::create("uart_trans");
    apbuart_cfg cfg = p_sequencer.cfg;

    `uvm_do_with(uart_trans, {
                              uart_trans.has_parity == cfg.rx_has_parity;
                              uart_trans.parity_type == cfg.parity_type;
                              uart_trans.has_stop_bit == cfg.rx_has_stop_bit;
                              uart_trans.stop_bit == 'b1;
    });
  endtask
endclass