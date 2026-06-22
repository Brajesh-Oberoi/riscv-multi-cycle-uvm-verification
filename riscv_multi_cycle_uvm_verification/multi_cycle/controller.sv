///////////////////////////////////////////////////////////////
// controller
//
// Definition of the multicycle RISC-V processor controller
///////////////////////////////////////////////////////////////

module controller(input logic clk, reset,
    input  logic [6:0] op,
    input  logic [2:0] funct3,
    input  logic       funct7b5,
    input  logic       Zero,
    output logic [1:0] ResultSrc,
    output logic       MemWrite,
    output logic       PCWrite,
    output logic       IRWrite,
    output logic       AdrSrc,
    output logic       RegWrite,
    output logic [1:0] ALUSrcA, ALUSrcB,
    output logic [1:0] ImmSrc,
    output logic [2:0] ALUControl);
  
  logic [1:0] ALUOp;
  logic       Branch;
  logic       PCUpdate;
  
  maindec md(clk, reset, op, ResultSrc, MemWrite, AdrSrc, Branch,
  PCUpdate, ALUSrcA, ALUSrcB, RegWrite, IRWrite, ALUOp);
  aludec  ad(op[5], funct3, funct7b5, ALUOp, ALUControl);
  instdec id(op, ImmSrc);
  
  assign PCWrite = PCUpdate | (Zero & Branch);
  endmodule
  
  module maindec(input logic clk, reset,
    input  logic [6:0] op,
    output logic [1:0] ResultSrc,
    output logic       MemWrite,
    output logic       AdrSrc,
    output logic       Branch,
    output logic       PCUpdate,
    output logic [1:0] ALUSrcA, ALUSrcB,
    output logic       RegWrite,
    output logic       IRWrite,
    output logic [1:0] ALUOp);
  
  
    // State encoding
    typedef enum logic [3:0] {
      FETCH     = 4'b0000,
      DECODE    = 4'b0001,
      MEMADR    = 4'b0010,
      MEMREAD   = 4'b0011,
      MEMWB     = 4'b0100,
      MEMWRITE  = 4'b0101,
      EXECUTER  = 4'b0110,
      ALUWB     = 4'b0111,
      EXECUTEI  = 4'b1000,
      JAL       = 4'b1001,
      BEQ       = 4'b1010 
  } state_t;
  
  state_t current_state, next_state;
  
  // State transition logic
  always_ff @(posedge clk) begin
      if (reset) begin
          current_state <= FETCH;
      end else begin
          current_state <= next_state;
      end
  end
  
  // Next state logic
  always_comb begin
    case (current_state)
      FETCH: next_state = DECODE;
      DECODE: begin
        case (op)
          7'b0000011, // lw
          7'b0100011: // sw
          begin
          next_state = MEMADR;
          end
          7'b0110011: // R-type
          next_state = EXECUTER;
          7'b0010011: // I-type ALU
          next_state = EXECUTEI;
          7'b1101111: // jal
          next_state = JAL;
          7'b1100011: // BEQ
          next_state = BEQ;
          default:
          next_state = FETCH;
        endcase
      end
      MEMADR: begin
        case (op)
          7'b0000011: next_state = MEMREAD; // lw
          7'b0100011: next_state = MEMWRITE; // sw
        endcase
      end
      MEMREAD: begin
        next_state = MEMWB;
      end
      MEMWB,
      MEMWRITE,
      ALUWB,
      BEQ: begin
      next_state = FETCH;
      end
      EXECUTER,
      EXECUTEI,
      JAL: begin
      next_state = ALUWB;
      end
    endcase
  end
  
  // data path control signals logic
  always_comb begin
    case (current_state)
      FETCH: begin
        AdrSrc = 1'b0;
        IRWrite = 1'b1;
        ALUSrcA = 2'b00;
        ALUSrcB = 2'b10;
        ALUOp = 2'b00;
        ResultSrc = 2'b10;
        PCUpdate = 1'b1;
        // control signals that must be zero if not used
        RegWrite = 1'b0;
        MemWrite = 1'b0;
        Branch = 1'b0;
      end
      
      DECODE: begin
        ALUSrcA = 2'b01;
        ALUSrcB = 2'b01;
        ALUOp = 2'b00;
        // control signals that must be zero if not used
        RegWrite = 1'b0;
        MemWrite = 1'b0;
        IRWrite = 1'b0;
        PCUpdate = 1'b0;
        Branch = 1'b0;
        // control signals that must be don't-care if not used
        ResultSrc = 2'bxx;
        AdrSrc = 1'bx;
      end
  
      MEMADR: begin
        ALUSrcA = 2'b10;
        ALUSrcB = 2'b01;
        ALUOp = 2'b00;
        // control signals that must be zero if not used
        RegWrite = 1'b0;
        MemWrite = 1'b0;
        IRWrite = 1'b0;
        PCUpdate = 1'b0;
        Branch = 1'b0;
        // control signals that must be don't-care if not used
        ResultSrc = 2'bxx;
        AdrSrc = 1'bx;
      end
  
      MEMREAD: begin
        ResultSrc = 2'b00;
        AdrSrc = 1'b1;
        // control signals that must be zero if not used
        RegWrite = 1'b0;
        MemWrite = 1'b0;
        IRWrite = 1'b0;
        PCUpdate = 1'b0;
        Branch = 1'b0;
        // control signals that must be don't-care if not used
        ALUSrcA = 2'bxx;
        ALUSrcB = 2'bxx;
        ALUOp = 2'bxx;
      end
  
      MEMWB: begin
        ResultSrc = 2'b01;
        RegWrite = 1'b1;
        // control signals that must be zero if not used
        MemWrite = 1'b0;
        IRWrite = 1'b0;
        PCUpdate = 1'b0;
        Branch = 1'b0;
        // control signals that must be don't-care if not used
        ALUSrcA = 2'bxx;
        ALUSrcB = 2'bxx;
        AdrSrc = 1'bx;
        ALUOp = 2'bxx;
      end
  
      MEMWRITE: begin
        ResultSrc = 2'b00;
        AdrSrc = 1'b1;
        MemWrite = 1'b1;
        // control signals that must be zero if not used
        RegWrite = 1'b0;
        IRWrite = 1'b0;
        PCUpdate = 1'b0;
        Branch = 1'b0;
        // control signals that must be don't-care if not used
        ALUSrcA = 2'bxx;
        ALUSrcB = 2'bxx;
        ALUOp = 2'bxx;
      end
  
      EXECUTER: begin
        ALUSrcA = 2'b10;
        ALUSrcB = 2'b00;
        ALUOp = 2'b10;
        // control signals that must be zero if not used
        RegWrite = 1'b0;
        MemWrite = 1'b0;
        IRWrite = 1'b0;
        PCUpdate = 1'b0;
        Branch = 1'b0;
        // control signals that must be don't-care if not used
        ResultSrc = 2'bxx;
        AdrSrc = 1'bx;
      end
  
      EXECUTEI: begin
        ALUSrcA = 2'b10;
        ALUSrcB = 2'b01;
        ALUOp = 2'b10;
        // control signals that must be zero if not used
        RegWrite = 1'b0;
        MemWrite = 1'b0;
        IRWrite = 1'b0;
        PCUpdate = 1'b0;
        Branch = 1'b0;
        // control signals that must be don't-care if not used
        ResultSrc = 2'bxx;
        AdrSrc = 1'bx;
      end
  
      JAL: begin
        ALUSrcA = 2'b01;
        ALUSrcB = 2'b10;
        ALUOp = 2'b00;
        ResultSrc = 2'b00;
        PCUpdate = 1'b1;
        // control signals that must be zero if not used
        RegWrite = 1'b0;
        MemWrite = 1'b0;
        IRWrite = 1'b0;
        Branch = 1'b0;
        // control signals that must be don't-care if not used
        AdrSrc = 1'bx;
      end
      BEQ: begin
        ALUSrcA = 2'b10;
        ALUSrcB = 2'b00;
        ALUOp = 2'b01;
        ResultSrc = 2'b00;
        Branch = 1'b1;
        // control signals that must be zero if not used
        RegWrite = 1'b0;
        MemWrite = 1'b0;
        IRWrite = 1'b0;
        PCUpdate = 1'b0;
        // control signals that must be don't-care if not used
        AdrSrc = 1'bx;
      end
      ALUWB: begin
        ResultSrc = 2'b00;
        RegWrite = 1'b1;
        // control signals that must be zero if not used
        MemWrite = 1'b0;
        IRWrite = 1'b0;
        PCUpdate = 1'b0;
        Branch = 1'b0;
        // control signals that must be don't-care if not used
        AdrSrc = 1'bx;
        ALUSrcA = 2'bxx;
        ALUSrcB = 2'bxx;
        ALUOp = 2'bxx;
      end
    endcase
  end
  
  endmodule
  
  module aludec(input  logic       opb5,
    input  logic [2:0] funct3,
    input  logic       funct7b5, 
    input  logic [1:0] ALUOp,
    output logic [2:0] ALUControl);
  
  logic  RtypeSub;
  assign RtypeSub = funct7b5 & opb5;  // TRUE for R-type subtract instruction
  
  always_comb
  case(ALUOp)
  2'b00:                ALUControl = 3'b000; // addition
  2'b01:                ALUControl = 3'b001; // subtraction
  default: case(funct3) // R-type or I-type ALU
       3'b000:  if (RtypeSub) 
                  ALUControl = 3'b001; // sub
                else          
                  ALUControl = 3'b000; // add, addi
       3'b010:    ALUControl = 3'b101; // slt, slti
       3'b110:    ALUControl = 3'b011; // or, ori
       3'b111:    ALUControl = 3'b010; // and, andi
       3'b001:    ALUControl = 3'b100; // sll
       default:   ALUControl = 3'bxxx; // ???
     endcase
  endcase
  endmodule
  
  module instdec(input logic [6:0] op, 
    output logic [1:0] ImmSrc);
  
    always_comb begin
      case (op)
      'b0000011:  ImmSrc = 'b00; // lw
      'b0100011:  ImmSrc = 'b01; // sw
      'b0110011:  ImmSrc = 'b00; // R-type
      'b1100011:  ImmSrc = 'b10; // beq
      'b0010011:  ImmSrc = 'b00; // ExecuteI
      'b1101111:  ImmSrc = 'b11; // jal
      default:    ImmSrc = 'b00; 
      endcase
    end
  endmodule