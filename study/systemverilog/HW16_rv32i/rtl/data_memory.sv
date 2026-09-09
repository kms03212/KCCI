module data_mem (
    input  logic        clk,
    input  logic [31:0] daddr,
    input  logic [31:0] dwdata,
    input  logic        dwe,
    input  logic [ 2:0] itype,
    output logic [31:0] drdata
);

    logic [31:0] dmem[0:127];  //word addres
    logic [31:0] read_word;
    logic [7:0]  read_byte;
    logic [15:0] read_half;

    //assign drdata = dmem[daddr[31:2]];-> because always_comb use
    assign read_word = dmem[daddr[31:2]];
    assign read_byte = read_word >> (8*daddr[1:0]);
    assign read_half = daddr[1] ? read_word[31:16] : read_word [15:0];

    always_ff @(posedge clk) begin
        if (dwe) begin
            case (itype)
                // sw word address
                3'b010: dmem[daddr[31:2]] <= dwdata;

                // sb byte address
                3'b000:
                case (daddr[1:0])
                    2'b00: dmem[daddr[31:2]][7:0] <= dwdata[7:0];
                    2'b01: dmem[daddr[31:2]][15:8] <= dwdata[7:0];
                    2'b10: dmem[daddr[31:2]][23:16] <= dwdata[7:0];
                    2'b11: dmem[daddr[31:2]][31:24] <= dwdata[7:0];
                endcase

                // sh half address
                3'b001:
                if (daddr[1]) dmem[daddr[31:2]][31:16] <= dwdata[15:0];
                else dmem[daddr[31:2]][15:0] <= dwdata[15:0];

                default: dmem[daddr[31:2]] <= dmem[daddr[31:2]];
            endcase
        end
    end

    //load 
    always_comb begin
        case(itype)
            3'b000: drdata = {{24{read_byte[7]}}, read_byte}; // LB
            3'b001: drdata = {{16{read_half}}, read_half};    // LH
            3'b010: drdata = read_word;                       // LW
            3'b100: drdata = {24'b0,read_byte};               // LBU
            3'b101: drdata = {15'b0,read_half};               // LHU
            default: drdata = 32'b0;
        endcase
    end



endmodule