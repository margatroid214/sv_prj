typedef enum logic {ODD, EVEN} parity_t;

class uart_seq_item extends uvm_sequence_item;

  // uart frame data
  rand logic[7:0] data; 
  rand logic parity;
  rand int frame_interval;
  rand logic stop_bit;

  rand paritiy_t parity_type;
  rand logic has_parity;
  rand logic has_stop_bit;

  `uvm_object_utils(uart_seq_item)
    `uvm_field_int(data, UVM_ALL_ON);
    `uvm_field_int(parity, UVM_ALL_ON);
    `uvm_field_int(frame_interval, UVM_ALL_ON | UVM_NO_COMPARE);
    `uvm_field_int(stop_bit, UVM_ALL_ON);
    `uvm_field_int(parity_type, UVM_ALL_ON);
    `uvm_field_int(has_parity, UVM_ALL_ON);
    `uvm_field_int(has_stop_bit, UVM_ALL_ON);
  `uvm_object_utils_end

  constraint ifs_constr { frame_interval < 10;}

  function new (string name = "uart_seq_item");
    super.new(name);
  endfunction 

  // function to calculate parity
  function bit calc_parity (parity_t pt);
    if (pt == ODD)
      calc_parity = ^data;
    else
      calc_parity = ~(^data);
  endfunction

  // after randomization, parity is calculated
  function void post_randomize ();
    parity = calc_parity(parity_type);
  endfunction

endclass