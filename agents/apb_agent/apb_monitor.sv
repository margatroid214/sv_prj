`define APBMON_IF apb_vif.MONITOR.monitor_cb

class apb_monitor extends uvm_monitor;

  `uvm_component_utils(apb_monitor);

  virtual apb_if apb_vif;

  uvm_analysis_port #(apb_seq_item) ap_scb; // tlm port for sending apb transactions out to scoreboard
  uvm_analysis_port #(apb_seq_item) ap_mdl; // tlm port for sending transactions out to reference model

  extern function new (string name = "apb_monitor", uvm_component parent);
  extern function void build_phase (uvm_phase phase);
  extern task run_phase (uvm_phase phase);
  extern task apb_wr_rd_mon;
  //extern task irq_mon;

endclass

function apb_monitor::new (string name = "apb_monitor", uvm_component parent);
  super.new(name, parent);
  ap_scb = new("ap_scb", this);
  ap_mdl = new("ap_mdl", this);
endfunction

function void apb_monitor::build_phase (uvm_phase phase);
  super.build_phase(phase);
  if (!uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", apb_vif))
    `uvm_error(get_type_name(), "did not get virtual bus handle")
endfunction

task apb_monitor::run_phase (uvm_phase phase);
  fork
    apb_wr_rd_mon;
    //irq_mon;
  join
endtask

task apb_monitor::apb_wr_rd_mon;
  apb_seq_item trans, trans_copy;

  forever begin
    @ (posedge apb_vif.pclk); 
    if (apb_vif.psel & apb_vif.penable & apb_vif.presetn) begin
      trans = apb_seq_item::type_id::create("trans");
      trans.addr = apb_vif.paddr;
      trans.data = apb_vif.pwrite ? apb_vif.pwdata : apb_vif.prdata;
      trans.wren = apb_vif.pwrite;
      if (apb_vif.pwrite) begin
        trans.data = apb_vif.pwdata;
        ap_mdl.write(trans);  // if write, send transaction to reference model
      end else begin
        trans.data = apb_vif.prdata;
        // need to send to both scoreboard and reference model
        trans_copy = apb_seq_item::type_id::create("trans_copy");
        trans_copy.copy(trans);
        ap_scb.write(trans_copy);  
        ap_mdl.write(trans);
      end
    end
  end
endtask