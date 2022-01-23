class uart_base_seq extends uvm_sequence #(uart_seq_item);
  `uvm_object_utils(uart_base_seq)
  `uvm_object_p_sequencer(vsequencer)

  uart_seq_item uart_trans;

  function new (string name = "uart_base_seq");
    super.new(name);
  endfunction
endclass