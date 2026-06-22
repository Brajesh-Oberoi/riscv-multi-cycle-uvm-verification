#!/bin/bash

iverilog -g2012 -o riscv_tb.vvp riscv_tb.sv
vvp -n riscv_tb.vvp