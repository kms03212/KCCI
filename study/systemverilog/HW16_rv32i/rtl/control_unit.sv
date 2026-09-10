module control_unit
    import rv32i_pkg::*;
(
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] instr_code,
    output logic        rf_we,
    output logic        alusrc_sel,
    output logic        branch,
    output logic        jal,
    output logic        jalr,
    output logic [ 3:0] alu_control,
    output logic [ 2:0] rf_srcsel,
    output logic        dwe,
    output logic [ 2:0] itype,        // instruction tpye : funct3
    //output logic        fet2_dec_en,
    output logic        pc_en
    //output logic
);
    logic [2:0] funct3;

    opcode_e opcode;
    instr_rtype_e instr_rtype;
    instr_btype_e instr_btype;

    assign opcode = opcode_e'(instr_code[6:0]);
    assign funct3 = instr_code[14:12];

    typedef enum logic [2:0] {
        FETCH,
        DECODE,
        EXECUTE,
        MEM,
        WB
    } state_e;

    state_e c_state, n_state;

    //for debuging
    assign instr_rtype = instr_rtype_e'(alu_control);
    assign instr_btype = instr_btype_e'(funct3);

    always_ff @(posedge clk) begin
        if (!rst_n) c_state <= FETCH;
        else begin
            c_state <= n_state;
        end
    end

    always_comb begin
        n_state = c_state;
        case (c_state)
            FETCH: n_state = DECODE;
            DECODE: n_state = EXECUTE;
            EXECUTE:
            case (opcode)
                OP_RTYPE, OP_BTYPE, OP_ITYPE, OP_ULTYPE, OP_UATYPE,OP_JTYPE, OP_JLTYPE :
                n_state = FETCH;
                OP_STYPE, OP_ILTYPE: n_state = MEM;
            endcase
            MEM:
            if (opcode == OP_STYPE) n_state = FETCH;
            else n_state = WB;
            WB: n_state = FETCH;
        endcase
    end

    always_comb begin
        rf_we       = 1'b0;
        alusrc_sel  = 1'b0;
        jal         = 1'b0;
        jalr        = 1'b0;
        alu_control = 4'b0_000;  // {funct7[5], funct3}
        rf_srcsel   = 3'd0;  // TO control for WB to reg_file,
        dwe         = 1'b0;
        itype       = 3'b111;  // SW,LW
        branch      = 1'b0;
        pc_en       = 1'b0;
        case (c_state)
            FETCH: pc_en = 1'b1;
            //DECODE:
            EXECUTE: begin
                case(opcode)
                    OP_RTYPE: begin  // R-type
                        rf_we = 1'b1;
                        alusrc_sel = 1'b0;  // rd2-> mux (0) -> alu
                        alu_control = {instr_code[30], funct3};
                        rf_srcsel   = 3'd0;  // TO control for WB to reg_file, 0 : alu_result, 1:drdata
                    end
                    OP_STYPE: begin  // S-type
                        alusrc_sel  = 1'b1;
                        alu_control = 4'd0;
                    end
                    OP_ITYPE: begin  // I-type
                        rf_we      = 1'b1;
                        alusrc_sel = 1'b1;  // use imm
                        rf_srcsel  = 3'd0;
                        if (funct3 == 3'b101)
                            alu_control = {instr_code[30], funct3};
                        else alu_control = {1'b0, funct3};
                    end
                    OP_ILTYPE: begin  // IL-type
                        alusrc_sel  = 1'b1;  // to calculate data mem addr
                        alu_control = 4'd0;  // ADD RS1 +Imm
                    end
                    OP_BTYPE: begin
                        alusrc_sel  = 1'b0;
                        branch      = 1'b1;
                        alu_control = {1'b0, funct3};
                    end
                    // U : LUI (rd = imm)
                    OP_ULTYPE: begin
                        rf_we     = 1'b1;
                        rf_srcsel = 3'd2;
                    end
                    // U : AUIPC
                    OP_UATYPE: begin
                        rf_we     = 1'b1;
                        rf_srcsel = 3'd3;
                    end
                    OP_JLTYPE: begin
                        rf_we     = 1'b1;
                        rf_srcsel = 3'd4;
                        jalr      = 1'b1;
                    end
                    OP_JTYPE: begin
                        rf_we     = 1'b1;
                        rf_srcsel = 3'd4;
                        jal       = 1'b1;
                    end
                endcase
            end

            MEM: begin
                itype = funct3;
                if(opcode == OP_STYPE) dwe = 1'b1;
            end

            WB: begin
                rf_we = 1'b1;
                rf_srcsel = 3'd1;
            end
        endcase
    end

endmodule
