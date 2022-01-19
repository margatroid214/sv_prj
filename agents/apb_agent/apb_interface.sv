interface apb_if (input pclk, presetn)

  logic [31:0]  paddr;
  logic [31:0]  pwdata;
  logic [31:0]  prdata;
  logic         psel;
  logic         penable;
  logic         pwrite;

  logic         uart_int;

  // clocking blocks
  clocking driver_cb @ (posedge pclk);
    default input #1 output #1;
    output  paddr;
    output  pwdata;
    output  psel;
    output  penable;
    output  pwrite;
    input   prdata;
    input   uart_int;
  endclocking

  clocking monitor_cb @ (posedge pclk);
    default input #1 output #1;
    input   paddr;
    input   pwdata;
    input   psel;
    input   penable;
    input   pwrite;
    input   prdata;
    input   uart_int;
  endclocking

  // modports
  modport DRIVER  (clocking driver_cb, input pclk, presetn);
  modport MONITOR (clocking monitor_cb, input pclk, presetn);

endinterface