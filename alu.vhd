library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
generic (
WIDTH : positive := 32);

port( 
	input1			: in std_logic_vector(WIDTH-1 downto 0); 
	input2			: in std_logic_vector(WIDTH-1 downto 0); 
	ALU_CTRL_SEL	: in std_logic_vector(4 downto 0); 					 
	IR_10_to_6		: in std_logic_vector(4 downto 0);		
	branch_taken   : out std_logic; 
	result_low		: out std_logic_vector(WIDTH-1 downto 0); 
	result_high		: out std_logic_vector(WIDTH-1 downto 0)
); 	
end alu; 

architecture ALU of alu is 

--	
	constant C_ADD		: std_logic_vector(4 downto 0) := "00000"; 
	constant C_ADDi	: std_logic_vector(4 downto 0) := "00001";
	constant C_SUB		: std_logic_vector(4 downto 0) := "00010";	
	constant C_SUBi	: std_logic_vector(4 downto 0) := "00011";
	constant C_MULT	: std_logic_vector(4 downto 0) := "00100";
	constant C_MULTu	: std_logic_vector(4 downto 0) := "00101";
	constant C_AND		: std_logic_vector(4 downto 0) := "00110";
	constant C_ANDi	: std_logic_vector(4 downto 0) := "00111";
	constant C_OR		: std_logic_vector(4 downto 0) := "01000";
	constant C_ORi		: std_logic_vector(4 downto 0) := "01001";
	constant C_XOR		: std_logic_vector(4 downto 0) := "01010";
	constant C_XORi	: std_logic_vector(4 downto 0) := "01011";
	constant C_SRL		: std_logic_vector(4 downto 0) := "01100";
	constant C_SLL		: std_logic_vector(4 downto 0) := "01101";
	constant C_SRA		: std_logic_vector(4 downto 0) := "01110";
	constant C_SLT		: std_logic_vector(4 downto 0) := "01111";
	constant C_SLTi	: std_logic_vector(4 downto 0) := "10000";
	constant C_SLTiu	: std_logic_vector(4 downto 0) := "10001";
	constant C_SLTu	: std_logic_vector(4 downto 0) := "10010";
	constant C_MFHI	: std_logic_vector(4 downto 0) := "10011";
	constant C_MFLO	: std_logic_vector(4 downto 0) := "10100";
	constant C_LOAD	: std_logic_vector(4 downto 0) := "10101";
	constant C_BNE		: std_logic_vector(4 downto 0) := "10110";
	constant C_BRE		: std_logic_vector(4 downto 0) := "10111";
	constant C_BRT		: std_logic_vector(4 downto 0) := "11000";
	constant C_BRLE0	: std_logic_vector(4 downto 0) := "11001";
	constant C_BRG0	: std_logic_vector(4 downto 0) := "11010";
	constant C_BRL0	: std_logic_vector(4 downto 0) := "11011";
	constant C_BRGE0	: std_logic_vector(4 downto 0) := "11100";
	constant C_JMP		: std_logic_vector(4 downto 0) := "11101";
	constant C_JMPL	: std_logic_vector(4 downto 0) := "11110";
	constant C_JMPR	: std_logic_vector(4 downto 0) := "11111";
	
	
begin 
process(input1, input2, ALU_CTRL_SEL, IR_10_to_6)
	variable add 			: unsigned (WIDTH downto 0); 
	variable temp 			: unsigned(WIDTH-1 downto 0); 
	variable mult 			: signed(2*WIDTH-1 downto 0); 
	variable mult_u 		: unsigned(2*WIDTH-1 downto 0); 
	variable temp_shift	: signed(WIDTH-1 downto 0); 
	--variable and_u 	: std_logic_vector(WIDTH-1 downto 0); 
	
