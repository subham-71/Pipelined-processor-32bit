// Register to memory type

module test_mips32;
    reg clk1, clk2;
    integer k;

    processor mips (clk1, clk2);

    initial begin
        clk1 = 0;
        clk2 = 0;
        repeat (20)
        begin
            #5 clk1 = 1; 
            #5 clk1 = 0;
            #5 clk2 = 1;
            #5 clk2 = 0;
        end
    end
   
    initial begin
        for(k = 0;k<31;k++)
        begin
            mips.Reg[k] = k;
        end
        
        // Initailising resgister R1 to 120
        mips.Mem[0] = 32'h28010078;   // ADDI  R1, R0, 120  => R1 = 120

        mips.Mem[1] = 32'h0c631800;   // OR   R3, R3, R3    -- dummy instruction

        // Loading data from memory add 64 to register R2      
        mips.Mem[2] = 32'h20220000;   // LW   R2, 0 (R1) => R2 = Mem[120] =85

        mips.Mem[3] = 32'h0c631800;   // OR   R3, R3, R3   -- dummy instruction

        // Adding 45 with value stored in R2 and again storing it in R2
        mips.Mem[4] = 32'h2842002d;   // ADDI  R2, R2, 45  => R2 = 85+45 =130

        mips.Mem[5] = 32'h0c842000;   // OR  R4, R4, R4   -- dummy instruction

        // Storing the value obtained from R2 in Memory address 120+1 i.e 121
        mips.Mem[6] = 32'h24220001;   // SW  R2, 1 (R1)   => Mem[120+1]= 130
        
        mips.Mem[7] = 32'h24220001;   // HLT

        mips.Mem[120] = 85;
        mips.PC = 0;
        mips.HALTED = 0;
        
        #500
        
        $display ("Mem[120]: %4d \nMem[121]: %4d" , mips.Mem[120] , mips.Mem[121]);
    end

    initial begin
        $dumpfile ("tb_1.vcd");
        $dumpvars (0, test_mips32);
        #100000 $finish;
    end
endmodule