library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_tb is 
end alu_tb; 

architecture TB of alu_tb is

component alu 
	generic ( 
		WIDTH : positive := 32
		);
	port( 
		input1			: in std_logic_vector(WIDTH-1 downto 0); 
		input2			: in std_logic_vector(WIDTH-1 downto 0); 
		ALU_CTRL_SEL	: in std_logic_vector(4 downto 0); 					
		IR_10_to_6		: in std_logic_vector(4 downto 0);		
		branch_taken   : out std_logic; 
		result_low		: out std_logic_vector(WIDTH-1 downto 0); 
		result_high		: out std_logic_vector(WIDTH-1 downto 0)
		); 
end component; 

		constant WIDTH  : positive:= 32;
		signal input1 			: std_logic_vector(WIDTH-1 downto 0) := (others => '0'); 
		signal input2 			: std_logic_vector(WIDTH-1 downto 0) := (others => '0'); 
		signal ALU_CTRL_SEL 	: std_logic_vector(4 downto 0)		 := (others => '0');
		signal IR_10_to_6		: std_logic_vector(4 downto 0) 		 := (others => '0');	
		signal branch_taken	: std_logic; 
		signal result_low		: std_logic_vector(WIDTH-1 downto 0); 
		signal result_high   : std_logic_vector(WIDTH-1 downto 0); 
		
