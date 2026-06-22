///////////////////////////////////////////////////////////////
// testbench top module
//
// Expect simulator to print "Simulation succeeded"
// when the value 25 (0x19) is written to address 100 (0x64)
///////////////////////////////////////////////////////////////
`include "riscvmulti.sv"

module top;

    `include "uvm_macros.svh"
    import uvm_pkg::*;
    import dmem_vip_pkg::*;


    logic        clk;
    logic        reset;

    logic [31:0] WriteData, DataAdr;
    logic        MemWrite;
    logic [31:0] hash;

    // instantiate device to be tested
    //top dut(clk, reset, WriteData, DataAdr, MemWrite);
    // instantiate processor and memories
    riscvmulti rvmulti(clk, reset, MemWrite, DataAdr, WriteData, ReadData);
    dmem_if dmem_vif ();
    assign dmem_vif.clk = clk;
    assign dmem_vif.MemWrite = MemWrite;
    assign dmem_vif.WriteData = WriteData;
    assign dmem_vif.DataAdr   = DataAdr;
    assign ReadData           = dmem_vif.ReadData;

    //mem mem(clk, MemWrite, DataAdr, WriteData, ReadData);

    // initialize test
    initial
      begin
        uvm_config_db#(virtual dmem_if)::set(null, "*", "dmem_vif", dmem_vif);
        reset <= 1; # 22; reset <= 0;
      end

    // generate clock to sequence tests
    always
      begin
        // the cycle time is 10, the provided cycle time was 5 which gave the wrong hash value.
        // The correct hash value is ffe0b9e2.
        clk <= 1; # 10; clk <= 0; # 10;
      end



    initial

      begin
        dmem_vif.load_mem("riscvtest.txt");
        run_test();
      end


  endmodule
