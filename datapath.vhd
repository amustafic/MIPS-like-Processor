library ieee;
use ieee.std_logic_1164.all;

entity datapath is 
	generic ( 
		WIDTH : positive := 32); 
	port( 
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
		--PC_IN				: in std_logic_vector(width-1 downto 0); 
		Buttons			: in std_logic_vector(1 downto 0); 
		Switches			: in std_logic_vector(9 downto 0); 
		LEDs				: out std_logic_vector(WIDTH-1 downto 0); 
		--MUX_out			: out std_logic_vector(WIDTH-1 downto 0);
		branch_taken	: out std_logic;
		IR31_26			: out std_logic_vector(5 downto 0);
		IR20_16			: out std_logic_vector(4 downto 0);
		IR25_21			: out std_logic_vector(4 downto 0);
		IR15_0			: out std_logic_vector(15 downto 0)
		);
end datapath; 

architecture PATH of datapath is 
	signal SRAM_Input					: std_logic_vector(WIDTH-1 downto 0); 
	signal PC_out						: std_logic_vector(WIDTH-1 downto 0);
	signal ALU_OUT						: std_logic_vector(WIDTH-1 downto 0);
	signal IR25_0						: std_logic_vector(25 downto 0); 
	signal IR_25_21					: std_logic_vector(4 downto 0);
	signal IR_20_16					: std_logic_vector(4 downto 0);
	signal IR15_11						: std_logic_vector(4 downto 0);
	signal IR_15_0						: std_logic_vector(15 downto 0); 
	signal MUX7_out					: std_logic_vector(WIDTH-1 downto 0);
	signal mem_data_reg				: std_logic_vector(WIDTH-1 downto 0);
	signal Write_data					: std_logic_vector(width-1 downto 0);
	signal RegA_out					: std_logic_vector(WIDTH-1 downto 0); 
	signal input1						: std_logic_vector(WIDTH-1 downto 0); 
	signal RegB_out					: std_logic_vector(WIDTH-1 downto 0); 
	signal shift_left_out			: std_logic_vector(WIDTH-1 downto 0);
	signal input2						: std_logic_vector(WIDTH-1 downto 0); 	
	signal Result_low					: std_logic_vector(WIDTH-1 downto 0);
	signal Concat_out					: std_logic_vector(WIDTH-1 downto 0); 
	signal ALU_LO_HI					: std_logic_vector(1 downto 0); 
	signal Reg_Lo_Out					: std_logic_vector(WIDTH-1 downto 0); 
	signal Reg_Hi_Out					: std_logic_vector(WIDTH-1 downto 0); 
	signal Read_data_1				: std_logic_vector(WIDTH-1 downto 0);
	signal Read_data_2				: std_logic_vector(WIDTH-1 downto 0);
	signal Result_hi					: std_logic_vector(WIDTH-1 downto 0); 
	signal HI_en 						: std_logic; 
	signal LO_en						: std_logic; 
	signal OPSelect					: std_logic_vector(4 downto 0);
	signal MemOut						: std_logic_vector(WIDTH-1 downto 0); 
	signal shift_out					: std_logic_vector(27 downto 0); 
	signal Write_Reg					: std_logic_vector(4 downto 0); 
	--signal PC_Source					: std_logic_vector(1 downto 0); 
	signal sign_extend				: std_logic_vector(WIDTH-1 downto 0);
	signal IR_31_26					: std_logic_vector(5 downto 0);
	signal inputs						: std_logic_vector(width-1 downto 0); 
	signal MUX_out						: std_logic_vector(WIDTH-1 downto 0);

