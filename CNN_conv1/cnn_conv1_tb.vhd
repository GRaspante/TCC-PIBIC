----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.04.2023 23:33:39
-- Design Name: 
-- Module Name: cnn_conv1_tb - Behavioral
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
use work.fpupack.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cnn_conv1_tb is
--  Port ( );
end cnn_conv1_tb;

architecture Behavioral of cnn_conv1_tb is

component cnn_conv1 
Port (  reset : in STD_LOGIC;
        clk : in STD_LOGIC;
        start : in std_logic;
        sample_adjusted0 : in std_logic_vector (FP_WIDTH-1 downto 0);
        sample_adjusted1 : in std_logic_vector (FP_WIDTH-1 downto 0);
        sample_adjusted2 : in std_logic_vector (FP_WIDTH-1 downto 0);
        sample_adjusted3 : in std_logic_vector (FP_WIDTH-1 downto 0);
        sample_adjusted4 : in std_logic_vector (FP_WIDTH-1 downto 0);
        sample_adjusted5 : in std_logic_vector (FP_WIDTH-1 downto 0);
        sample_adjusted6 : in std_logic_vector (FP_WIDTH-1 downto 0);
        filter0 : in std_logic_vector (FP_WIDTH-1 downto 0);
        filter1 : in std_logic_vector (FP_WIDTH-1 downto 0);
        filter2 : in std_logic_vector (FP_WIDTH-1 downto 0);
        filter3 : in std_logic_vector (FP_WIDTH-1 downto 0);
        filter4 : in std_logic_vector (FP_WIDTH-1 downto 0);
        filter5 : in std_logic_vector (FP_WIDTH-1 downto 0);
        filter6 : in std_logic_vector (FP_WIDTH-1 downto 0);
        bias : in std_logic_vector (FP_WIDTH-1 downto 0);
        ready : out std_logic;
        output : out std_logic_vector (FP_WIDTH-1 downto 0));
end component;

signal s_reset, sclk, s_start, s_ready: std_logic; 

signal s_sample_adjusted0, s_sample_adjusted1, s_sample_adjusted2 : std_logic_vector (FP_WIDTH-1 downto 0);
signal s_sample_adjusted3, s_sample_adjusted4, s_sample_adjusted5, s_sample_adjusted6 : std_logic_vector (FP_WIDTH-1 downto 0);

signal s_filter0, s_filter1, s_filter2 : std_logic_vector (FP_WIDTH-1 downto 0);
signal s_filter3, s_filter4, s_filter5, s_filter6 : std_logic_vector (FP_WIDTH-1 downto 0);

signal s_bias, s_output: std_logic_vector (FP_WIDTH-1 downto 0);

begin

    uut: cnn_conv1 port map (   reset       => s_reset,
                                clk         => sclk,
                                start       => s_start,
                                ready       => s_ready,
                                sample_adjusted0      => s_sample_adjusted0,
                                sample_adjusted1      => s_sample_adjusted1,
                                sample_adjusted2      => s_sample_adjusted2,
                                sample_adjusted3      => s_sample_adjusted3,
                                sample_adjusted4      => s_sample_adjusted4,
                                sample_adjusted5      => s_sample_adjusted5,
                                sample_adjusted6      => s_sample_adjusted6,                              
                                filter0     => s_filter0,
                                filter1     => s_filter1,
                                filter2     => s_filter2,                                     
                                filter3     => s_filter3,
                                filter4     => s_filter4,
                                filter5     => s_filter5,
                                filter6     => s_filter6,                               
                                bias        => s_bias,
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
            wait for 25ns;
            s_reset <= '1';
            wait for 20ns;
            s_reset <= '0';
            s_sample_adjusted0 <= (others => '0'); 
            s_sample_adjusted1 <= (others => '0');
            s_sample_adjusted2 <= (others => '0');
            s_sample_adjusted3 <= (others => '0');
            s_sample_adjusted4 <= (others => '0');
            s_sample_adjusted5 <= (others => '0');
            s_sample_adjusted6 <= (others => '0');
            s_filter0 <= (others => '0');
            s_filter1 <= (others => '0');
            s_filter2 <= (others => '0');
            s_filter3 <= (others => '0');
            s_filter4 <= (others => '0');
            s_filter5 <= (others => '0');
            s_filter6 <= (others => '0');
            wait for 10ns;
            s_start <= '1';
            wait for 10ns;
            s_sample_adjusted0 <= "001111000100111011011001000"; 
            s_sample_adjusted1 <= "001111000011111101000100010";
            s_sample_adjusted2 <= "101111011000010100110000000";
            s_sample_adjusted3 <= "101111010100111000011001001";
            s_sample_adjusted4 <= "101111000001111011101110011";
            s_sample_adjusted5 <= "101111001001110000111100111";
            s_sample_adjusted6 <= "101111010100111011010101111";
            s_filter0 <= firstConvFilter(31,6);
            s_filter1 <= firstConvFilter(31,5);
            s_filter2 <= firstConvFilter(31,4);
            s_filter3 <= firstConvFilter(31,3);
            s_filter4 <= firstConvFilter(31,2);
            s_filter5 <= firstConvFilter(31,1);
            s_filter6 <= firstConvFilter(31,0);
            s_bias <= firstConvBias(31);
            wait for 150ns;
            wait;
        end process;
end Behavioral;