begin 

	U_ALU	: alu 
		generic map(WIDTH => WIDTH) 
		
		port map( 
			input1 			=> input1, 
			input2 			=> input2, 
			ALU_CTRL_SEL	=> ALU_CTRL_SEL,
			IR_10_to_6		=> IR_10_to_6,
			branch_taken	=> branch_taken,
			result_low		=> result_low,
			result_high		=> result_high ); 
			
	process 
	begin 
		--ADD 10 and 15 
		ALU_CTRL_SEL <= "00000";
		input1 		<= std_logic_vector(to_unsigned(10,input1'length));
		input2 		<= std_logic_vector(to_unsigned(15,input2'length));
		IR_10_to_6 	<= std_logic_vector(to_unsigned(0,IR_10_to_6'length));
		wait for 40 ns;
    
		assert(result_low = std_logic_vector(to_unsigned(25,result_low'length))) report "Error: 10+15 = instead of 25" severity warning; 
		assert(result_high = std_logic_vector(to_unsigned(0,result_high'length))); 
		assert(branch_taken = '0'); 
		
		--SUB 25 and 10 
		ALU_CTRL_SEL <= "00010";
		input1 		<= std_logic_vector(to_unsigned(25,input1'length));
		input2 		<= std_logic_vector(to_unsigned(10,input2'length));
		IR_10_to_6 	<= std_logic_vector(to_unsigned(0,IR_10_to_6'length));
		wait for 40 ns;
    
		assert(result_low = std_logic_vector(to_unsigned(15,result_low'length))) report "Error: 25-10 = instead of 15" severity warning; 
		assert(result_high = std_logic_vector(to_unsigned(0,result_high'length))); 
		assert(branch_taken = '0'); 
	
		--MUL 10 and -4
		ALU_CTRL_SEL <=  "00100";
		input1 		<= std_logic_vector(to_signed(10,input1'length));
		input2 		<= std_logic_vector(to_signed(-4,input2'length));
		IR_10_to_6 	<= std_logic_vector(to_unsigned(0,IR_10_to_6'length));
		wait for 40 ns;
    
		assert(result_low = std_logic_vector(to_signed(-40,result_low'length))) report "Error: 25-10 = instead of 15" severity warning; 
		assert(result_high = std_logic_vector(to_signed(0,result_high'length))); 
		assert(branch_taken = '0'); 
		
		--MUL 65536 and 131072
		ALU_CTRL_SEL <=  "00100";
		input1 		<= std_logic_vector(to_unsigned(65536,input1'length));
		input2 		<= std_logic_vector(to_unsigned(131072,input2'length));
		IR_10_to_6 	<= std_logic_vector(to_unsigned(0,IR_10_to_6'length));
		wait for 40 ns;
    
		assert(result_low = std_logic_vector(to_unsigned(0,result_low'length))) report "Error: 25-10 = instead of 15" severity warning; 
		assert(result_high = std_logic_vector(to_unsigned(0,result_high'length))); 
		assert(branch_taken = '0'); 
	 
		--AND 0x0000FFFF and 0xFFFF1234
		ALU_CTRL_SEL <=  "00110";
		input1 		<= std_logic_vector(to_signed(65535,input1'length));
		input2 		<= std_logic_vector(to_signed(16#FFFF1234#,input1'length));
		IR_10_to_6 	<= std_logic_vector(to_unsigned(0,IR_10_to_6'length));
		wait for 40 ns;
    
		assert(result_low = std_logic_vector(to_signed(4660,result_low'length))) report "Error: 25-10 = instead of 15" severity warning; 
		assert(result_high = std_logic_vector(to_signed(0,result_high'length))); 
		assert(branch_taken = '0');
		
		--SRL 0x0000000F by 4
		ALU_CTRL_SEL <=  "01100";
		input1 		<= std_logic_vector(to_unsigned(15,input1'length));
		input2 		<= std_logic_vector(to_unsigned(0,input2'length));
		IR_10_to_6 	<= std_logic_vector(to_unsigned(4,IR_10_to_6'length));
		wait for 40 ns;
    
		assert(result_low = std_logic_vector(to_unsigned(0,result_low'length))) report "Error: 25-10 = instead of 15" severity warning; 
		assert(result_high = std_logic_vector(to_unsigned(0,result_high'length))); 
		assert(branch_taken = '0');
		
		 --SRA 0xF0000008 by 1
		ALU_CTRL_SEL <=  "01110";
		input1 		<= std_logic_vector(to_signed(16#F0000008#,input1'length));
		input2 		<= std_logic_vector(to_unsigned(0,input2'length));
		IR_10_to_6 	<= std_logic_vector(to_unsigned(1,IR_10_to_6'length));
		wait for 40 ns;
    
		assert(result_low = std_logic_vector(to_signed(16#F8000004#,result_low'length))) report "Error: 25-10 = instead of 15" severity warning; 
		assert(result_high = std_logic_vector(to_unsigned(0,result_high'length))); 
		assert(branch_taken = '0');
		
		 --SRA 0x00000008 by 1
		ALU_CTRL_SEL <=  "01110";
		input1 		<= std_logic_vector(to_unsigned(8,input1'length));
		input2 		<= std_logic_vector(to_unsigned(0,input2'length));
		IR_10_to_6 	<= std_logic_vector(to_unsigned(1,IR_10_to_6'length));
		wait for 40 ns;
    
		assert(result_low = std_logic_vector(to_unsigned(4,result_low'length))) report "Error: 25-10 = instead of 15" severity warning; 
		assert(result_high = std_logic_vector(to_unsigned(0,result_high'length))); 
		assert(branch_taken = '0');
		
		--Set on less than using 10 and 15
		ALU_CTRL_SEL <=  "01111";
		input1 		<= std_logic_vector(to_unsigned(10,input1'length));
		input2 		<= std_logic_vector(to_unsigned(15,input2'length));
		IR_10_to_6 	<= std_logic_vector(to_unsigned(0,IR_10_to_6'length));
		wait for 40 ns;
    
		assert(result_low = std_logic_vector(to_unsigned(1,result_low'length))) report "Error: 10 less than 15" severity warning; 
		assert(result_high = std_logic_vector(to_unsigned(0,result_high'length))); 
		assert(branch_taken = '0');
		
		--Set on less than using 15 and 10
		ALU_CTRL_SEL <=  "01111";
		input1 		<= std_logic_vector(to_unsigned(15,input1'length));
		input2 		<= std_logic_vector(to_unsigned(10,input2'length));
		IR_10_to_6 	<= std_logic_vector(to_unsigned(0,IR_10_to_6'length));
		wait for 40 ns;
    
		assert(result_low = std_logic_vector(to_unsigned(0,result_low'length))) report "Error: 10 less than 15" severity warning; 
		assert(result_high = std_logic_vector(to_unsigned(0,result_high'length))); 
		assert(branch_taken = '0');
		
		--Branch Taken output = '0' for 5<=0
		ALU_CTRL_SEL <=  "11001";
		input1 		<= std_logic_vector(to_unsigned(5,input1'length));
		input2 		<= std_logic_vector(to_unsigned(0,input2'length));
		IR_10_to_6 	<= std_logic_vector(to_unsigned(0,IR_10_to_6'length));
		wait for 40 ns;
    
		assert(result_low = std_logic_vector(to_unsigned(0,result_low'length))) report "Error: branch taken 1" severity warning; 
		assert(result_high = std_logic_vector(to_unsigned(0,result_high'length))); 
		assert(branch_taken = '0');
		
		--Branch Taken output = '1' for 5>0
		ALU_CTRL_SEL <=  "11010";
		input1 		<= std_logic_vector(to_unsigned(5,input1'length));
		input2 		<= std_logic_vector(to_unsigned(0,input2'length));
		IR_10_to_6 	<= std_logic_vector(to_unsigned(0,IR_10_to_6'length));
		wait for 40 ns;
    
		assert(result_low = std_logic_vector(to_unsigned(0,result_low'length))) report "Error: branch taken 1" severity warning; 
		assert(result_high = std_logic_vector(to_unsigned(0,result_high'length))); 
		assert(branch_taken = '1');
		
		wait; 
		end process; 
		end TB; 
		
		
		 
	 