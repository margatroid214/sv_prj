set TESTCASE_NAME "apbuart_wr_rd_test"
#set TESTCASE_NAME "apbuart_stable_test"
#set TESTCASE_NAME "apbuart_tx_basic_test"
#set TESTCASE_NAME "apbuart_random_test"
#set TESTCASE_NAME "apbuart_irq_test"

set UVM_HOME "C:/questasim64_10.6c/verilog_src/uvm-1.2/src"
set UVM_DPI "C:/questasim64_10.6c/uvm-1.2/win64/uvm_dpi"

set SOURCES "../dut"

set source_files [glob -directory $SOURCES "*.*v*"]
foreach design [concat $source_files] {
	vlog $design
}

vlog +incdir+$UVM_HOME ../tb/top_tb.sv
vsim -assertdebug -c -sv_lib $UVM_DPI work.top_tb -novopt +UVM_TESTNAME=$TESTCASE_NAME

run 4000 us