
library ieee;
use ieee.std_logic_1164.all;

entity top_level is
	generic ( 
		WIDTH : positive := 32);
		
    port (
		  clk 		: in std_logic; 
		  rst			: in std_logic; 
        switches  : in  std_logic_vector(9 downto 0);
        buttons  	: in  std_logic_vector(1 downto 0);
		  LEDs		: out std_logic_vector(width-1 downto 0) 
--        led0    : out std_logic_vector(6 downto 0);
--        led0_dp : out std_logic;
--        led1    : out std_logic_vector(6 downto 0);
--        led1_dp : out std_logic;
--        led2    : out std_logic_vector(6 downto 0);
--        led2_dp : out std_logic;
--        led3    : out std_logic_vector(6 downto 0);
--        led3_dp : out std_logic;
--        led4    : out std_logic_vector(6 downto 0);
--        led4_dp : out std_logic;
--        led5    : out std_logic_vector(6 downto 0);
--        led5_dp : out std_logic
        );
end top_level;

architecture STR of top_level is
--
--    component decoder7seg
--        port (
--            input  : in  std_logic_vector(3 downto 0);
--            output : out std_logic_vector(6 downto 0));
--    end component;

	component datapath 
		generic ( 
			WIDTH : positive := 32); 
		port ( 
			clk 				: in std_logic; 
			rst				: in std_logic; 
			JumpAndLink		: in std_logic; 
			IsSigned			: in std_logic; 
			PCSource			: in std_logic_vector(1 downto 0); 
			ALUOp				: in std_logic_vector(4 downto 0); 
			ALUSrcB			: in std_logic_vector(1 downto 0); 
			ALUSrcA			: in std_logic; 
			RegWrite			: in std_logic; 
			RegDst			: in std_logic_vector(1 downto 0);  
			IRWrite			: in std_logic; 
			MemToReg			: in std_logic; 
			MemWrite			: in std_logic; 
			MemRead			: in std_logic; 
			IorD				: in std_logic;
			PC_en				: in std_logic; 
			Buttons			: in std_logic_vector(1 downto 0); 
			Switches			: in std_logic_vector(9 downto 0);
			branch_taken	: out std_logic; 
			LEDs				: out std_logic_vector(WIDTH-1 downto 0); 
			IR31_26			: out std_logic_vector(5 downto 0);
			IR20_16			: out std_logic_vector(4 downto 0);
			IR25_21			: out std_logic_vector(4 downto 0); 
			IR15_0			: out std_logic_vector(15 downto 0)
			);
	end component; 
	
	component ctrl 
		generic ( 
			WIDTH : positive := 32); 
		port( 
			IR31_26 		: in std_logic_vector(5 downto 0);
			IR20_16 		: in std_logic_vector(4 downto 0); 
			IR25_21		: in std_logic_vector(4 downto 0); 
			IR15_0		: in std_logic_vector(15 downto 0); 
			JumpandLink : out std_logic; 
			IsSigned 	: out std_logic; 
			PCSource 	: out std_logic_vector(1 downto 0);
			ALUOp 		: out std_logic_vector(4 downto 0); 
			ALUSrcB 		: out std_logic_vector(1 downto 0); 
			ALUSrcA		: out std_logic; 
			RegWrite 	: out std_logic; 
			RegDst 		: out std_logic_vector(1 downto 0); 
			PCWriteCond : out std_logic; 
			PCWrite 		: out std_logic; 
			IorD 			: out std_logic; 
			MemRead 		: out std_logic; 
			MemWrite 	: out std_logic; 
			MemToReg 	: out std_logic; 
			IRWrite		: out std_logic; 
			clk			: in std_logic; 
			rst			: in std_logic 
			); 
	end component; 
		
		signal JumpAndLink 		: std_logic; 
		signal IsSigned 			: std_logic; 
		signal PCSource 			: std_logic_vector(1 downto 0); 
		signal ALUOp 				: std_logic_vector(4 downto 0);
		signal ALUSrcA				: std_logic; 
		signal ALUSrcB				: std_logic_vector(1 downto 0);
		signal RegWrite 			: std_logic; 
		signal RegDst 				: std_logic_vector(1 downto 0); 
		signal IRWrite 			: std_logic; 
		signal MemToReg			: std_logic; 
		signal MemWrite 			: std_logic; 
		signal MemRead				: std_logic; 
		signal IorD					: std_logic; 
		signal PC_en 				: std_logic; 
		signal branch_taken		: std_logic; 
		signal IR31_26				: std_logic_vector(5 downto 0); 
		signal IR20_16				: std_logic_vector(4 downto 0);
		signal IR25_21				: std_logic_vector(4 downto 0);
		signal IR15_0				: std_logic_vector(15 downto 0); 
		signal PCWriteCond		: std_logic; 
		signal PCWrite 			: std_logic;  
	
	begin 
	
