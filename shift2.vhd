library ieee;
use ieee.std_logic_1164.all;

entity shift2 is 
	port( 
			input 	: in std_logic_vector(25 downto 0); 
			output 	: out std_logic_vector(27 downto 0)
	); 
end shift2; 
	
architecture SH2 of shift2 is 
begin 

	output <= input & "00"; 
	
end SH2; 