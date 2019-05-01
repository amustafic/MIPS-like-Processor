library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem_tb is 
end mem_tb; 

architecture TB of mem_tb is 

component memory 
	generic ( 
		WIDTH : positive := 32
		);
	port( 
	  clk   		: in std_logic;
	  rst			: in std_logic; 
	  MemWrite	: in std_logic; 
	  MemRead	: in std_logic; 
	  RegB		: in std_logic_vector(width-1 downto 0); 
	  input0 	: in std_logic_vector(width-1 downto 0);
	  input1 	: in std_logic_vector(width-1 downto 0);
	  in0_en 	: in std_logic;  
	  in1_en 	: in std_logic; 
	  addr		: in std_logic_vector(width-1 downto 0); 
	  mem_out	: out std_logic_vector(width-1 downto 0); 
	  OutPort	: out std_logic_vector(width-1 downto 0)
	 ); 
end component; 

	constant WIDTH  : positive:= 32;
	signal clk 			: std_logic := '0'; 
	signal rst 			: std_logic := '0'; 
	signal MemWrite 	: std_logic	:= '0';
	signal MemRead 	: std_logic	:= '0';
	signal RegB 		: std_logic_vector(width-1 downto 0) := (others => '0');
	signal input0 		: std_logic_vector(width-1 downto 0) := (others => '0');
	signal input1 		: std_logic_vector(width-1 downto 0) := (others => '0');
	signal in0_en		: std_logic	:= '0';
	signal in1_en		: std_logic	:= '0';
	signal addr			: std_logic_vector(width-1 downto 0) := (others => '0');
	signal mem_out 	: std_logic_vector(width-1 downto 0);
	signal OutPort		: std_logic_vector(width-1 downto 0);
	
	begin 

	U_MEM : memory 
		generic map(WIDTH => WIDTH) 
		
		port map(
			clk 			=> clk, 
			rst			=> rst,
			MemWrite 	=> MemWrite,
			MemRead 		=> MemRead,
			RegB 			=> RegB,
			input0 		=> input0, 
			input1 		=> input1, 
			in0_en 		=> in0_en, 
			in1_en 		=> in1_en, 
			addr 			=> addr,
			mem_out 		=> mem_out,
			OutPort 		=> OutPort ); 
			
	clk <= not clk after 10 ns;
	
process 
	begin 
		rst <= '1'; 
		wait for 100 ns;

		rst <= '0';  


		RegB 	<= std_logic_vector(to_unsigned(16#0A0A0A0A#,input1'length));
		addr	<= std_logic_vector(to_unsigned(0,input1'length));
		MemWrite <= '1'; 
		MemRead <= '0'; 
		wait for 40 ns;
		--assert(mem_out = std_logic_vector(to_unsigned(16#0A0A0A0A#, mem_out'length))) report "Error"; 
		
		wait for 40 ns; 
		
		RegB 	<= std_logic_vector(to_signed(16#F0F0F0F0#,32));
		addr	<= std_logic_vector(to_unsigned(4,input1'length));
		MemWrite <= '1';
		MemRead <= '0';
		wait for 40 ns;
		
		wait for 40 ns; 
		
		addr	<= std_logic_vector(to_unsigned(0,input1'length));
		MemWrite <= '0'; 
		MemRead <= '1'; 
		wait for 40 ns;
		assert(mem_out = std_logic_vector(to_unsigned(16#0A0A0A0A#, mem_out'length))) report "Error 1"; 
		
		addr	<= std_logic_vector(to_unsigned(1,input1'length));
		MemWrite <= '0'; 
		MemRead <= '1'; 
		wait for 40 ns;
		assert(mem_out = std_logic_vector(to_unsigned(16#0A0A0A0A#, mem_out'length))) report "Error 2"; 
		
		addr	<= std_logic_vector(to_unsigned(4,input1'length));
		MemWrite <= '0'; 
		MemRead <= '1'; 
		wait for 40 ns;
		assert(mem_out = std_logic_vector(to_signed(16#F0F0F0F0#, mem_out'length))) report "Error 3"; 
		
		addr	<= std_logic_vector(to_unsigned(5,input1'length));
		MemWrite <= '0'; 
		MemRead <= '1'; 
		wait for 40 ns;
		assert(mem_out = std_logic_vector(to_signed(16#F0F0F0F0#, mem_out'length))) report "Error 4"; 
		
		RegB 	<= std_logic_vector(to_unsigned(16#00001111#,input1'length));
		addr	<= std_logic_vector(to_unsigned(16#0000FFFC#,input1'length));
		MemWrite <= '1'; 
		MemRead <= '0'; 
		wait for 40 ns;
		assert(mem_out = std_logic_vector(to_signed(16#00001111#, mem_out'length))); 
		assert(OutPort = std_logic_vector(to_signed(16#00001111#, OutPort'length)));
		
		addr	<= std_logic_vector(to_unsigned(16#0000FFF8#,input1'length));
		input0 	<= std_logic_vector(to_unsigned(16#00010000#,input1'length));
		MemWrite <= '0'; 
		MemRead <= '1'; 
		in0_en	<= '1'; 
		wait for 40 ns;
		
		addr	<= std_logic_vector(to_unsigned(16#0000FFFC#,input1'length));
		input1 	<= std_logic_vector(to_unsigned(16#00000001#,input1'length));
		MemWrite <= '0'; 
		MemRead <= '1'; 
		in1_en	<= '1';
		wait for 40 ns;
		
wait; 
end process; 
end TB; 
			
	
