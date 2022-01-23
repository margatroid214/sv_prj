`define APBMON_IF apb_vif.MONITOR.monitor_cb

class apb_monitor extends uvm_monitor;

  `uvm_component_utils(apb_monitor);

  virtual apb_if apb_vif;

  uvm_analysis_port #(apb_seq_item) ap_scb; // tlm port for sending transactions out to scoreboard
  uvm_analysis_port #(apb_seq_item) ap_mdl; // tlm port for sending transactions out to reference model

  extern function new (string name = "apb_monitor", uvm_component parent);
  extern function void build_phase (uvm_phase phase);
  extern task run_phase (uvm_phase phase);

endclass

function apb_monitor::new (string name = "apb_monitor", uvm_component parent);
  super.new(name, parent);
  ap_scb = new("ap_scb", this);
  ap_mdl = new("ap_mdl", this);
endfunction

function apb_monitor::build_phase (uvm_phase phase);
  super.build_phase(phase);
  if (!uvm_config_db#(virtual apb_if)::get(this, "*", "apb_vif", apb_vif))
    `uvm_error(get_type_name(), "did not get virtual bus handle")
endfunction

task apb_monitor::run_phase (uvm_phase phase);
  apb_seq_item trans;

  forever begin
    wait(`APBMON_IF.psel & `APBMON_IF.penable & apb_vif.presetn);
    trans = apb_seq_item::type_id::create("trans");
    trans.addr = `APBMON_IF.paddr;
    trans.data = `APBMON_IF.pwrite ? `APBMON_IF.pwdata : `APBMON_IF.prdata;
    trans.wren = `APBMON_IF.pwrite;
    if (`APBMON_IF.pwrite) begin
      trans.data = `APBMON_IF.pwdata;
      ap_mdl.write(trans);  // if write, send transaction to reference model
    end else begin
      trans.data = `APBMON_IF.prdata;
      // need to send to both scoreboard and reference model
      ap_scb.write(trans);  
      ap_mdl.write(trans); 
    end
  end
endtask