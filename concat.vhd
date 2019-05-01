library ieee;
use ieee.std_logic_1164.all;

entity concat is 
	generic( 
		width : positive); 
		
	port( 
		in1 		: in std_logic_vector(27 downto 0); 
		in2 		: in std_logic_vector(3 downto 0);
		output	: out std_logic_vector(width-1 downto 0)
	);
end concat; 

architecture CON of concat is 
begin 
	process(in1, in2) 
	begin
		output <= in2 & in1;
	end process; 	
end CON; 
		