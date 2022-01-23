`define UARTDRIV_IF uart_vif.DRIVER.driver_cb

class uart_driver extends uvm_driver #(uart_seq_item);

  `uvm_component_utils(uart_driver)

  // virtual uart interface
  virtual uart_if uart_vif;

  apbuart_cfg cfg;

  // methods
  extern function new (string name = "uart_driver", uvm_component parent);
  extern function void build_phase (uvm_phase phase);
  extern task run_phase (uvm_phase phase);
  extern task reset ();   // uart reset
  extern task drive (apb_seq_item trans);   // drive the uart rxd

endclass

function uart_driver::new (string name = "uart_driver", uvm_component parent);
  super.new(name, parent);
endfunction

function void uart_driver::build_phase (uvm_phase phase);
  super.build_phase(phase);
  if (!uvm_config_db#(virtual uart_if)::get(this, "*", "uart_vif", uart_vif))
    `uvm_error(get_type_name(), "did not get virtual bus handle")
  if (!uvm_config_db#(apbuart_cfg)::get(this, "*", "cfg", cfg))
    `uvm_error(get_type_name(), "did not get global config handle")
endfunction
 
task uart_driver::run_phase (uvm_phase phase);
  uart_seq_item trans;
  while (1) begin
    reset();
    fork
      @ (negedge uart_vif.rstn);
      forever begin
        seq_item_port.get_next_item(trans); // get next transaction to drive
        drive(trans);
        set_item_port.item_done();
      end
    join_any
  end
endtask

task uart_driver::reset ();
  wait(!uart_vif.rstn);   // wait for reset active
  // pull up uart rxd signal
  `uvm_info(get_type_name(), $sformatf("uart rxd pulled up"), UVM_MEDIUM);
  `UARTDRIV_IF.urxd <= 'h1;
  @ (posedge uart_vif.rstn);
end

task uart_driver::drive (uart_seq_item trans);
  int bit_cycles;
  bit_cycles = 26000000 / cfg.baud_rate;

  // start bit
  `UARTDRIV_IF.urxd <= 'h0;
  repeat(bit_cycles) @`UARTDRIV_IF;
  // transfer 1 byte data
  for (int i = 0; i < 8; i++) begin
    `UARTDRIV_IF.urxd <= trans.data[i];
    repeat(bit_cycles) @`UARTDRIV_IF;
  end
  // send parity bit
  if (trans.has_parity) begin
    `UARTDRIV_IF.urxd <= trans.parity;
    repeat(bit_cycles) @`UARTDRIV_IF;
  end
  // send stop bits
  `UARTDRIV_IF.urxd <= 'h1;
  repeat(trans.stop_bits) begin
    repeat(bit_cycles * 1 / 2) @`UARTDRIV_IF;
  end
  // send inter-frame
  `UARTDRIV_IF.urxd <= 'h1;
  repeat(trans.frame_interval) begin
    repeat(bit_cycles * 1 / 2) @`UARTDRIV_IF;
  end
endtask