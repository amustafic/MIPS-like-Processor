library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Reg_file is
    generic ( width : positive); 
	 
	 port( 
		clk 				: in std_logic; 
		rst				: in std_logic; 
		R_Reg1 			: in std_logic_vector(4 downto 0); 
		R_Reg2 			: in std_logic_vector(4 downto 0);
		Wr_Reg			: in std_logic_vector(4 downto 0);
		Wr_Data			: in std_logic_vector(width-1 downto 0);
		JumpAndLink 	: in std_logic;  
		RegWrite			: in std_logic; 
		R_Data1			: out std_logic_vector(width-1 downto 0);  
		R_Data2			: out std_logic_vector(width-1 downto 0)	 
	 ); 
end Reg_file; 

architecture FILES of Reg_file is 

    type reg_array is array(0 to width-1) of std_logic_vector(width-1 downto 0);
    signal regs : reg_array;
begin
    process (clk, rst) is
    begin
        if (rst = '1') then
            for i in regs'range loop
                regs(i) <= (others => '0');
            end loop;
        elsif (rising_edge(clk)) then

            if (RegWrite = '1' and JumpAndLink = '0') then
                regs(to_integer(unsigned(Wr_Reg))) <= Wr_Data;
					 regs(0)	<= (others => '0'); 
            end if;  

				if(JumpAndLink = '1') then
					regs(31) <= Wr_Data;
					regs(0)	<= (others => '0');
				end if; 
        end if;
    end process;

    R_Data1 <= regs(to_integer(unsigned(R_Reg1)));
    R_Data2 <= regs(to_integer(unsigned(R_Reg2)));

end FILES; 