begin 
		U_PC 	: entity work.reg 
			generic map (width => width) 
			
			port map(
				clk 		=> clk,		
				rst 		=> rst, 		
				load 		=> PC_en,			
				input 	=> MUX_out,
				output 	=> PC_out);
				
		U_MUX_1 : entity work.mux2x1 
			generic map (width => width) 
			
			port map( 
				in1 => PC_out,
				in2 => ALU_OUT, 
				sel => IorD,
				output => SRAM_Input); 
				
		U_MEMORY	: entity work.memory				 
			generic map (width => width)
			
			port map( 
				clk			=> clk, 
				rst			=> rst,
				MemWrite		=> MemWrite, 
				MemRead		=> MemRead,
				addr			=> SRAM_Input,
				buttons		=> Buttons(0), 
				switches		=> switches(9), 
				input0		=> inputs,
				input1		=> inputs,
				OutPort		=> LEDs, 
				RegB			=> RegB_out, 
				mem_out		=> MemOut
			); 
			
		U_IR	: entity work.IR 			 
			generic map (width => width)
			
			port map( 
				clk 	   => clk, 
				rst		=> rst, 
				input 	=> MemOut,
				IRWrite 	=> IRWrite,
				IR25_0	=> IR25_0,
				IR31_26	=> IR_31_26,
				IR25_21	=> IR_25_21,
				IR20_16	=> IR_20_16,
				IR15_11	=> IR15_11,
				IR15_0	=> IR_15_0 ); 
				
		U_MEM_REG	: entity work.reg 
			generic map(width => width) 
			
			port map(
				clk 		=> clk,		
				rst 		=> rst, 		
				load 		=> '1',			
				input 	=> MemOut,
				output 	=> mem_data_reg ); 
				
		U_MUX_2 : entity work.mux3x1 
			generic map (width => 5) 
			
			port map(
				in1 		=> IR_31_26(5 downto 1),
				in2 		=> IR_20_16,
				in3 		=> IR15_11, 
				sel 		=> RegDst,
				output 	=> Write_Reg);
			
		U_MUX_3 : entity work.mux2x1 
			generic map (width => width) 
			
			port map( 
				in1 => MUX7_out,
				in2 => mem_data_reg, 
				sel => MemToReg,
				output => Write_data);
			
		U_REG_FILE	: entity work.Reg_file 
			generic map(width => width) 
			
			port map( 
				clk 				=> clk, 
				rst				=> rst,
				R_Reg1			=> IR_25_21,
				R_Reg2			=> IR_20_16,
				Wr_Reg			=> Write_Reg,
				Wr_Data			=> Write_data,
				JumpAndLink		=> JumpAndLink,
				RegWrite			=> RegWrite,
				R_Data1			=> Read_data_1,
				R_Data2			=> Read_data_2 ); 
			
				
		U_SIGN_EXTEND	: entity work.sign_extend 
			generic map(width => width) 
			
			port map( 
				input 	=> IR_15_0,
				enable 	=> IsSigned,
				output 	=> sign_extend ); 	
				
				
		U_SHIFT_1 : entity work.shift1 
			generic map (width => width)
			
			port map( 
				input 	=> sign_extend, 
				output 	=>	shift_left_out
			); 
				
			
		U_REG_A	: entity work.reg 
			generic map (width => width)
			
			port map(
				clk 		=> clk,		
				rst 		=> rst, 		
				load 		=> '1',			
				input 	=> Read_data_1,
				output 	=> RegA_out); 
			
		U_REG_B	: entity work.reg 
			generic map (width => width)
			
			port map(
				clk 		=> clk,		
				rst 		=> rst, 		
				load 		=> '1',
				input 	=> Read_data_2,
				output 	=> RegB_out); 	
				
		U_MUX_4 : entity work.mux2x1 
			generic map (width => width) 
			
			port map( 
				in1 => PC_out,
				in2 => RegA_out, 
				sel => ALUSrcA,
				output => input1);
				
			
		U_MUX_5 : entity work.mux4x1 
			generic map (width => width) 
			
			port map( 
				in1 => RegB_out,
				in2 => x"00000004", 
				in3 => sign_extend,
				in4 => shift_left_out,
				sel => ALUSrcB,
				output => input2);
				
		U_ALU	: entity work.alu 
			generic map (width => width)
			
			port map( 
				input1 			=> input1, 
				input2 			=> input2, 
				ALU_CTRL_SEL 	=> OPSelect, 
				IR_10_to_6 		=> IR_15_0(10 downto 6), 
				branch_taken	=> branch_taken,
				result_low		=> Result_low,
				result_high		=> Result_hi
			);
			
		U_ALU_CTRL	: entity work.ALU_ctrl 
			generic map (width => width) 
			
			port map( 
				clk			=> clk, 
				rst  			=> rst, 
				ALUOp 		=> ALUOp, 
				IR_5_to_0	=> IR_15_0(5 downto 0),
				HI_en			=> HI_en, 
				LO_en			=> LO_en, 
				ALU_LO_HI	=> ALU_LO_HI,
				OPSelect		=> OPSelect ); 
			
		U_MUX_6 : entity work.mux3x1 
			generic map (width => width) 
			
			port map( 
				in1 => Result_low,
				in2 => ALU_OUT, 
				in3 => Concat_out,
				sel => PCSource,
				output => MUX_out);	
				
		U_MUX_7 : entity work.mux3x1 
			generic map (width => width) 
			
			port map( 
				in1 => ALU_OUT,
				in2 => Reg_Lo_Out, 
				in3 => Reg_Hi_Out,
				sel => ALU_LO_HI,
				output => MUX7_out);	
				
				
		U_REG_ALU_OUT	: entity work.reg 
			generic map (width => width)
			
			port map(
				clk 		=> clk,		
				rst 		=> rst, 		
				load 		=> '1',
				input 	=> Result_low,
				output 	=> ALU_OUT); 
				
		U_REG_LO	: entity work.reg 
			generic map (width => width)
			
			port map(
				clk 		=> clk,		
				rst 		=> rst, 		
				load 		=> LO_en,			
				input 	=> Result_low,
				output 	=> Reg_Lo_Out); 
				
		U_REG_HI	: entity work.reg 
			generic map (width => width)
			
			port map(
				clk 		=> clk,		
				rst 		=> rst, 		
				load 		=> HI_en,			
				input 	=> Result_hi,
				output 	=> Reg_Hi_Out); 
		
		U_CONCAT	: entity work.concat 
			generic map( width => width) 
			
			port map( 
				in1 		=> shift_out,
				in2 		=> PC_out(31 downto 28),
				output	=>	Concat_out ); 
	
			
		U_SHIFT_2 : entity work.shift2 
			
			port map( 
				input 	=> IR25_0, 
				output 	=>	shift_out
			); 
			
		U_EXTEND : entity work.zero_ex 
			generic map( width => width) 
			
			port map( 
				input  	=> switches(8 downto 0),
				output 	=> inputs
			); 
			
	
		IR31_26 	<= IR_31_26; 
		IR25_21	<= IR_25_21;
		IR20_16	<= IR_20_16;
		IR15_0	<= IR_15_0; 
		--MUX_out		<= PC_IN; 
		--PC_IN <= MUX_out; 
				
end PATH; 