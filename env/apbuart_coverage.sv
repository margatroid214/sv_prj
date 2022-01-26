class apb_cov extends uvm_subscriber #(apb_seq_item);
  `uvm_component_utils(apb_cov)

  covergroup wr_cov with function sample(logic [31:0] addr, logic [31:0] data, logic wren);
    option.name = "apb_write_coverage";

    // reg addr
    reg_addr: coverpoint addr iff (wren) {
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
      options.weight = 0;
    }

    baud_rate: coverpoint data iff (wren) {
      // baud rate : 9600, 19200, 38400, 115200
      bins div = {'d169, 'd85, 'd42, 'd14};
    }

    parity: coverpoint data[1:0] iff (wren) {
      wildcard bins parity_off = {'b0?};
      wildcard bins parity_on_odd = {'b11};
      wildcard bins parity_on_even = {'b10};
    }

    // baud rate coverage
    BAUD_RATE: coverpoint data iff (wren) {
      // 9600, 19200,38400, 115200
      bins div = {'d169, 'd85, 'd42, 'd14};
    }
    DIV_ADDR: coverpoint addr iff (wren) {
      bins div_addr = {`UART_DIV};
    }
  endgroup
endclass