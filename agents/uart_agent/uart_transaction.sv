typedef enum bit {ODD, EVEN} parity_t;

class uart_transaction extends uvm_sequence_item;

  rand byte data;
  rand paritiy_t parity_type;
  rand int data_interval;

  `uvm_object_utils(uart_transaction)
    `uvm_field_int()
  `uvm_object_utils_end

endclass