///////////////////////////////////////////////////////////////
// top
//
// Instantiates multicycle RISC-V processor and memory
///////////////////////////////////////////////////////////////

`include "primitives.sv"
`include "controller.sv"
`include "datapath.sv"

module top(input  logic        clk, reset, 
  output logic [31:0] WriteData, DataAdr, 
  output logic        MemWrite);

logic [31:0] ReadData;

// instantiate processor and memories
riscvmulti rvmulti(clk, reset, MemWrite, DataAdr, 
            WriteData, ReadData);
mem mem(clk, MemWrite, DataAdr, WriteData, ReadData);
endmodule

///////////////////////////////////////////////////////////////
// mem
//
// Single-ported RAM with read and write ports
// Initialized with machine language program
///////////////////////////////////////////////////////////////

module mem(input  logic        clk, we,
  input  logic [31:0] a, wd,
  output logic [31:0] rd);

logic [31:0] RAM[63:0];

initial begin
$readmemh("riscvtest.txt",RAM);
end

assign rd = RAM[a[31:2]]; // word aligned

always_ff @(posedge clk)
if (we) RAM[a[31:2]] <= wd;
endmodule

///////////////////////////////////////////////////////////////
// riscvmulti
//
// Multicycle RISC-V microprocessor definition
///////////////////////////////////////////////////////////////

module riscvmulti(input  logic        clk, reset,
                  output logic        MemWrite,
                  output logic [31:0] Adr, WriteData,
                  input  logic [31:0] ReadData);

  logic PCWrite, AdrSrc, RegWrite, Zero, IRWrite;
  logic [1:0] ALUSrcA, ALUSrcB, ImmSrc, ResultSrc;
  logic [2:0] ALUControl;
  logic [31:0] Instr;

  controller c(clk, reset, Instr[6:0], Instr[14:12], Instr[30], Zero,
  ResultSrc, MemWrite, PCWrite, IRWrite, AdrSrc, RegWrite, ALUSrcA,
  ALUSrcB, ImmSrc, ALUControl);

  datapath dp(clk, reset, PCWrite, AdrSrc, IRWrite, ResultSrc,
  ALUControl, ALUSrcA, ALUSrcB, ImmSrc, RegWrite, ReadData, Zero, Instr,
  Adr, WriteData);

endmodule
