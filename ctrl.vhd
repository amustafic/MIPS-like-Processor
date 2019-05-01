library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ctrl is 
	generic (WIDTH : positive); 
	
	port( 
		clk			: in std_logic; 
		rst			: in std_logic; 
		IR31_26 		: in std_logic_vector(5 downto 0);
		IR20_16 		: in std_logic_vector(4 downto 0); 
		IR25_21		: in std_logic_vector(4 downto 0); 
		IR15_0		: in std_logic_vector(15 downto 0); 
		JumpandLink : out std_logic; 
		IsSigned 	: out std_logic; 
		PCSource 	: out std_logic_vector(1 downto 0);
		ALUOp 		: out std_logic_vector(4 downto 0); 
		ALUSrcB 		: out std_logic_vector(1 downto 0); 
		ALUSrcA		: out std_logic; 
		RegWrite 	: out std_logic; 
		RegDst 		: out std_logic_vector(1 downto 0); 
		PCWriteCond : out std_logic; 
		PCWrite 		: out std_logic; 
		IorD 			: out std_logic; 
		MemRead 		: out std_logic; 
		MemWrite 	: out std_logic; 
		MemToReg 	: out std_logic; 
		IRWrite		: out std_logic
		); 
		
end ctrl; 

architecture CTRL of ctrl is
	type STATE_TYPE is (INIT, DECODE, JMP, JMPL1, JMPL3, BR, S_WAIT, IR, S_WAIT2, S_WAIT3, S_WAIT4,MEM_WAIT,S_WAIT5, ANDi_WAIT, ANDi_WAIT2, COMPL, MFLO,
								S_STORE_WAIT, S_STORE_WAIT1, S_STORE_WAIT2, HALT, R_TYPE1, R_TYPE2, JMPL2, I_COMPL,ORi_WAIT, ADDiu_WAIT1, BR_WAIT, BR_WAIT2, SUBiu_WAIT1,
								XORi_WAIT, MEM_WAIT2, BNE, BNE_WAIT, WAIT_BR); 
	signal state, next_state : STATE_TYPE;
