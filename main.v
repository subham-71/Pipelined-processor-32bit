module processor (clk1, clk2);

input  clk1 , ckl2;   //Refers to two phase clock

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

reg [31:0]  Reg [0:31];      // Register bank (32 ✕ 32) 32 registers each of 32 bit
reg [31:0]  Mem [0:1023];    // 1024 ✕ 32 memory , 32 bit instruction set containing information about opcode source , destination register and offset

// operation codes for operations
parameter 
ADD= 6'b000000,  //ADD =  A+ B
SUB=6'b0000001,  // SUB = A-B
AND=6'b000010,   // AND = A & B
OR=6'b000011,    // OR = A|B
CMP= 6'b000100,  // CMP = A<B 
MUL=6'b000101,   // MUL = A*B

ADDI= 6'b001010, // Adding a number with a value stored in a register
SUBI = 6'b001011, // Subtracting a number from a value stored in a register
CMPI=6'b001100 , // Stores 1 if given number is less than value stored in a register 

LW=6'b001000,    // load word
SW=6'b001001,    //store word
HLT= 6'b111111,  // to halt the instruction


endmodule