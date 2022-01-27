class apb_cov extends uvm_subscriber #(apb_seq_item);
  `uvm_component_utils(apb_cov)

  logic [31:0] addr;
  logic [31:0] data;
  logic wren;

  covergroup wr_cov;
    option.name = "apb_write_coverage";

    // reg addr
    reg_addr: coverpoint addr {
      bins txd  = {`UART_TXD};
      bins rxd  = {`UART_RXD};
      bins div  = {`UART_DIV};
      bins cfg  = {`UART_CFG};
      bins rxtd = {`UART_RXTD};
      bins txtd = {`UART_TXTD};
      bins ifs  = {`UART_IFS};
      bins sr   = {`UART_SR};
      bins rdl  = {`UART_RDL};
      bins tdl  = {`UART_TDL};
    }

    baud_rate: coverpoint data {
      // baud rate : 9600, 19200, 38400, 115200
      bins baud_9600 = {'d168};
      bins baud_19200 = {'d84};
      bins baud_38400 = {'d41};
      bins baud_115200 = {'d13};
    }

    cfg_bits: coverpoint data[3:0];

    tx_trigg_depth: coverpoint data[3:0] {
      bins d5 = {'d5};
      bins d6 = {'d6};
      bins d7 = {'d7};
      bins d8 = {'d8};
      bins under_5 = {[0:'d4]};
    }

    ifs: coverpoint data[3:0] {
      bins i0 = {0};
      bins i1 = {'d1};
      bins i2 = {'d2};
      bins over_2 = {['d3:'d15]};
    }

    tx_irq: coverpoint data[0];
    
    baud_addr: coverpoint addr { bins addr = {`UART_DIV}; }
    cfg_addr: coverpoint addr { bins addr = {`UART_CFG}; }
    txtd_addr: coverpoint addr { bins addr = {`UART_TXTD}; }
    ifs_addr: coverpoint addr { bins addr = {`UART_IFS}; }
    sr_addr: coverpoint addr { bins addr = {`UART_SR}; }

    baud_cov : cross baud_addr, baud_rate;
    cfg_cov : cross cfg_addr, cfg_bits;
    txtd_cov : cross txtd_addr, tx_trigg_depth;
    ifs_cov : cross ifs_addr, ifs;
    tx_irq_cov : cross sr_addr, tx_irq;
  endgroup

  covergroup bus;
    option.name = "apb_bus_coverage";

    apb_wr_rd: coverpoint wren {
      bins write = {1};
      bins read = {0};
    }
  endgroup

  function new (string name, uvm_component parent);
    super.new(name, parent);
    wr_cov = new();
    bus = new();
  endfunction

  function void write(apb_seq_item t);
    data = t.data;
    addr = t.addr;
    wren = t.wren;
    if (wren)
      wr_cov.sample();
    bus.sample();
  endfunction
endclass