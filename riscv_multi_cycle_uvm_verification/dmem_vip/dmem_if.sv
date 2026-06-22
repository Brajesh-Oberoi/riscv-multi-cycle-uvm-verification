interface dmem_if;

logic clk;
logic MemWrite;
logic [31:0]DataAdr;
logic [31:0]WriteData;
logic [31:0]ReadData;

logic [31:0] mem[127:0];


modport driver_modport(input clk, input MemWrite, input DataAdr, input WriteData, output ReadData);

assign ReadData = mem[DataAdr];

  task mem_access();
    @(posedge clk);
    if (MemWrite == 1'b1)
      mem[DataAdr] = WriteData;
    //else
      //ReadData = mem[DataAdr];
  endtask

  task load_mem(string filename);
     $readmemh(filename, mem);
  endtask

endinterface
