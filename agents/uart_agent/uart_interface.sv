interface uart_if (input clk, rstn);

  logic     urxd;
  logic     utxd;

  // clocking blocks
  clocking driver_cb @ (posedge clk);
    default input #1 output #1;
    input  utxd;
    output urxd;
  endclocking

  clocking monitor_cb @ (posedge clk);
    default input #1 output #1;
    input urxd;
    input utxd;
  endclocking

  // modports
  modport DRIVER  (clocking driver_cb, input clk, input rstn);
  modport MONITOR (clocking monitor_cb, input clk, input rstn);

endinterface