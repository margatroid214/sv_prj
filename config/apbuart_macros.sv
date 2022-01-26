`ifndef __APBUART_MACROS__
`define __APBUART_MACROS__

// macros if didnt use register model
`define UART_TXD 32'h0000
`define UART_RXD 32'h0004
`define UART_DIV 32'h0008
`define UART_CFG 32'h000c
`define UART_RXTD 32'h0010
`define UART_TXTD 32'h0014
`define UART_IFS 32'h0018
`define UART_SR 32'h001c
`define UART_RDL 32'h0020
`define UART_TDL 32'h0024

`endif