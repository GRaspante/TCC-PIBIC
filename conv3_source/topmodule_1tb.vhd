----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.08.2023 13:37:58
-- Design Name: 
-- Module Name: topmodule_1tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity topmodule_1tb is
--  Port ( );
end topmodule_1tb;

architecture Behavioral of topmodule_1tb is
component top_module1 is
    Port (  clk     : in std_logic;
            reset   : in std_logic;
            first_start   : in std_logic;
            rd_out  : out std_logic);
end component;

signal sclk, sreset, sfirst_start, srd_out : std_logic;

begin
uut : top_module1 port map( clk => sclk,
                            reset => sreset,
                            first_start => sfirst_start,
                            rd_out  => srd_out);      
clk: process
        begin
            sclk <= '0';
            wait for 5ns;
            sclk <= '1';
            wait for 5ns;            
        end process;     
        
stimulus: process
        begin
        sreset <= '1';       
        sfirst_start <= '0';
        wait for 25ns;
        sreset <= '0';       
        sfirst_start <= '1';
        wait;
end process;                            



end Behavioral;
