import uart_cfg_pkg::*

class apbuart_model extends uvm_component;

  `uvm_component_utils(apbuart_model)

  uvm_blocking_get_port #(apb_seq_item) bgp_apb;
  uvm_analysis_port #(apb_seq_item) ap_apb;

  uvm_blocking_get_port #(uart_seq_item) bgp_uart;
  uvm_analysis_port #(uart_seq_item) ap_uart;

  uvm_analysis_port #(irq_t) ap_irq;

  /**** variables representing apbuart state ****/
  logic [7:0] rx_queue[$]; // rx uart data queue
  logic [7:0] tx_queue[$]; // tx uart data queue
  
  // registers
  logic [31:0] apbuart_regs[*];

  function new (string name = "apbuart_model", uvm_component parent);
    super.new(name, parent);
    for (int i = 0; i < 40; i = i + 4) begin
      apbuart_regs[i] = 'hxxxx;
    end
    // registers initialization
    apbuart_regs[`UART_DIV]   = 'hf152;
    apbuart_regs[`UART_CFG]   = 'h34;
    apbuart_regs[`UART_RXTD]  = 'h1;
    apbuart_regs[`UART_TXTD]  = 'h0;
    apbuart_regs[`UART_IFS]   = 'h2;
    apbuart_regs[`UART_SR]    = 'h0;
  endfunction

  function void build_phase (uvm_phase phase);
    super.new(name, parent);
    bgp_apb   = new ("bgp_apb", this);
    ap_apb    = new ("ap_apb", this);
    bgp_uart  = new ("bgp_uart", this);
    ap_uart   = new ("ap_uart", this);
  endfunction

  task main_phase (uvm_phase phase);
    super.main_phase(phase);
    fork
      apb_handle;
      irq_handle;
      uart_handle;
    join 
  endtask

  task apb_handle ();
    apb_seq_item trans_i, trans_o;
    uart_seq_item uart_tr_o;

    forever begin
      bgp_apb.get(trans_i);
      if (trans_i.wren) begin   // apb write transaction
        case (trans_i.addr[7:0])
          `UART_TXD : begin
            if (tx_queue.size() < 16)
              tx_queue.push_back(trans_i.data);
          end
          `UART_RXD, `UART_RDL, `UART_TDL : ;   // read only
          default : apbuart_regs[trans_i.addr] = trans_i.data; 
        endcase
        if (apbuart_regs[`UART_CFG][14]) // tx fifo reset
          tx_queue.delete();     
        if (apbuart_regs[`UART_CFG][15])  // rx fifo reset
          rx_queue.delete();
        if (tx_queue.size() > 0) begin
          uart_tr_o = uart_seq_item::type_id::create("uart_tr_o");
          // packing tx data
          uart_tr_o.data = tx_queue.pop_front();
          uart_tr_o.has_parity = apbuart_regs[`UART_CFG][0];
          uart_tr_o.has_stop_bit = apbuart_regs[`UART_CFG][3];
          uart_tr_o.parity_type = apbuart_regs[`UART_CFG][1] ? ODD : EVEN;
          uart_tr_o.parity = uart_tr_o.calc_parity(uart_tr_o.parity_type);
          uart_tr_o.stop_bit = 'b1;
          uart_tr_o.frame_interval = apbuart_regs[`UART_TDL][5:0] > 1 ? apbuart_regs[`UART_IFS][3:0] : -1;  // -1 means don't care
          // transmit
          ap_uart.write(uart_tr_o);
        end
      end else begin    // apb read transaction
        trans_o = apb_seq_item::type_id::create("trans_o");
        trans_o.copy(trans_i); 
        trans_o.data = apbuart_regs[trans_o.addr];
        if (trans_o.addr == `UART_RXD)
          trans_o.data = rx_queue.pop_front();
        ap_apb.write(trans_o);
      end
    end  
  endtask

  task irq_handle ();
    irq_t trans;

    forever begin
      if (|apbuart_regs[`UART_SR][3:0]) begin
        @(negedge |apbuart_regs[`UART_SR][3:0]);
        trans = FELL;
        ap_irq.write(trans);
      end else begin
        @(posedge |apbuart_regs[`UART_SR][3:0]);
        trans = ROSE;
        ap_irq.write(trans);
      end
    end
  endtask

  task uart_handle ();
    uart_seq_item trans_i;

    forever begin
      bgp_uart.get(trans_i);
      // verify parity
      case (apbuart_regs[`UART_CFG][1:0])
        'b11 : begin    // verify odd parity
          if (trans_i.parity != trans.calc_parity(ODD))
            apbuart_regs[`UART_SR][2] = 'b1;
        end
        'b01 : begin    // verify even parity
          if (trans_i.parity != trans.calc_parity(EVEN))
            apbuart_regs[`UART_SR][2] = 'b1;
        end
        default : ;
      endcase
      // verify stop bit
      if (apbuart_regs[`UART_CFG][3]) begin
        if (!trans_i.stop_bit)
          apbuart_regs[`UART_SR][3] = 'b1;
      end
      // if pass verification, sent to rx queue
      if (apbuart_regs[`UART_SR][3:2] == 'b00 && rx_queue.size <= 16)
        rx_queue.push_back(trans_i.data);
    end
  endtask

endclass