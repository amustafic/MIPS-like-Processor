library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sign_extend is 
	generic( 
		width : positive); 
		
	port( 
		input 	: in std_logic_vector((width-1)/2 downto 0);
		enable 	: in std_logic; 
		output 	: out std_logic_vector(width-1 downto 0) ); 

end sign_extend; 

architecture EXTEND of sign_extend is 
begin 

	process(enable, input) 
		variable temp : std_logic_vector((width-1)/2 downto 0); 
	begin
		if (enable = '1') then 
			if(input((width-1)/2) = '1') then
				temp 		:= (others => '1'); 
				output 	<= temp & input; 
			else 
				temp 		:= (others => '0'); 
				output 	<= temp & input; 
			end if; 
			
		else 
			temp 		:= (others => '0'); 
			output 	<= temp & input; 
			
		end if; 
	end process; 
end EXTEND; 