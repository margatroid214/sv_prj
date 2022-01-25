##### questasim flow #####
TESTCASE_NAME=apbuart_wr_rd_test
UVM_HOME=C:/questasim64_10.6c/verilog_src/uvm-1.2/src
UVM_DPI=C:/questasim64_10.6c/verilog_src/uvm-1.2/win64/uvm_dpi

qsim:
	vlib.exe work
	vlog.exe +incdir+$(UVM_HOME) ../config/uart_cfg_pkg.sv
	vlog.exe +incdir+$(UVM_HOME) ../agents/apb_agent/apb_interface.sv
	vlog.exe +incdir+$(UVM_HOME)+../agents/apb_agent ../agents/apb_agent/apb_agent_pkg.sv
	vlog.exe +incdir+$(UVM_HOME) ../agents/uart_agent/uart_interface.sv
	vlog.exe +incdir+$(UVM_HOME)+../agents/uart_agent ../agents/uart_agent/uart_agent_pkg.sv
	vlog.exe +incdir+$(UVM_HOME)+../tb ../tb/top_tb.sv
	vsim.exe -c sv_lib $(UVM_DPI) top_tb -novopt +UVM_TESTNAME=TESTCASE_NAME

qclean:
	rm -rf ./work transcript *.wlf
