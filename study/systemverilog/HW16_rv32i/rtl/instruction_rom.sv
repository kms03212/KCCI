
module instruction_rom (
    input  logic [31:0] instr_addr,
    output logic [31:0] instr_code
);

    logic [31:0] instr_rom[0:127];

    `ifdef SIMULATION_TEST
    initial begin
        instr_rom[0] = 32'h0041_82b3;  // ADD x5, x3, x4
        instr_rom[1] = 32'h0053_2323;  // SW  x6, 6(x6)
        instr_rom[2] = 32'h0023_8413;  // ADDI x8, x7, 2
        instr_rom[3] = 32'h0063_2503;  // LW x10, x6, 6
        instr_rom[4] = 32'hfe62_8ce3;  // beq  x5, x6, -8
        instr_rom[5] = 32'hfe62_9ce3;  // bne  x5, x6, -8
      end
    `endif

    initial
    $readmemh("./rtl/rom_code_ex1.mem",instr_rom,0);

    assign instr_code = instr_rom[instr_addr[31:2]];

endmodule
