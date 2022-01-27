module apbuart_prop (
  input clk,
  input rst_,
  input psel_i,
  input penable_i,
  input pwrite_i
);

  property en_after_sel_rose;
    @(posedge clk) disable iff(!rst_) ($rose(psel_i) |=> $rose(penable_i));
  endproperty

  property en_sel_fell;
    @(posedge clk) disable iff(!rst_) ($fell(psel_i) |-> $fell(penable_i));
  endproperty

  property no_burst;
    @(posedge clk) disable iff(!rst_) ($rose(penable_i) |=> $fell(penable_i));
  endproperty

  property pwrite_stable;
    @(posedge clk) disable iff(!rst_) ($rose(penable_i) |-> $stable(pwrite_i));
  endproperty

  en_after_sel_roseP: assert property (en_after_sel_rose) else $error($stime, "\t\t FAIL: en_after_sel_rose condition");

  en_sel_fellP: assert property (en_sel_fell) else $error($stime, "\t\t FAIL: en_sel_fell condition");

  no_burstP: assert property (no_burst) else $error($stime, "\t\t FAIL: no_burst condition");

  pwrite_stableP: assert property (pwrite_stable) else $error($stime, "\t\t FAIL: pwrite_stable condition");

endmodule