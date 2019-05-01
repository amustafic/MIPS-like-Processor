
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory is
    generic (
		  width		 : positive	:= 32
        );
    port (
        clk   		: in std_logic;
		  rst			: in std_logic; 		
		  MemWrite	: in std_logic; 
		  MemRead	: in std_logic; 
		  RegB		: in std_logic_vector(width-1 downto 0); 
		  input0 	: in std_logic_vector(width-1 downto 0);
		  input1 	: in std_logic_vector(width-1 downto 0);
		  buttons 	: in std_logic; 
		  switches 	: in std_logic; 
		  addr		: in std_logic_vector(width-1 downto 0); 
		  mem_out	: out std_logic_vector(width-1 downto 0); 
		  OutPort	: out std_logic_vector(width-1 downto 0)
        );	
end memory;

architecture MEM of memory is 
	signal out_en 	: std_logic; 
	signal RAM_out : std_logic_vector(width-1 downto 0);
	signal in0_reg	: std_logic_vector(width-1 downto 0);
	signal in1_reg	: std_logic_vector(width-1 downto 0); 
	signal mux_sel : std_logic_vector(1 downto 0); 
	signal wr_en	: std_logic; 
	signal input0_en : std_logic; 
	signal input1_en : std_logic;
	
	begin 

	U_MUX : entity work.mux3x1 
		generic map( width => width) 
		
		port map( 
			in1 		=> RAM_out, 
			in2 		=> in0_reg,
			in3 		=> in1_reg,
			sel 		=> mux_sel,
			output 	=> mem_out ); 
			
	U_REG_0	: entity work.reg
		generic map( width => width) 
		
		port map( 
			clk 		=> clk, 
			rst 		=> '0',			--this reset is different
			load 		=> input0_en, 
			input 	=> input0,
			output 	=> in0_reg ); 
			
			
	U_REG_1	: entity work.reg
		generic map( width => width) 
		
		port map( 
			clk 		=> clk, 
			rst 		=> '0',			--this reset is different
			load 		=> input1_en, 
			input 	=> input1,
			output 	=> in1_reg );
			
	U_REG_2	: entity work.reg
		generic map( width => width) 
		
		port map( 
			clk 		=> clk, 
			rst 		=> rst,			--this reset is different
			load 		=> out_en, 
			input 	=> RegB,
			output 	=> OutPort ); 
			
	U_SRAM	: entity work.SRAM  
		generic map( width => width) 
		port map( 
			clock 		=> clk, 
			wren 			=>	wr_en,
			address 		=> addr(9 downto 2),
			data 			=> RegB,
			q				=> RAM_out ); 
			
	U_CTRL0	: entity work.ctrl_ram 
		generic map( width => width)
		
		port map( 
			memRead		=> MemRead, 
			memWrite 	=> MemWrite,
			addr 			=> addr,
			wr_en 		=> wr_en,
			MUX_sel		=> mux_sel,
			out_en		=> out_en,
			input0_en  	=> input0_en, 
			input1_en   => input1_en, 
			button		=> buttons, 
			switch      => switches );  
			
end MEM; 
