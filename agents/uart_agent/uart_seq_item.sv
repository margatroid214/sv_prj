typedef enum bit {ODD, EVEN} parity_t;

class uart_seq_item extends uvm_sequence_item;

  // uart frame data
  rand byte data; 
  rand paritiy_t parity_type;
  rand int frame_interval;

  `uvm_object_utils(uart_seq_item)
    `uvm_field_int()
  `uvm_object_utils_end

endclass