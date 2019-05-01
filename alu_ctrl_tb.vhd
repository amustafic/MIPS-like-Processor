library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_ctrl_tb is 
end alu_ctrl_tb; 

architecture TB of alu_ctrl_tb is

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


component ALU_ctrl 
	generic ( 
		WIDTH : positive := 32
	);
	port(
		ALUOp			: in std_logic_vector(4 downto 0); 
		IR_5_to_0	: in std_logic_vector(5 downto 0);
		HI_en			: out std_logic; 
		LO_en			: out std_logic; 
		ALU_LO_HI	: out std_logic_vector(1 downto 0); 
		OPSelect		: out std_logic_vector(4 downto 0) ); 
end component; 

component reg 
	generic ( 
		WIDTH : positive := 32
	); 
	port (
    clk    : in  std_logic;
    rst    : in  std_logic;
    load   : in  std_logic;
    input  : in  std_logic_vector(width-1 downto 0);
    output : out std_logic_vector(width-1 downto 0));
end component;

component MUX3x1 
	generic( 
		WIDTH : positive := 32
	); 
	port( 
		in1 			: in std_logic_vector(width-1 downto 0); 
		in2			: in std_logic_vector(width-1 downto 0);
		in3 			: in std_logic_vector(width-1 downto 0);
		sel   		: in std_logic_vector(1 downto 0); 
		output 		: out std_logic_vector(width-1 downto 0)
		);
end component;
		
		constant WIDTH  : positive:= 32;
		signal clk 				: std_logic := '0'; 
		signal rst 				: std_logic := '0'; 
		signal input1 			: std_logic_vector(WIDTH-1 downto 0) := (others => '0'); 
		signal input2 			: std_logic_vector(WIDTH-1 downto 0) := (others => '0'); 
		signal alu_sel 		: std_logic_vector(4 downto 0);
		signal IR_10_to_6		: std_logic_vector(4 downto 0) 		 := (others => '0');	
		signal branch_taken	: std_logic; 
		signal result_low		: std_logic_vector(WIDTH-1 downto 0); 
		signal result_high   : std_logic_vector(WIDTH-1 downto 0); 
		signal ALUOp			: std_logic_vector(4 downto 0);
		signal IR_5_to_0		: std_logic_vector(5 downto 0);
		signal HI_en 			: std_logic; 
		signal LO_en 			: std_logic; 
		signal ALU_LO_HI		: std_logic_vector(1 downto 0); 
		signal mux0				: std_logic_vector(WIDTH-1 downto 0); 
		signal mux1 			: std_logic_vector(WIDTH-1 downto 0);
		signal mux2				: std_logic_vector(WIDTH-1 downto 0); 
		signal ALU_OUT			: std_logic_vector(WIDTH-1 downto 0); 
 	
begin 

	U_ALU	: alu 
		generic map(WIDTH => WIDTH) 
		
		port map( 
			input1 			=> input1, 
			input2 			=> input2, 
			ALU_CTRL_SEL	=> alu_sel,
			IR_10_to_6		=> IR_10_to_6,
			branch_taken	=> branch_taken,
			result_low		=> result_low,
			result_high		=> result_high ); 
			
	U_ALU_ctrl	: ALU_ctrl 
		generic map(WIDTH => WIDTH) 
		
		port map( 
			ALUOp 		=> ALUOp,
			IR_5_to_0 	=> IR_5_to_0,
			HI_en 		=> HI_en,
			LO_en 		=> LO_en, 	
			ALU_LO_HI 	=> ALU_LO_HI, 
			OPSelect		=> alu_sel ); 
			
	U_REG_ALU_out	: reg 
		generic map(WIDTH => WIDTH) 
		
		port map( 
			clk 		=> clk, 
			rst 		=> rst, 
			load 		=> '1', 
			input 	=> result_low,
			output 	=> mux0 ); 
			
	U_REG_LO	: reg 
		generic map(WIDTH => WIDTH) 
		
		port map( 
			clk 		=> clk, 
			rst 		=> rst, 
			load 		=> LO_en, 
			input 	=> result_low,
			output 	=> mux1 );
	
	U_REG_HI	: reg 
		generic map(WIDTH => WIDTH) 
		
		port map( 
			clk 		=> clk, 
			rst 		=> rst, 
			load 		=> LO_en, 
			input 	=> result_high,
			output 	=> mux2 );
			
	U_MUX7	: MUX3x1
		generic map(WIDTH => WIDTH) 
		
		port map( 
			in1 		=> mux0, 
			in2 		=> mux1,
			in3 		=> mux2, 
			sel 		=> ALU_LO_HI, 
			output 	=> ALU_OUT ); 
	
		clk <= not clk after 10 ns;
		
	process 
	begin 
	
		rst <= '1'; 
		wait for 100 ns;

		rst <= '0'; 
		
		--Add 10 and 15 
		ALUOp 		<= std_logic_vector(to_unsigned(0,ALUOp'length));
		IR_5_to_0	<= std_logic_vector(to_unsigned(33,IR_5_to_0'length));
		input1 		<= std_logic_vector(to_unsigned(10,input1'length));
		input2 		<= std_logic_vector(to_unsigned(15,input2'length));
		IR_10_to_6 	<= std_logic_vector(to_unsigned(0,IR_10_to_6'length));
		wait for 40 ns;
    
		assert(result_low = std_logic_vector(to_unsigned(25,result_low'length))) report "Error: 10+15 = instead of 25" severity warning; 
		assert(result_high = std_logic_vector(to_unsigned(0,result_high'length))); 
		assert(branch_taken = '0'); 
		
		--OR 5 and 8
		ALUOp 		<= std_logic_vector(to_unsigned(4,ALUOp'length));
		IR_5_to_0	<= std_logic_vector(to_unsigned(0,IR_5_to_0'length));
		input1 		<= std_logic_vector(to_unsigned(5,input1'length));
		input2 		<= std_logic_vector(to_unsigned(8,input2'length));
		IR_10_to_6 	<= std_logic_vector(to_unsigned(0,IR_10_to_6'length));
		wait for 40 ns;
		
		assert(result_low = std_logic_vector(to_unsigned(13,result_low'length))) report "Error: ORi" severity warning; 
		assert(result_high = std_logic_vector(to_unsigned(0,result_high'length))); 
		assert(branch_taken = '0'); 
		
		wait; 
	end process; 
end TB;
		
		
		