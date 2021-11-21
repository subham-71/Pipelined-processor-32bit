// Register to resgister type and Register to memory type

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
        // mips.Reg[2]=120;
        
        // Initailising resgister R1 to 64
        mips.Mem[0] = 32'h28010040;   // ADDI  R1, R0, 64  => R1 = 64

        mips.Mem[1] = 32'h0c631800;   // OR   R3, R3, R3    -- dummy instruction

        // Loading data from memory address 64 to register R2
        mips.Mem[2] = 32'h20220000;   // LW   R2, 0 (R1)   => R2 = Mem[64]=121
        
        mips.Mem[3] = 32'h0c631800;   // OR   R3, R3, R3   -- dummy instruction

        // Multiplying values stored in R1 and R2 together and storing them in R3
        mips.Mem[4] = 32'h14411800;   // MUL  R3, R1, R2   => R3 = R1 * R2 = 64 * 121

        mips.Mem[5] = 32'h0c842000;   // OR  R4, R4, R4   -- dummy instruction

        // Storing the value obtained from R2 in Memory address 64-2 i.e 62
        mips.Mem[6] = 32'h2423FFFE;   // SW  R3, -2 (R1)   => Mem [64-2] = R3 = 7744
        mips.Mem[7] = 32'h24220001;   // HLT

        mips.Mem[64] = 121;
        mips.PC = 0;
        mips.HALTED = 0;
        
        #500
        for(k=0;k<4;k++)begin
            $display ("R%1d - %2d", k, mips.Reg[k]);
        end
        $display ("Mem[64]: %4d \nMem[62]: %4d" , mips.Mem[64] , mips.Mem[62]);
    end

    initial begin
        $dumpfile ("tb_2.vcd");
        $dumpvars (0, test_mips32);
        #100000 $finish;
    end
endmodule