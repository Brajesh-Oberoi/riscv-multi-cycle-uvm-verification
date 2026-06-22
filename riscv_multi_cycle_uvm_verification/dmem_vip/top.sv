module top;

`include "uvm_macros.svh"
import uvm_pkg::*;
import dmem_vip_pkg::*;

logic clk;
logic MemWrite;
logic [31:0]DataAdr;
logic [31:0]WriteData;
logic [31:0]ReadData;

logic [31:0]temp_addr_arr[$];
logic [31:0]temp_data_arr[$];
dmem_if dmem_vif();

assign dmem_vif.driver_modport.clk         =  clk;
assign dmem_vif.driver_modport.MemWrite    =  MemWrite;
assign dmem_vif.driver_modport.DataAdr     =  DataAdr;
assign dmem_vif.driver_modport.WriteData   =  WriteData;
assign ReadData                            = dmem_vif.driver_modport.ReadData;


always #5 clk = ~clk;

initial
  begin
    clk=1'b0;
    uvm_config_db#(virtual dmem_if)::set(null, "*", "dmem_vif", dmem_vif);
  end


initial
  begin

    //Write the memory array
    for(int i=0; i<128; i++)
      begin
        MemWrite   = 1'b1;
        DataAdr    = i;//$urandom_range(0,127);
        WriteData  = $urandom_range(0,2**32 -1);
        temp_addr_arr.push_back(DataAdr);
        temp_data_arr.push_back(DataAdr);
        #10us;
      end

    //Read the memory array
    for(int i=0; i<200; i++)
      begin
        MemWrite   = 1'b0;
        DataAdr    = temp_addr_arr.pop_front();
        #10us;
      end
  end



initial
  begin
    run_test("");
  end



endmodule
