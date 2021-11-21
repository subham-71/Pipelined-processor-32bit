module processor (clk1, clk2);

input  clk1 , clk2;   //Refers to two phase clock

reg [31:0]  PC, IF_ID_IR, IF_ID_NPC; 
// PC = Program Counter
// IF_ID_IR = Instruction register in the latch stage between the IF and ID stages
// IF_ID_NPC = New Program Counter

reg [31:0]  ID_EX_IR, ID_EX_NPC, ID_EX_A, ID_EX_B, ID_EX_Imm;
// ID_EX_IR = Instruction register in the latch stage between the ID and EX stages
// ID_EX_NPC = New program counter 
// ID_EX_A = stores value of the register for execution
// ID_EX_B = stores value of the register for execution
// ID_EX_Imm = Immediate value is sign extended to make it 32 bit 

reg [31:0]  EX_MEM_IR , EX_MEM_ALUOut, EX_MEM_B;
// EX_MEM_IR = Instruction register in the latch stage between the EX and MEM stages
// EX_MEM_ALUOut =  Temporary register to store the output of the execution
// EX_MEM_B = To store value while execution

reg [31:0]  MEM_WB_IR, MEM_WB_ALUOut, MEM_WB_LMD;
// MEM_WB_IR = Instruction register in the latch stage between the MEM and WB stages
// MEM_WB_ALUOut = Containing output of execution
// MEM_WB_LMD = To load memory

reg [2:0] ID_EX_type,EX_MEM_type,MEM_WB_type;

reg [31:0]  Reg [0:31];      // Register bank (32 ✕ 32) 32 registers each of 32 bit
reg [31:0]  Mem [0:1023];    // 1024 ✕ 32 memory , 32 bit instruction set containing information about opcode source , destination register and offset

// operation codes for operations
parameter 
ADD= 6'b000000,  //ADD =  A+ B
SUB=6'b000001,  // SUB = A-B
AND=6'b000010,   // AND = A & B
OR=6'b000011,    // OR = A|B
CMP= 6'b000100,  // CMP = A<B 
MUL=6'b000101,   // MUL = A*B

ADDI= 6'b001010, // Adding a number with a value stored in a register
SUBI = 6'b001011, // Subtracting a number from a value stored in a register
CMPI=6'b001100 , // Stores 1 if given number is less than value stored in a register 

LW=6'b001000,    // load word
SW=6'b001001,    // store word
HLT= 6'b111111,  // to halt the instruction

//type of instructions
RR_ALU= 3'b000,   // Register to register
RM_ALU = 3'b001,  // Register to memory
LOAD = 3'b010,    // Loading data from mem address to register  
STORE= 3'b011,    // Storing data from register to mem address
HALT= 3'b101;     // Halting the program

reg HALTED;       // flag set to 1 if halt detected

// IF stage
always @(posedge clk1 ) 
begin
    if(HALTED==0)
    begin    
        IF_ID_IR <= #2 Mem[PC];
        IF_ID_NPC <= PC+1; 
        PC <= #2 PC+1;     // increasing program counter to get the next instruction
    end
end

//ID stage
always @(posedge clk2 ) 
begin
    if(HALTED==0)
    begin
        if(IF_ID_IR[25:21]==5'b00000)
            begin
                ID_EX_A <= 0;
            end
        else 
            begin
                ID_EX_A <= #2 Reg[IF_ID_IR[25:21]]; 
            end

        if(IF_ID_IR[20:16]==5'b00000)
            begin
                ID_EX_B <= 0;
            end
        else
            begin
                ID_EX_B <= #2 Reg[IF_ID_IR[20:16]]; 
            end
        ID_EX_NPC <= #2 IF_ID_NPC;
        ID_EX_IR  <= #2 IF_ID_IR;
        ID_EX_Imm <= #2 {{16{IF_ID_IR[15]}},{IF_ID_IR[15:0]}};

        case (IF_ID_IR[31:26])
            ADD,SUB,AND,OR,CMP,MUL : ID_EX_type <= #2 RR_ALU;
            ADDI,SUBI,CMPI :         ID_EX_type <= #2 RM_ALU;
            LW :                     ID_EX_type <= #2 LOAD;
            SW :                     ID_EX_type <= #2 STORE;
            HLT :                    ID_EX_type <= #2 HALT;
            default :                ID_EX_type <= #2 HALT;
        endcase
    end     
end

//EX Stage
always @(posedge clk1 ) 
begin
    if(HALTED==0)
    begin
        EX_MEM_type <= #2 ID_EX_type;
        EX_MEM_IR <= #2 ID_EX_IR;
       
        case (ID_EX_type)
        RR_ALU : begin
                    case(ID_EX_IR[31:26])
                        ADD: EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_B ; 
                        SUB: EX_MEM_ALUOut <= #2 ID_EX_A - ID_EX_B ; 
                        AND: EX_MEM_ALUOut <= #2 ID_EX_A & ID_EX_B ; 
                        OR:  EX_MEM_ALUOut <= #2 ID_EX_A | ID_EX_B ; 
                        CMP: EX_MEM_ALUOut <= #2 ID_EX_A < ID_EX_B ; 
                        MUL: EX_MEM_ALUOut <= #2 ID_EX_A * ID_EX_B ; 
                        default: EX_MEM_ALUOut <= #2 32'hxxxxxxxx ; 
                    endcase
                 end
        RM_ALU : begin
                    case(ID_EX_IR[31:26])
                        ADDI : EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_Imm;
                        SUBI : EX_MEM_ALUOut <= #2 ID_EX_A - ID_EX_Imm; 
                        CMPI : EX_MEM_ALUOut <= #2 ID_EX_A < ID_EX_Imm; 
                        default : EX_MEM_ALUOut <= #2 32'hxxxxxxxx; 
                    endcase
                 end
        LOAD,STORE :
                 begin
                     EX_MEM_ALUOut <= #2 ID_EX_A +ID_EX_Imm;
                     EX_MEM_B      <= #2 ID_EX_B;
                 end
        endcase
    end 
end

//MEM Stage
always @(posedge clk2 ) 
begin
    if(HALTED==0)
    begin
       MEM_WB_type <= #2 EX_MEM_type;
       MEM_WB_IR <= #2 EX_MEM_IR;

       case (EX_MEM_type)
            RR_ALU,RM_ALU :  MEM_WB_ALUOut <= #2 EX_MEM_ALUOut ; 
            LOAD : MEM_WB_LMD <= #2 Mem[EX_MEM_ALUOut]; 
            STORE : 
                begin
                    Mem[EX_MEM_ALUOut] <= #2 EX_MEM_B; //written in memory
                end 
        endcase    
    end
end

//WB stage
always @(posedge clk1 ) 
begin
    case(MEM_WB_type)
        RR_ALU : Reg[MEM_WB_IR[15:11]] <= #2 MEM_WB_ALUOut ; //written in rd
        RM_ALU : Reg[MEM_WB_IR[20:16]] <= #2 MEM_WB_ALUOut ; //written in rt
        LOAD   : Reg[MEM_WB_IR[20:16]] <= #2 MEM_WB_LMD    ; //written in rt
        HALT   : HALTED <= #2 1'b1;                          // halt flag set to 1
    endcase
end

endmodule