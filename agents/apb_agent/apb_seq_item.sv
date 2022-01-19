class apb_seq_item extends uvm_sequence_item;

  rand logic [31:0] addr;
  rand logic [31:0] data;
  rand logic        wren;
  rand int          interval;

  // constructor
  function new (string name = "apb_seq_item");
    super.new(name);
  endfunction

  // transaction registration
  `uvm_object_utils_begin (apb_seq_item)
    `uvm_field_int (addr, UVM_ALL_ON);
    `uvm_field_int (data, UVM_ALL_ON);
    `uvm_field_int (wren, UVM_ALL_ON);
    `uvm_field_int (interval, UVM_ALL_ON);
  `uvm_object_utils_end

endclass