begin 
	
	result_high 	<= (others => '0'); 
	--result_low		<= (others => '0'); 
	branch_taken 	<= '0'; 
	
	case ALU_CTRL_SEL is 
	
		--ADD UNSIGNED
		when C_ADD =>  
			add := resize(unsigned(input1), WIDTH+1) + unsigned(input2); 
			result_low <= std_logic_vector(add(WIDTH-1 downto 0));
		
		--ADD IMMEDIATE UNSIGNED
		when C_ADDi => 
			add := resize(unsigned(input1), WIDTH+1) + unsigned(input2); 
			result_low <= std_logic_vector(add(WIDTH-1 downto 0));
		
		--SUB UNSIGNED	is it input1-input2 or vice versa 
		when C_SUB =>
			temp := unsigned(input1) - unsigned(input2);
			result_low <= std_logic_vector(temp(WIDTH-1 downto 0));
			
		--SUB IMMEDIATE UNSIGNED
		when C_SUBi => 
			temp := unsigned(input1) - unsigned(input2);
			result_low <= std_logic_vector(temp(WIDTH-1 downto 0));
		
		--MULT 
		when C_MULT => 
			mult := resize((signed(input1)*signed(input2)), 2*WIDTH); 
			result_low <= std_logic_vector(mult(WIDTH-1 downto 0));
			result_high <= std_logic_vector(mult(2*WIDTH-1 downto WIDTH));
			
		--MULT UNSIGNED
		when C_MULTu => 
			mult_u := resize((unsigned(input1) * unsigned(input2)),2*WIDTH); 
			result_low <= std_logic_vector(mult_u(WIDTH-1 downto 0));
			result_high <= std_logic_vector(mult_u(2*WIDTH-1 downto WIDTH));
			
		--AND 
		when C_AND => 
			result_low <= input1 and input2;  
			
			--ANDi 
		when C_ANDi => 
			result_low <= input1 and input2;  
			
		--OR 
		when C_OR => 
			result_low <= input1 or input2;  
			
		--ORI 
		when C_ORi => 
			result_low <= input1 or input2; 
		
		--XOR 
		when C_XOR => 
			result_low <= input1 xor input2; 
		
		
		--XORI 
		when C_XORi => 
			result_low <= input1 xor input2;  
		
		--srl -shift right logical "01100"
		when C_SRL =>
			temp := shift_right(unsigned(input2), to_integer(unsigned(IR_10_to_6)));
			result_low <= std_logic_vector(temp); 	
		
		
		--sll -shift left logical "01101"
		when C_SLL => 
			temp := 	shift_left(unsigned(input2), to_integer(unsigned(IR_10_to_6)));
			result_low <= std_logic_vector(temp); 
		
		--sra -shift right arithmetic "01110"
		when C_SRA => 
			if(input2(WIDTH-1) = '1') then 
				temp_shift := shift_right(signed(input2), to_integer(unsigned(IR_10_to_6)));	
				result_low <= std_logic_vector(temp_shift);
			else 
				temp := shift_right(unsigned(input2), to_integer(unsigned(IR_10_to_6)));	
				result_low <= std_logic_vector(temp);
			end if; 
		
		
		--slt -set on less than signed "01111"
		when C_SLT => 
			if(input1 < input2) then 
				result_low <= std_logic_vector(to_unsigned(1,result_low'length)); 
			else 
				result_low <= std_logic_vector(to_unsigned(0,result_low'length)); 
			end if; 
		
--		
--		--slti -set on less than immediate signed "10000"
--		when C_SLTi => 
--		
--		
--		
--		--sltiu- set on less than immediate unsigned "10001"
--		when C_SLTiu => 
		
		
		
		--sltu - set on less than unsigned "10010"
		when C_SLTu => 
		
		if(input1 < input2) then 
			result_low <= x"00000001"; 
		else 
			result_low <= x"00000000"; 
		end if; 
		
		--mfhi -move from Hi "10011"
--		when C_MFHI => 
--		
--		
--		
--		--mflo -move from LO "10100"
--		when C_MFLO => 
		
		
		--load word "10101"
		when C_LOAD => 
			add := resize(unsigned(input1), WIDTH+1) + unsigned(input2); 
			result_low <= std_logic_vector(add(WIDTH-1 downto 0));
		
		
		--Branch not equal "10110"
		when C_BNE => 
			if(input1 /= input2) then 
				branch_taken <= '1'; 
				result_low <= x"00000001"; 
			else 
				branch_taken <= '0';
				result_low <= x"00000000";		
			end if;
		
		
		--branch if equal "10111"
		when C_BRE => 
			if(input1 = input2) then 
				branch_taken <= '1'; 
				result_low <= x"00000001"; 
			else 
				branch_taken <= '0';
				result_low <= x"00000000";		
			end if;
		
		--branch not equal "11000"
		when C_BRT => 
			if(input1 /= input2) then 
				branch_taken <= '1'; 
				result_low <= x"00000001"; 
			else 
				branch_taken <= '0';
				result_low <= x"00000000";		
			end if;
		
		
		
		--Branch on Less Than or Equal to Zero "11001"
		when C_BRLE0 => 
			branch_taken <= '1';	
		
		
		--Branch on Greater Than Zero "11010" 
		when C_BRG0 => 
			branch_taken <= '1';
		
		--Branch on Less Than Zero "11011" 
		when C_BRL0 => 
			branch_taken <= '1';
		
		
	
		--Branch on Greater Than or Equal to Zero "11100" 
		when C_BRGE0 => 
			branch_taken <= '1';
		
			
--		--jump to address  "11101" 
--		when C_JMP => 
--			result_low <= input2;
		
		
--		--jump and link  "11110" 
--		when C_JMPL => 
--		
--		
--		--jump register  "11111" 
--		when C_JMPR => 
		
		when others => 
			null; 
		
	end case; 
end process; 
end ALU; 