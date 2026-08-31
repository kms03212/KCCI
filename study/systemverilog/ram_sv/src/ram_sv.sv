`timescale 1ns / 1ps

module ram(
  input  logic       clk,
  input  logic       we,
  input  logic [7:0] addr,
  input  logic [7:0] wdata,
  output logic [7:0] rdata
);

  logic [7:0] ram_file[0:255];

  always_ff @(posedge clk)begin
    if(we)
      ram_file[addr]<=wdata;
  end

  // CL output
  assign rdata = ram_file[addr];

endmodule
