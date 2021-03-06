library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU_ctrl is 
	generic (WIDTH : positive); 
	
	port( 
		clk			: in std_logic; 
		rst			: in std_logic; 
		ALUOp			: in std_logic_vector(4 downto 0); 
		IR_5_to_0	: in std_logic_vector(5 downto 0);
		HI_en			: out std_logic; 
		LO_en			: out std_logic; 
		ALU_LO_HI	: out std_logic_vector(1 downto 0); 
		OPSelect		: out std_logic_vector(4 downto 0)
		--IR_20_to_16	: in std_logic_vector(4 downto 0)
	); 
end ALU_ctrl; 
	
architecture CTRL of ALU_ctrl is 
	type STATE_TYPE is (START, S_END, S_WAIT_MULTu); 
	signal state, next_state : STATE_TYPE;
	
begin 

	process(clk, rst) 
	 begin 
		 if (rst = '1') then
			state <= START;	
		 elsif (clk'event and clk = '1') then
			state <= next_state;
		 end if;
	end process;
	
	process(ALUOp, IR_5_to_0, state) 
	begin 
		HI_en <= '0'; 
		LO_en <= '0'; 
		ALU_LO_HI <= "00";
		--OPSelect <= "00000";
		next_state <= state; 
		
		case state is 
		
		when START => 
		
		case ALUOp is 
		
		when "00000" => 
			if(IR_5_to_0 = "100001") then 
				OPSelect <= "00000"; --ADD
				ALU_LO_HI <= "00"; 
				next_state <= START; 
				
			elsif(IR_5_to_0 = "100011") then
				OPSelect <= "00010"; --SUBu 
				ALU_LO_HI <= "00";
				next_state <= START; 
				
			elsif(IR_5_to_0 = "011000") then 
				OPSelect <= "00100";	--MULT
				ALU_LO_HI <= "00";
--				HI_en <= '1'; 
--				LO_en <= '1'; 
				next_state <= S_WAIT_MULTu; 
				
			elsif(IR_5_to_0 = "011001") then 
				OPSelect <= "00101";	--MULTu
				ALU_LO_HI <= "00";
				
--				HI_en <= '1'; 
--				LO_en <= '1';
				next_state <= S_WAIT_MULTu; 
				--send a signal here 
				
			elsif(IR_5_to_0 = "100100") then 
				OPSelect <= "00110";	--AND
				ALU_LO_HI <= "00";
				next_state <= START; 
				
			elsif(IR_5_to_0 = "100101") then
				OPSelect <= "01000"; --OR
				ALU_LO_HI <= "00";
				next_state <= START; 
				
			elsif(IR_5_to_0 = "100110") then
				OPSelect <= "01010"; --XOR
				ALU_LO_HI <= "00";
				next_state <= START; 
				
			elsif(IR_5_to_0 = "000010") then
				OPSelect <= "01100"; --SRL
				ALU_LO_HI <= "00";
				next_state <= START; 
				
			elsif(IR_5_to_0 = "000000") then
				OPSelect <= "01101";	--SLL
				ALU_LO_HI <= "00";
				next_state <= START; 
				
			elsif(IR_5_to_0 = "000011") then
				OPSelect <= "01110";	--SRA
				ALU_LO_HI <= "00";
				next_state <= START; 
				
			elsif(IR_5_to_0 = "101010") then
				OPSelect <= "01111";	--SLT
				ALU_LO_HI <= "00";
				
			elsif(IR_5_to_0 = "101011") then
				OPSelect <= "10010";	--SLTu
				ALU_LO_HI <= "00";
				next_state <= START; 
				
			elsif(IR_5_to_0 = "010000") then
				--OPSelect <= "10011";	--MFHI
				ALU_LO_HI <= "10";
				
				
			elsif(IR_5_to_0 = "010010") then
				--OPSelect <= "10100";	--MFLO
				ALU_LO_HI <= "01";
				next_state <= START; 
				
			elsif(IR_5_to_0 = "001000") then
				OPSelect <= "11111";	--JMPR
				ALU_LO_HI <= "00";
				next_state <= START; 
			
			else 
				next_state <= START; 
			end if; 
				
		
		when "00001" => 
		--ADDiu  
			OPSelect <= "00001";
			next_state <= START; 
			
		when "00010" => 
		--SUBiu
			OPSelect <= "00011";
			next_state <= START; 
			
		when "00011" => 
		--ANDi 
			OPSelect <= "00111";
			next_state <= START; 
			
		when "00100" =>
		--ORi
			OPSelect <= "01001";
			next_state <= START; 
			
		when "00101" =>
		--XORi 
			OPSelect <= "01011";
			next_state <= START; 
			
		when "00110" =>
		--SLTi
			OPSelect <= "10000";
			next_state <= START; 
			
		when "00111" =>
		--SLTiu 
			OPSelect <= "10001";
			next_state <= START; 
			
		when "01000" =>
		--load word 
			OPSelect <= "10101";
			next_state <= START; 
			
--		when "01001" =>
--		--store word
--			OPSelect <= "10110";
--			next_state <= START; 
			
		when "01010" =>	--dummy 
		--branch eq 
			--OPSelect <= "10111";
		next_state <= START;
			
		when "01101" =>
		--branch if equal 
			OPSelect <= "10111"; 
			next_state <= START;
			
		when "01011" =>
		--branch not equal 
			OPSelect <= "10110"; 
			next_state <= START;
			
--		when "01110" =>	
--			if(IR_20_to_16 = '0') then 
--		--branch less than 0 
--			OPSelect <= "11011"; 
--			
--			elsif(IR_20_to_16 = '1')
--		--branch gr or eq 0 
--			OPSelect <= "11100"; 
--			
--			end if; 
		
		when "01111" =>
		--pass input2
			OPSelect <= "11101"; 
			next_state <= START;

--		when "10000" =>
--		--jump and link 
--			OPSelect <= "11110"; 
		
		when others => 
			null; 
			
	end case;
	when S_END => 
		HI_en <= '0'; 
		LO_en <= '0'; 
		ALU_LO_HI <= "00";
		next_state <= START;
		
	when S_WAIT_MULTu => 
		HI_en <= '1'; 
		LO_en <= '1';
		next_state <= START;
		
	when others => 
			null; 
end case; 
end process; 
end CTRL; 
		
		
		
		