`define APBDRIV_IF apb_vif.DRIVER.driver_cb

class apb_driver extends uvm_driver #(apb_seq_item);

  `uvm_component_utils(apb_driver)

  // virtual apb interface
  virtual apb_if apb_vif;

  // methods
  extern function new (string name = "apb_driver", uvm_component parent);
  extern function void build_phase (uvm_phase phase);
  extern task run_phase (uvm_phase phase);
  extern task reset ();   // apb bus reset
  extern task drive (apb_seq_item trans);   // drive the bus

endclass

function apb_driver::new (string name = "apb_driver", uvm_component parent);
  super.new(name, parent);
endfunction

function void apb_driver::build_phase (uvm_phase phase);
  super.build_phase(phase);
  if (!uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", apb_vif))
    `uvm_error(get_type_name(), "did not get virtual bus handle")
endfunction

task apb_driver::run_phase (uvm_phase phase);
  apb_seq_item trans;
  while (1) begin
    reset();
    fork
      @ (negedge apb_vif.presetn);  // apb reset
      forever begin
        seq_item_port.try_next_item(trans);   // try get transaction
        if (trans == null) begin
          @ (posedge apb_vif.pclk);
          apb_vif.psel <= 'h0;
          apb_vif.penable <= 'h0;
        end else begin
          drive(trans);
          seq_item_port.item_done();
        end
      end
    join_any
    disable fork;
  end
endtask

task apb_driver::reset ();
  wait(!apb_vif.presetn);   // wait for reset active
  // reset APB signals
  `uvm_info(get_type_name(), $sformatf("apb bus reset"), UVM_MEDIUM);
  apb_vif.paddr   <= 'h0;
  apb_vif.pwdata  <= 'h0;
  apb_vif.pwrite  <= 'h0;
  apb_vif.psel    <= 'h0;
  apb_vif.penable <= 'h0;
  @ (posedge apb_vif.presetn);
endtask

task apb_driver::drive (apb_seq_item trans);
  repeat(trans.interval) begin    // wait for several cycles as trans interval
    @(posedge apb_vif.pclk);
    apb_vif.psel    <= 'h0;
    apb_vif.penable <= 'h0;
  end
  @(posedge apb_vif.pclk);
  apb_vif.penable <= 'h0;
  apb_vif.psel    <= 'h1;
  apb_vif.paddr   <= trans.addr;
  apb_vif.pwdata  <= trans.data;
  apb_vif.pwrite  <= trans.wren;
  @(posedge apb_vif.pclk);
  apb_vif.penable <= 'h1;
endtask