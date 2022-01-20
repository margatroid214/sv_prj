typedef enum bit {ODD, EVEN} parity_t;

class uart_seq_item extends uvm_sequence_item;

  // uart frame data
  rand byte data; 
  rand bit parity;
  rand int frame_interval;
  rand bit[1:0] stop_bits; // take half a cycle as unit

  rand paritiy_t parity_type;
  rand bit has_parity;

  `uvm_object_utils(uart_seq_item)
    `uvm_field_int(data, UVM_ALL_ON);
    `uvm_field_int(parity, UVM_ALL_ON);
    `uvm_field_int(frame_interval, UVM_ALL_ON);
    `uvm_field_int(stop_bits, UVM_ALL_ON);
    `uvm_field_int(parity_type, UVM_ALL_ON);
    `uvm_field_int(has_parity, UVM_ALL_ON);
  `uvm_object_utils_end

  function new (string name = "uart_seq_item");
    super.new(name);
  endfunction 

  // function to calculate parity
  function bit calc_parity ();
    if (parity_type == ODD)
      calc_parity = ^data;
    else
      calc_parity = ~(^data);
  endfunction

  // after randomization, parity is calculated
  function void post_randomize ();
    parity = calc_parity;
  endfunction

endclass