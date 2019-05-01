library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IR is
    generic ( width : positive); 
	 
	 port( 
		 clk			: in std_logic; 
		 rst			: in std_logic; 
		 input 		: in std_logic_vector(width-1 downto 0);
		 IRWrite 	: in std_logic; 
		 IR25_0 		: out std_logic_vector(25 downto 0); 
		 IR31_26 	: out std_logic_vector(5 downto 0); 
		 IR25_21		: out std_logic_vector(4 downto 0); 
		 IR20_16		: out std_logic_vector(4 downto 0); 
		 IR15_11		: out std_logic_vector(4 downto 0); 
		 IR15_0		: out std_logic_vector(15 downto 0) ); 
		 
 end IR;  
 
 architecture REG of IR is 
 begin 
 
	U_IR25_0 : entity work.reg 
			generic map (width => 26) 
			
			port map(
				clk 		=> clk,		
				rst 		=> rst, 		
				load 		=> IRWrite,			
				input 	=> input(25 downto 0),
				output 	=> IR25_0 );
				
	U_IR31_26 : entity work.reg 
			generic map (width => 6) 
			
			port map(
				clk 		=> clk,		
				rst 		=> rst, 		
				load 		=> IRWrite,			
				input 	=> input(31 downto 26),
				output 	=> IR31_26 );
				
	U_IR25_21 : entity work.reg 
			generic map (width => 5) 
			
			port map(
				clk 		=> clk,		
				rst 		=> rst, 		
				load 		=> IRWrite,			
				input 	=> input(25 downto 21),
				output 	=> IR25_21 );
				
	U_IR20_16 : entity work.reg 
			generic map (width => 5) 
			
			port map(
				clk 		=> clk,		
				rst 		=> rst, 		
				load 		=> IRWrite,			
				input 	=> input(20 downto 16),
				output 	=> IR20_16 );
				
	U_IR15_11 : entity work.reg 
			generic map (width => 5) 
			
			port map(
				clk 		=> clk,		
				rst 		=> rst, 		
				load 		=> IRWrite,			
				input 	=> input(15 downto 11),
				output 	=> IR15_11 );
				
	U_IR15_0 : entity work.reg 
			generic map (width => 16) 
			
			port map(
				clk 		=> clk,		
				rst 		=> rst, 		
				load 		=> IRWrite,			
				input 	=> input(15 downto 0),
				output 	=> IR15_0 );
				
				
--	process(IRWrite) 
--	begin 
--		if (IRWrite = '1') then 
--			IR25_0 	<= input(25 downto 0); 
--			IR31_26 	<= input(31 downto 26); 
--			IR25_21	<= input(25 downto 21); 
--			IR20_16	<= input(20 downto 16); 
--			IR15_11	<= input(15 downto 11); 
--			IR15_0	<= input(15 downto 0); 
--	end if; 
--	end process; 
 end REG;
		 