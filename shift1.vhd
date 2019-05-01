library ieee;
use ieee.std_logic_1164.all;

entity shift1 is 
	generic( 
		width : positive); 
	port( 
			input 	: in std_logic_vector(width-1 downto 0); 
			output 	: out std_logic_vector(width-1 downto 0)
	); 
end shift1; 
	
architecture SH1 of shift1 is 
begin 

	output <= input(width-3 downto 0) & "00"; 
	
end SH1; 