begin 

	process(clk, rst) 
	 begin 
		 if (rst = '1') then
			state <= INIT;	
		 elsif (clk'event and clk = '1') then
			state <= next_state;
		 end if;
	end process;
	  
	process(IR31_26, state,IR20_16, IR25_21, IR15_0) 
	begin 
	
	--default values 
	IsSigned 	<= '1';
	MemRead  	<= '0'; 
	MemWrite		<= '0'; 
	JumpAndLink <= '0'; 
	ALUOp			<= "01010"; 	--random
	PCWriteCond	<= '0'; 
	PCWrite		<= '0'; 
	IorD			<= '0'; 
	MemToReg		<= '0'; 
	IRWrite		<= '0'; 
	PCSource		<= "00"; 
	ALUSrcA  	<= '0'; 
	ALUSrcB		<= "00";
	RegWrite		<= '0'; 
	RegDst		<= "00"; 
	
	next_state <= state; 
	
	case state is 
	
		when INIT => 
			ALUOp		<= "00001";
			MemRead 	<= '1'; 
			--IRWrite	<= '1'; 
			next_state <= MEM_WAIT;
			
		when MEM_WAIT => 
			next_state <= IR; 
			
		when IR => 
			--MemWrite <= '0'; 
			--IorD		<= '0';
			ALUSrcA  <= '0'; 
			ALUSrcB	<= "01"; 
			ALUOp		<= "00001"; 	
			PCSource <= "00"; 
			PCWrite  <= '1'; 
			IRWrite	<= '1';
			next_state <= DECODE;
			 
		when DECODE => 
		
			case IR31_26 is 
		
				when "000000" => 
					ALUOp 		<= "00000"; 
					ALUSrcA		<= '1'; 
					ALUSrcB		<= "00"; 
					RegDst		<= "01";
					--RegWrite <= '1';	
					if(IR15_0(5 downto 0) = "010010") then 
						next_state <= MFLO; 
					elsif(IR15_0(5 downto 0) = "010000") then 
						next_state <= MFLO; 
					else 
						next_state	<= R_TYPE1; 
					end if; 
					
					
				when "001001" =>	--ADDiu
					--ALUOp 	<= "00001";  
					next_state	<= ADDiu_WAIT1; 
					
				when "010000" => 	--SUBiu
					 
					next_state	<= SUBiu_WAIT1; 
					
				when "001100" => 
					--ALUOp 	<= "00011";	--ANDi
--					ALUSrcB	<= "10";
--					ALUSrcA	<= '1';
--					IsSigned	<= '0';
					--PCWrite     <= '1';
					next_state	<= ANDi_WAIT; 	
					
				when "001101" => 
					
					next_state	<= ORi_WAIT; 
					
				when "001110" => 
					
					next_state	<= XORi_WAIT; 
					
				when "001010" => 
					ALUOp <= "00110"; 	--SLTi
					ALUSrcB	<= "10";
					ALUSrcA	<= '1';
					next_state	<= INIT; 
					
				when "001011"=>
					ALUOp <= "00111"; 	--SLTiu 
					ALUSrcB	<= "10";
					ALUSrcA	<= '1';
					next_state	<= INIT; 
					
				when "100011" => 			--load word 
					ALUOp 	<= "00001";	--addi 
					RegWrite		<= '0';
					MemRead 	<= '0'; 		--it's a default
					MemWrite <= '0'; 
					RegDst	<= "01";	
					MemtoReg	<= '0';
					PCWrite		<= '0'; 
					next_state	<= S_WAIT; 
					
				when "101011" => 			--store word
					
					ALUOp 	<= "00001";	--addi 
					RegWrite		<= '0';
					MemRead 	<= '0'; 		--it's a default
					MemWrite <= '0'; 
					RegDst	<= "01";	
					MemtoReg	<= '0';
					PCWrite		<= '0'; 	
					next_state	<= S_STORE_WAIT1; 
							
				when "000100" => 	--branch if equal
					
					next_state	<= BR_WAIT; 
				
					
				when "000101" => 		--branch not equal 
					
					next_state	<= BNE_WAIT;
					
				when "000110" => 
					
					if(IR25_21 <= "00000") then 
							
							next_state 	<= BR; 
							
						else 
							next_state	<= INIT; 
						end if; 
						
				when "000111" => 
						--branch greater 0 
					if(IR25_21 > "00000") then 
							
							next_state 	<= BR; 
							
						else 
							next_state	<= INIT; 
						end if; 
						
				when "000001" => 		--two branches  
					if(IR20_16 = "00000") then --les than zero
						if(IR25_21 < "00000") then 
				
							next_state 	<= BR; 
							
						else 
							next_state	<= INIT; 
						end if; 
						
					elsif(IR20_16 = "00001") then 	--greater or equal to 0 
						if(IR25_21 >= "00000") then 
						 
							next_state 	<= BR; 
							
						else 
							next_state	<= INIT; 
						end if; 
						
					end if; 	
						 
					
				when "000010" => 	--JMP
					AluSrcA 		<= '1'; 
					AluSrcB		<= "11";
					next_state 	<= JMP;  
					
					
				when "000011" => 
						--jump and link 
					--RegDst 		<= "00";	
					next_state 	<= JMPL1; 
				
				when "111111" =>  --HALT 
					PCWrite  <= '0'; 
					--MemRead  <= '1'; 
					next_state <= HALT; 
					
				when others => 
					null; 
				
			end case;
				
			when ADDiu_WAIT1 => 
				ALUOp 	<= "00001"; 
				ALUSrcB	<= "10";
				ALUSrcA	<= '1';
				next_state <= I_COMPL;
			
			when I_COMPL => 
				RegWrite		<= '1';
				RegDst		<= "01";
				next_state	<= INIT; 
		
			when SUBiu_WAIT1 => 
				ALUOp <= "00010"; 
				ALUSrcB	<= "10";
				ALUSrcA	<= '1';
				next_state <= I_COMPL;
			
			when ORi_WAIT	=> 
				ALUOp <= "00100"; 	--ORi
				ALUSrcB	<= "10";
				ALUSrcA	<= '1';
				IsSigned	<= '0';
				next_state <= I_COMPL;
			
			when XORi_WAIT	=> 
				ALUOp <= "00101";	--XORi
				ALUSrcB	<= "10";
				ALUSrcA	<= '1';
				IsSigned	<= '0';
				next_state <= I_COMPL;
				
			when S_WAIT =>
				MemRead 		<= '1'; 
				next_state	<= S_WAIT2;
				
			when S_WAIT2 => 
				ALUOp		<= "00001";
				ALUSrcB	<= "10";
				ALUSrcA	<= '1';
				RegDst		<= "01";
				next_state	<= S_WAIT3;
			
			when S_WAIT3 => 
			
				 IorD			<= '1';
				 MemRead		<= '1';
				 RegDst		<= "01";
				 next_state	<= S_WAIT4;
				
			when S_WAIT4 =>  
				RegDst		<= "01";
				MemToReg		<= '1'; 
				next_state <= S_WAIT5;
			
			when S_WAIT5 => 
				RegWrite 	<= '1'; 
				MemtoReg		<= '1'; 
				RegDst		<= "01";
				next_state <= INIT;
				
			when S_STORE_WAIT =>
				MemWrite 	<= '1';
				next_state  <= S_STORE_WAIT1;
			
			when S_STORE_WAIT1 => 
				ALUOp		<= "00001";
				ALUSrcA	<= '1'; 
				ALUSrcB	<= "10";
				RegDst		<= "01";
				next_state  <= S_STORE_WAIT2; 
			
			when S_STORE_WAIT2 => 
				MemtoReg  <= '1'; 
				IorD		<= '1';
				MemWrite 	<= '1';
				RegDst		<= "01";
				next_state	<= INIT;
				
			when ANDi_WAIT =>
				
            ALUOp 	<= "00011";	--ANDi
				ALUSrcB	<= "10";
				ALUSrcA	<= '1';
				IsSigned	<= '0';
					--PCWrite     <= '1';
				next_state <= ANDi_WAIT2; 
				
			when ANDi_WAIT2 => 
				RegWrite		<= '1';
				RegDst		<= "01";
				next_state	<= INIT; 
			
			when COMPL => 
				ALUSrcA		<= '1';
				RegDst <= "10"; 
				RegWrite <= '1'; 
				next_state	<= INIT; 
			
			when R_TYPE1 =>
				--ALUOp 		<= "00000";
				ALUSrcA		<= '1';
				RegDst <= "10"; 
				--RegWrite <= '1'; 
				next_state	<= R_TYPE2;
				
			when R_TYPE2 => 
				ALUSrcA		<= '1';
				RegDst <= "10"; 
				RegWrite <= '1'; 
				next_state	<= INIT;
				
			when MFLO => 
				ALUOp 		<= "00000"; 
				ALUSrcA		<= '1';
				RegDst <= "10"; 
				RegWrite <= '1'; 
				next_state	<= INIT; 
			
			when HALT => 
				next_state 	<= HALT;
				
			when BNE_WAIT	=> 
				ALUOp <= "00001";
				ALUSrcA		<= '0'; 
				ALUSrcB		<= "11"; 
				next_state	<= BNE; 
				
			when BNE 	=> 
				ALUOp <= "01011";			--branch if not equal 
				ALUSrcA 		<= '1'; 
				ALUSrcB 		<= "00"; 
				PCSource		<= "01"; 
				PCWriteCond <= '1';
				next_state	<= INIT; 
				
			when BR_WAIT	=> 
				ALUOp 		<= "00001";		--add PC + target 
				ALUSrcA		<= '0'; 
				ALUSrcB		<= "11"; 				
				next_state 	<= BR; 				
					
			when BR => 
				--ALUOp <= "01011";
				ALUOp			<= "01101"; 	--branch if equal
				ALUSrcA 		<= '1'; 
				ALUSrcB 		<= "00"; 
				PCSource		<= "01"; 
				PCWriteCond <= '1';
				next_state	<= INIT;
			
			when WAIT_BR => 		
				ALUOp 		<= "00001";		--add PC + target
				ALUSrcA 		<= '1'; 
				ALUSrcB 		<= "00"; 
				PCSource		<= "01"; 
				PCWriteCond <= '1';
				next_state	<= INIT; 
				
			when JMP =>  
				RegDst		<= "01";
				PCWrite		<= '1'; 
				PCSource 	<= "10";
				next_state	<= INIT;   
				
			when JMPL1 => 
				ALUOp		<= "00001";	
				ALUSrcA 		<= '0'; 
				ALUSrcB 		<= "01";   
				next_state 	<= JMPL2; 
				
			when JMPL2 => 
				next_state 	<= JMPL3; 
			
			when JMPL3 =>  
				JumpandLink	<= '1'; 
				RegWrite		<= '1'; 
				RegDst		<= "01";
				PCWrite		<= '1'; 
				PCSource 	<= "10";
				next_state	<= INIT;  
				 
				
			when others => 
				null; 
				
	end case; 	
	end process; 
end CTRL; 
				
				
				
				