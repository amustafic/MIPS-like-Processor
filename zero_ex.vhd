library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity zero_ex is 
	generic (WIDTH : positive); 
	
	port( 
		input		: in std_logic_vector(8 downto 0); 
		output	: out std_logic_vector(width-1 downto 0) 
	); 
end zero_ex; 

architecture EXTEND of zero_ex is 
	constant zero : std_logic_vector(22 downto 0) := (others => '0'); 
begin 
	output <= zero & input; 

end EXTEND; 