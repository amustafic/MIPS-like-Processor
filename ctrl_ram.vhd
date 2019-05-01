library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ctrl_ram is 

generic (
WIDTH : positive := 32);

	 
	 port( 
		button		: in std_logic; 
		switch		: in std_logic; 
		memRead 		: in std_logic; 
		memWrite 	: in std_logic;
		addr			: in std_logic_vector(WIDTH-1 downto 0); 
		wr_en 		: out std_logic; 
		MUX_sel		: out std_logic_vector(1 downto 0);
		out_en		: out std_logic; 
		input0_en 	: out std_logic; 
		input1_en   : out std_logic );
		
end ctrl_ram; 
		
architecture CTRL of ctrl_ram is 

begin 
	process(memRead, memWrite, addr, button, switch)
	begin
		out_en <= '0'; 
--		MUX_sel <= "00";
--		input1_en <= '0';
--		input0_en <= '0';
--		wr_en <= '0';
		
		if (button = '1' and switch = '0') then
		
			input0_en <= '1'; 
			input1_en <= '0'; 
			
		elsif (button = '1' and switch = '1') then
			
			input0_en <= '0'; 
			input1_en <= '1'; 
		
		else 
		
			input0_en <= '0'; 
			input1_en <= '0';
		
		end if; 	
		
		if(memRead = '1' and memWrite = '0') then 
			
			if(addr(11 downto 0) = "111111111000") then 
				--output in0
				MUX_sel <= "01";
				wr_en <= '0';  
				out_en <= '0';
				
			elsif(addr(11 downto 0) = "111111111100") then
				--output in1 
				MUX_sel <= "10";
				wr_en <= '0';
				out_en <= '0';
			
			else
				--output ram 
				MUX_sel <= "00";
				wr_en <= '0';
				out_en <= '0';
				 
				
			end if; 
		
		elsif(memWrite = '1') then 
			if(addr(11 downto 0) = "111111111100") then
				out_en <= '1';
			else 
				wr_en <= '1';
			end if; 
			
		else 
			wr_en <= '0';
			out_en <= '0';	
			
		end if; 	
		end process; 
end CTRL; 