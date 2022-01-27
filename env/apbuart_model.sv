class apbuart_model extends uvm_component;

  `uvm_component_utils(apbuart_model)

  uvm_blocking_get_port #(apb_seq_item) bgp_apb;
  uvm_analysis_port #(apb_seq_item) ap_apb;

  uvm_blocking_get_port #(uart_seq_item) bgp_uart;
  uvm_analysis_port #(uart_seq_item) ap_uart;

  /**** variables representing apbuart state ****/
  logic [7:0] rx_queue[$]; // rx uart data queue
  logic [7:0] tx_queue[$]; // tx uart data queue
  
  // registers
  logic [31:0] apbuart_regs[*];

  // virtual interface
  virtual uart_if uart_vif;

  event bpsclk;
  int baud_cnt;

  function new (string name = "apbuart_model", uvm_component parent);
    super.new(name, parent);
    for (int i = 0; i < 40; i = i + 4) begin
      apbuart_regs[i] = 'hxxxx;
    end
    // registers initialization
    apbuart_regs[`UART_TXD]   = 'h0;
    apbuart_regs[`UART_DIV]   = 'hf152;
    apbuart_regs[`UART_CFG]   = 'h34;
    apbuart_regs[`UART_RXTD]  = 'h1;
    apbuart_regs[`UART_TXTD]  = 'h0;
    apbuart_regs[`UART_IFS]   = 'h2;
    apbuart_regs[`UART_SR]    = 'h0;
  endfunction

  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    bgp_apb   = new ("bgp_apb", this);
    ap_apb    = new ("ap_apb", this);
    bgp_uart  = new ("bgp_uart", this);
    ap_uart   = new ("ap_uart", this);
    if (!uvm_config_db#(virtual uart_if)::get(this, "", "uart_vif", uart_vif))
      `uvm_error(get_type_name(), "did not get virtual bus handle")
  endfunction

  task run_phase (uvm_phase phase);
    super.run_phase(phase);
    fork
      apb_handle;
      uart_tx_handle;
      uart_rx_handle;
      bpsclk_gen;
    join 
  endtask

  task apb_handle ();
    apb_seq_item trans_i, trans_o;
    baud_cnt = 16 * (apbuart_regs[`UART_DIV][9:0] + 1);

    forever begin
      bgp_apb.get(trans_i);
      if (trans_i.wren) begin   // apb write transaction
        case (trans_i.addr)
          `UART_TXD : begin
            apbuart_regs[`UART_TXD] = trans_i.data;
            if (tx_queue.size() < 16) begin
              tx_queue.push_back(trans_i.data);
            end
          end
          `UART_RXD, `UART_RDL, `UART_TDL : ;   // read only
          `UART_SR : begin    // clear status reg
            apbuart_regs[`UART_SR] = ~trans_i.data | apbuart_regs[`UART_SR];
          end
          default : apbuart_regs[trans_i.addr] = trans_i.data; 
        endcase
        if (apbuart_regs[`UART_CFG][14]) // tx fifo reset
          tx_queue.delete();     
        if (apbuart_regs[`UART_CFG][15])  // rx fifo reset
          rx_queue.delete();
        // baud count update
        baud_cnt = 16 * (apbuart_regs[`UART_DIV][9:0] + 1);
        // sr reg update
        if (tx_queue.size() <= apbuart_regs[`UART_TXTD][3:0])
          apbuart_regs[`UART_SR][0] = 'b1;
      end else begin    // apb read transaction
        trans_o = apb_seq_item::type_id::create("trans_o");
        trans_o.copy(trans_i); 
        trans_o.data = apbuart_regs[trans_o.addr];
        case (trans_o.addr)
          `UART_RXD : begin
            if (rx_queue.size > 0)
              trans_o.data = rx_queue.pop_front();
            else
              trans_o.data = 'h0;
          end
          `UART_SR :
            trans_o.data = {28'h0, apbuart_regs[`UART_SR][3:0]};
          `UART_RDL :
            trans_o.data = rx_queue.size(); 
          `UART_TDL : begin
            if (tx_queue.size == 0)
              trans_o.data = 'h0;
            else
              trans_o.data = tx_queue.size() - 1; 
          end
          `UART_TXD, `UART_DIV, `UART_CFG, `UART_RXTD, `UART_TXTD, `UART_IFS : ;
          default : trans_o.data = 'h0;   // illegal address return 0
        endcase
        ap_apb.write(trans_o);
      end
    end  
  endtask

/*
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
  */
  task uart_tx_handle ();
    uart_seq_item uart_tr_o;
    int transfer_bits;

    forever begin
      if (tx_queue.size() > 0) begin
        uart_tr_o = uart_seq_item::type_id::create("uart_tr_o");
        // packing tx data
        uart_tr_o.data = tx_queue.pop_front();
        uart_tr_o.has_parity = apbuart_regs[`UART_CFG][0];
        uart_tr_o.has_stop_bit = apbuart_regs[`UART_CFG][2];
        uart_tr_o.parity_type = apbuart_regs[`UART_CFG][1] ? ODD : EVEN;
        if (uart_tr_o.has_parity)
          uart_tr_o.parity = uart_tr_o.calc_parity(uart_tr_o.parity_type);
        else
          uart_tr_o.parity = 'b0;   // don't care
        uart_tr_o.stop_bit = 'b1;
        uart_tr_o.frame_interval = apbuart_regs[`UART_TDL][5:0] > 1 ? apbuart_regs[`UART_IFS][3:0] : -1;  // -1 means don't care
        // sr reg update
        if (tx_queue.size() <= apbuart_regs[`UART_TXTD][3:0]) begin
          apbuart_regs[`UART_SR][0] = 'b1;
        end
        // transmit
        transfer_bits = (8 + uart_tr_o.has_stop_bit + uart_tr_o.has_parity);
        if (uart_tr_o.frame_interval != -1)
          transfer_bits += uart_tr_o.frame_interval;
        repeat(transfer_bits) @bpsclk;
        ap_uart.write(uart_tr_o);
      end else begin
        @bpsclk;    
      end
    end
  endtask

  task uart_rx_handle ();
    uart_seq_item trans_i;

    forever begin
      bgp_uart.get(trans_i);
      // verify parity
      case (apbuart_regs[`UART_CFG][1:0])
        'b11 : begin    // verify odd parity
          if (trans_i.parity != trans_i.calc_parity(ODD))
            apbuart_regs[`UART_SR][2] = 'b1;
        end
        'b01 : begin    // verify even parity
          if (trans_i.parity != trans_i.calc_parity(EVEN))
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

  task bpsclk_gen ();
    int cnt = 0;
    wait(uart_vif.rstn);
    forever begin
      @(posedge uart_vif.clk);
      if (cnt == baud_cnt) begin
        cnt = 0;
        -> bpsclk;
      end else begin
        ++cnt;
      end
    end
  endtask

endclass