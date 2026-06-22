///////////////////////////////////////////////////////////////
// primitives
//
// Definition of common and primitive logic elements.
///////////////////////////////////////////////////////////////

module adder(input  [31:0] a, b,
output [31:0] y);

assign y = a + b;
endmodule

module flopr #(parameter WIDTH = 8)
    (input  logic            clk, reset,
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q);

always_ff @(posedge clk, posedge reset)
if (reset) q <= '0;
else        q <= d;
endmodule

module flopren #(parameter WIDTH = 8)
    (input  logic            clk, reset,
    input  logic             en,
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q);

always_ff @(posedge clk, posedge reset)
if (reset) q <= '0;
else if (en) q <= d;
endmodule

module floprdual #(parameter WIDTH = 8)
    (input  logic             clk, reset,
    input  logic [WIDTH-1:0] d1, d2,
    output logic [WIDTH-1:0] q1, q2);

always_ff @(posedge clk, posedge reset)
if (reset) begin
    q1 <= '0;
    q2 <= '0;
end else begin
    q1 <= d1;
    q2 <= d2;
end
endmodule

module floprdualen #(parameter WIDTH = 8)
    (input  logic             clk, reset,
    input  logic             en,
    input  logic [WIDTH-1:0] d1, d2,
    output logic [WIDTH-1:0] q1, q2);

always_ff @(posedge clk, posedge reset)
if (reset) begin
    q1 <= '0;
    q2 <= '0;
end else if(en) begin
    q1 <= d1;
    q2 <= d2;
end
endmodule

module mux2 #(parameter WIDTH = 8)
(input  logic [WIDTH-1:0] d0, d1,
input  logic             s,
output logic [WIDTH-1:0] y);

assign y = s ? d1 : d0;
endmodule

module mux3 #(parameter WIDTH = 8)
(input  logic [WIDTH-1:0] d0, d1, d2,
input  logic [1:0]       s,
output logic [WIDTH-1:0] y);

assign y = s[1] ? d2 : (s[0] ? d1 : d0);
endmodule


