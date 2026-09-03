module control_unit(
	input		logic [31:0]	instr_code,
	output	logic					rf_we,
	output	logic	        alusrc_sel,
	output	logic	[ 3:0]	alu_control,
  output  logic         dwe,
  output  logic [ 2:0]  itype // instruction type : func3
);
  logic [2:0] func3;
  assign func3 = instr_code[14:12];

	always_comb begin
		rf_we				= 1'b0;
    alusrc_sel  = 1'b0;
		alu_control	= 4'b0_000; 
    dwe         = 1'b0;
    itype       = 3'b010;  // SW
		case(instr_code[6:0])
			7'b011_0011: begin // R-tpye
				rf_we = 1'b1;
        alusrc_sel = 1'b0;
				alu_control	= {instr_code[30],func3};
        dwe = 1'b0;
        itype = 3'b000;
			end
			7'b010_0011: begin // S_type
				rf_we = 1'b0;
        alusrc_sel = 1'b1;
				alu_control	= 32'd0;
        dwe = 1'b1;
        itype = func3; // SW,LW
			end

		endcase
	end

endmodule
