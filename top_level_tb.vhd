library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level_tb is 
	generic ( 
		WIDTH : positive := 32);
end top_level_tb; 

architecture TB of top_level_tb is 

	component top_level 
		generic ( WIDTH : positive := 32
		);
	port(
		 rst 			: in std_logic; 
		 clk 			: in std_logic; 
		 switches  	: in  std_logic_vector(9 downto 0);
		 buttons  	: in  std_logic_vector(1 downto 0);
		 LEDs			: out std_logic_vector(width-1 downto 0) 
		); 
	end component; 
		signal rst 		 : std_logic	:= '0';
		signal clk 		 : std_logic	:= '0'; 
		signal switches	 : std_logic_vector(9 downto 0)	:= "0000000000"; 
		signal buttons   : std_logic_vector(1 downto 0)	:= "00"; 
		signal LEDs		 : std_logic_vector(width-1 downto 0); 
begin 

	U_TL : top_level 
		generic map(WIDTH => WIDTH) 
		
		port map( 
			rst 		=> rst, 
			clk 		=> clk,
			switches	=> switches,
			buttons	=> buttons, 
			LEDs		=> LEDs
			); 
	clk <= not clk after 10 ns;
process 
		begin 
		
	rst <= '1'; 
	wait for 100 ns;

	rst <= '0';  	
	switches	 <= "0000000100";
	buttons	<= "01"; 
	
	wait for 400 ns;	--400ns
	
	switches <= "1000001010";
	buttons	<= "01";
	
	wait for 400 ns;	--400ns
	
	rst <= '1'; 
	wait for 100 ns;
	rst <= '0';
	
	wait for 600 ns;	--400ns 
	
	switches <= "1000001000";
	buttons	<= "01";
	
	wait for 1000 ns;	--500ns
	
	switches <= "1000000101";
	buttons	<= "01";
	
	wait for 1000 ns;
	
	switches <= "1000000100";
	buttons	<= "01";
	
	
wait; 
end process; 	
end TB; 
