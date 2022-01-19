class reg2apb_adpater extends uvm_reg_adapter;

  `uvm_object_utils(reg2apb_adpater)

  function new (string name = "reg2apb_adapter");
    super.new(name);
  endfunction

  virtual function uvm_sequence_item reg2bus (const ref uvm_reg_bus_op rw);
    apb_seq_item apb_trans = apb_seq_item::type_id::create("apb_trans");
    apb_trans.addr = rw.addr;
    apb_trans.data = rw.data;
    apb_trans.wren = (rw.kind == UVM_WRITE) ? 1 : 0;
    `uvm_info(get_type_name(), $sformatf("reg2bus addr=0x%0h data=0x%0h kind=%s", apb_trans.addr, apb_trans.data, rw.kind.name), UVM_DEBUG) 
    return apb_trans;
  endfunction

  virtual function void bus2reg (uvm_sequence_item bus_item, uvm_reg_bus_op rw);
    apb_seq_item apb_trans;
    if (!$cast(apb_trans, bus_item)) begin
      `uvm_fatal(get_type_name(), "failed to cast bus_item to apb_seq_item");
    end

    rw.addr = apb_trans.addr;
    rw.data = apb_trans.data;
    rw.kind = apb_trans.wren ? UVM_WRITE : UVM_READ;
    rw.status = UVM_IS_OK;
  endfunction

endclass