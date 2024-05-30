 ----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.08.2023 23:08:49
-- Design Name: 
-- Module Name: loop_interno_tb - Behavioral
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
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
use work.fpupack.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cnn_conv3_tb is
--  Port ( );
end cnn_conv3_tb;

architecture Behavioral of cnn_conv3_tb is

component cnn_conv3 
Port (  reset : in STD_LOGIC;
        clk : in STD_LOGIC;
        start : in std_logic;
        sample_adjusted0 : in std_logic_vector (FP_WIDTH-1 downto 0);
        sample_adjusted1 : in std_logic_vector (FP_WIDTH-1 downto 0);
        sample_adjusted2 : in std_logic_vector (FP_WIDTH-1 downto 0);            
        filter0 : in std_logic_vector (FP_WIDTH-1 downto 0);
        filter1 : in std_logic_vector (FP_WIDTH-1 downto 0);
        filter2 : in std_logic_vector (FP_WIDTH-1 downto 0);        
        ready : out std_logic;
        output : out std_logic_vector (FP_WIDTH-1 downto 0));
end component;

signal s_reset, sclk, s_start, s_ready: std_logic; 

signal s_sample_adjusted0, s_sample_adjusted1, s_sample_adjusted2 : std_logic_vector (FP_WIDTH-1 downto 0);

signal s_filter0, s_filter1, s_filter2 : std_logic_vector (FP_WIDTH-1 downto 0);

signal s_output: std_logic_vector (FP_WIDTH-1 downto 0);

begin

    uut: cnn_conv3 port map (   reset       => s_reset,
                                clk         => sclk,
                                start       => s_start,
                                ready       => s_ready,
                                sample_adjusted0      => s_sample_adjusted0,
                                sample_adjusted1      => s_sample_adjusted1,
                                sample_adjusted2      => s_sample_adjusted2,                                 
                                filter0     => s_filter0,
                                filter1     => s_filter1,
                                filter2     => s_filter2, 
                                output      => s_output);
  
    clk: process
        begin
            sclk <= '0';
            wait for 5ns;
            sclk <= '1';
            wait for 5ns;            
        end process;

    stimulus: process
        begin
            s_reset <= '0';
            s_start <= '0';            
            wait for 20ns;            
            s_reset <= '1';
            s_sample_adjusted0 <= (others => '0'); 
            s_sample_adjusted1 <= (others => '0');
            s_sample_adjusted2 <= (others => '0');
            s_filter0 <= (others => '0');
            s_filter1 <= (others => '0');
            s_filter2 <= (others => '0');   
            wait for 20ns;
            s_reset <= '0';
            wait for 10ns;
            s_start <= '1'; 
            s_sample_adjusted0 <= "000000000000000000000000000";
            s_sample_adjusted1 <= "001111001111101000000101000";
            s_sample_adjusted2 <= "001111011000000001001000010";           

            s_filter0 <= thirdConvFilter(31,31,2);
            s_filter1 <= thirdConvFilter(31,31,1);
            s_filter2 <= thirdConvFilter(31,31,0);   
            wait for 10ns;
            s_start <= '0';
            wait for 150ns;
            wait;
        end process;

end Behavioral;