--	U_LED5	: decoder7seg port map (
--        input  => LEDs(23 downto 20),
--        output => led5);
--
--    U_LED4 : decoder7seg port map (
--        input  => LEDs(19 downto 16),
--        output => led4);
--
--    -- all other LEDs should display 0
--    U_LED3 : decoder7seg port map (
--        input  => LEDs(15 downto 12),
--        output => led3);
--
--    U_LED2 : decoder7seg port map (
--        input  => LEDs(11 downto 8),
--        output => led2);
--    
--    U_LED1 : decoder7seg port map (
--        input  => LEDs(7 downto 4),
--        output => led1);
--
--    U_LED0 : decoder7seg port map (
--        input  => LEDs(3 downto 0),
--        output => led0);
		  
	U_DATAPATH : datapath 
		generic map( 
			WIDTH => 32) 
		port map( 
			clk 				=> clk,  
			rst				=> rst,  
			JumpAndLink		=> JumpAndLink, 
			IsSigned			=> IsSigned, 
			PCSource			=> PCSource, 
			ALUOp				=> ALUOp,  
			ALUSrcB			=> ALUSrcB,  
			ALUSrcA			=> ALUSrcA, 
			RegWrite			=> RegWrite,  
			RegDst			=> RegDst,   
			IRWrite			=> IRWrite, 
			MemToReg			=> MemToReg, 
			MemWrite			=> MemWrite, 
			MemRead			=> MemRead, 
			IorD				=> IorD, 
			PC_en				=> PC_en, 
			Buttons			=> buttons, 
			Switches			=> switches, 
			LEDs				=> LEDs, 
			branch_taken	=> branch_taken,
			IR31_26			=> IR31_26,
			IR20_16			=> IR20_16,
			IR25_21			=> IR25_21,
			IR15_0			=> IR15_0
		);
		
		U_CTRL : ctrl 
			generic map( 
				WIDTH => 32) 
			port map( 
				IR31_26 		=> IR31_26,
				IR20_16 		=> IR20_16,
				IR25_21		=> IR25_21,	
				IR15_0		=> IR15_0,
				JumpandLink => JumpandLink,
				IsSigned 	=> IsSigned,
				PCSource 	=> PCSource,
				ALUOp 		=> ALUOp,
				ALUSrcB 		=> ALUSrcB,
				ALUSrcA		=> ALUSrcA,
				RegWrite 	=> RegWrite,
				RegDst 		=> RegDst,
				PCWriteCond => PCWriteCond,
				PCWrite 		=> PCWrite,
				IorD 			=> IorD,
				MemRead 		=> MemRead,
				MemWrite 	=> MemWrite,
				MemToReg 	=> MemToReg,
				IRWrite		=> IRWrite,
				clk 			=> clk, 
				rst			=> rst
			); 
		
		PC_en  		<= PCWrite or (PCWriteCond and branch_taken); 
		
--		led5_dp 		<= '1'; 
--		led4_dp		<= '1'; 
--		led3_dp 		<= not in1_en;
--		led2_dp 		<= not in0_en;
--		led1_dp 		<= not button(0);
--		led0_dp 		<= not button(1);
	 
end STR; 
				