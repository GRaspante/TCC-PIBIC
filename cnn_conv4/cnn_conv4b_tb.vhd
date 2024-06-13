----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.08.2023 12:44:25
-- Design Name: 
-- Module Name: cnn_conv4b_tb - Behavioral
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

entity cnn_conv4b_tb is
--  Port ( );
end cnn_conv4b_tb;

architecture Behavioral of cnn_conv4b_tb is

component cnn_conv4b is
    Port (  reset_conv4 : in STD_LOGIC;
            clk : in STD_LOGIC;
            start_conv4 : in STD_LOGIC;
            samples_conv4 : in in_Conv4;
--            filter_conv4 : in filter4;
--            bias_conv4 : in biasConv;
            ready_conv4: out STD_LOGIC;            
--            output_conv4: out out_Conv2
            out_conv4: out std_logic_vector (FP_WIDTH-1 downto 0));--ILA
end component;

signal sreset_conv4, sclk, s_start_conv4, sready_conv4 : std_logic;
signal s_samples_conv4 : in_Conv4;
--signal sfilter_conv4 : filter4;
--signal sbias_conv4 : biasConv;
signal s_out_conv4tb: std_logic_vector (FP_WIDTH-1 downto 0);

begin
uut: cnn_conv4b port map (     reset_conv4       => sreset_conv4,
                                clk               => sclk,
                                start_conv4       => s_start_conv4,
                                ready_conv4       => sready_conv4,
                                samples_conv4     => s_samples_conv4,                                    
                             --   filter_conv4      => sfilter_conv4,                                
                            --    bias_conv4        => sbias_conv4,                                
                                out_conv4      => s_out_conv4tb);
                                
clk: process
        begin
            sclk <= '0';
            wait for 5ns;
            sclk <= '1';
            wait for 5ns;            
        end process;
        
stimulus: process
    begin
        sreset_conv4 <= '0';
        s_start_conv4 <= '0';            
        wait for 10ns;            
        sreset_conv4 <= '1';
        s_samples_conv4 <= ((others =>(others => (others => '0'))));
--        sbias_conv4 <= (others => (others => '0'));
--        sfilter_conv4 <= ((others =>(others => (others => '0'))));
        wait for 20ns;
        
        sreset_conv4 <= '0';
        wait for 10ns;
        
        s_start_conv4 <= '1'; 
--        sbias_conv4 <= fourthConvBias;
--        sfilter_conv4 <= fourthConvfilter;
        s_samples_conv4 <= (("001111100101100100110000101","001111100110101010101110111","001111100101001000101100000","001111100100111001101001111","001111100100011101111100000","001111100011111011110110101","001111100011001110011111011","001111100010110001011011110","001111100010110000101101111","001111100010111000100010101","001111100100010001110100100","001111100101101111100010011","001111100111101011000001100","001111101000111100101000011","001111101010001001011000110","001111101010111101110000011","001111101011000101011001001","001111101010001011110001001","001111101001011011101000111","001111101000010111010111001","001111100111110011100110110","001111101000000000011000101","001111101000110110110110000","001111101001001000101010011","001111101001101001100111011","001111101010010001010000010","001111101010100001110001101","001111101010000011000001110","001111101000110100011101011","001111100010011011111001011"),
("001111011000001001011001010","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","001111000001101110100001101","001111001011011111010100000","001111000111110100111011001","001110110111000001110011100","001110001010000101111011000","001110110101111011100011010","001111001011010010101000011","001111001111101011100101011","001111010011010010001111010","001111011000010001111010100","001111011001001101010000000","001111010000100101101010101","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","001110110100001000011110000","001111001000111001011010001"),
("000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000"),
("001111100000010010000000000","001111100001000100010101010","001111100010011100000100111","001111100010001011110111001","001111100001001111111110010","001111100000110010100011000","001111100000100101001110101","001111100000011000111010111","001111100000010000110100111","001111100000100000000001111","001111100000101000001101101","001111100000111110100010011","001111100001010010011110110","001111100000111110110000000","001111100010000110110011011","001111100010010011100110111","001111100001011000001100011","001111100000001010001110000","001111011101001100011011100","001111011010011011100000100","001111011000100010000000010","001111010110011111111110010","001111010110000110100001110","001111011001000011001000000","001111011011011010111010100","001111011110110110101011000","001111100000101011111100000","001111100010100101000100011","001111100001100011101100110","001111100001101111001000011"),
("000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000"),
("001111101100001010001110101","001111101100110101010000100","001111101100000000100000110","001111101010101011100101111","001111101010010110101000101","001111101001111001111000000","001111101001010001111111111","001111101000101101100110110","001111100111100010001000011","001111100101001100001100101","001111100011010100101010010","001111100001111001101000101","001111100001001000101000100","001111100001101100001001111","001111100100000010110000011","001111100110100010010011001","001111100111011001000011110","001111100110101010001000011","001111100100001010101101001","001111100001111100011001100","001111100000110111011110101","001111100001110000101100010","001111100100100000101100001","001111101000011000111111110","001111101010000001011101111","001111101011110110111100001","001111101101011111101101001","001111101101011111001011110","001111101011101010110100000","001111100100110011000110100"),
("001111100111110001111001111","001111101100001100010001010","001111101011100001001011001","001111101010101011110001101","001111101001111001011001111","001111101001100010111001111","001111101001010101001000000","001111101000111011111001011","001111101000110000001010000","001111101000101111000100000","001111101000111101010111001","001111101001001001110101001","001111101001100000101000101","001111101011001011001111110","001111101100111011110000100","001111101110000011000010100","001111101101011111000010010","001111101011000001000110010","001111101000010010110011111","001111100010010000001001010","001111011100010000100101001","001111011010011100010011011","001111011100111100011100001","001111100001000101111001001","001111100101100011001100100","001111101001010010110001011","001111101011011101111000110","001111101101100001101100101","001111101110011010001110101","001111101001000011100011101"),
("001111011110100011010000100","001111100001010011001101011","001111100100001111011100010","001111100110111111001110111","001111101000001111000010101","001111101000110100101011111","001111101001001001010010111","001111101001010100110010000","001111101001001000001101000","001111101000111011000101001","001111101000110000000101100","001111101000010000001000010","001111100110101001101110001","001111100010111111110110010","001111011011111101100010001","001110100100101110101111100","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","001111001000001111101010011"),
("000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","001111000110000100111011000","001111010110011000001111010","001111011010010011101101011","001111011101000000100001110","001111011101010111011111111","001111011001110011110011110","001111001011001111010000011","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000"),
("000000000000000000000000000","001111011101011001000100100","001111100010010100100011101","001111100100000011000010100","001111100100000001011000000","001111100100101000010110000","001111100101011001111111100","001111100110011101000011001","001111100110110001011111011","001111100110101101001001111","001111100110001001011010101","001111100101001100010100010","001111100010111100001001010","001111011110001001101101110","001111010001100010011010110","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","001111000011101011101100110","001111001010011010000010101","001111010000011001000011010","001111010101011110110101001","001111010011010110011111111","001111010011101101000000101","001111011000011000011010111","001111011100000000000111110","001111100001100011011011110"),
("001111100111101100010011000","001111101000111001001100000","001111100111010001101001110","001111100011010001010001101","001111100001101011000000100","001111100000110001110110100","001111100000100001001101111","001111011111100001101110001","001111011110010101000100111","001111011110001101000000000","001111011110000010101011111","001111011110111111000010111","001111100000100111010010101","001111100010111010111100010","001111100110101101111010000","001111101000111011100000011","001111101001011001011001110","001111101000111000101001101","001111100111101011111100000","001111100100011000011010000","001111100010010100011010110","001111100001100101101001101","001111100010100010000010101","001111100101100100100001010","001111101000001111111011010","001111101001101110000001010","001111101011100111100011011","001111101011110010110110011","001111101010110101011110101","001111100011010100100100011"),
("000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000"),
("000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000"),
("001111100011100011011100110","001111101001001010100100010","001111101001100110100100010","001111101010000111001110011","001111101001101000101101001","001111101001000100111001101","001111101000100100101100011","001111101000011011111110000","001111101000100101100000010","001111101001000101100010101","001111101001110100000010110","001111101010101011101101110","001111101011101110111011110","001111101101000010011011001","001111101101000101010110011","001111101100001101100001110","001111101010000111001011110","001111100111100000000010110","001111100011111101110110111","001111011111111011011000110","001111011100111100111101001","001111011100100111100000000","001111011111101111000110011","001111100001010100110111010","001111100011110010100100011","001111100110011000000010010","001111101000100001110011001","001111101000100000001010111","001111101001011011111000001","001111100010001101111010100"),
("001111100001110110110001011","001111101001010011010001100","001111101010011001000001011","001111101010110101010011111","001111101011000011010101010","001111101011001000000010011","001111101011010100001001000","001111101010111110110000100","001111101010110010010111011","001111101010001101110110001","001111101001101001010000101","001111101001000010000001010","001111101000101001000010100","001111100111111000000111111","001111100110001001111000010","001111100011001011100111001","001111100000011010100100110","001111011000100110111101100","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","001111001100101001000100110","001111011010111000110010111","001111100001000011100000101","001111100010000010011100110","001111011101110001110100111"),
("000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000"),
("000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000"),
("001111100101000010101001010","001111101100011100111010001","001111101101011011001111001","001111101101100001010011010","001111101101000000010000110","001111101100110111001010101","001111101100101111110100011","001111101100100001110000001","001111101100000011010110100","001111101011010001111101110","001111101010110110000011100","001111101010000101100011011","001111101001110011100110111","001111101010011110111101000","001111101011101000111011101","001111101101001101110110001","001111101101011100111110101","001111101100001111000111001","001111101010001000011110100","001111100111010001100100000","001111100011001001111010111","001111100000101010010100011","001111100000011001011111100","001111100001001101100111010","001111100100110111100010101","001111101000000101100010101","001111101010000111011101101","001111101010111101111110010","001111101011001000101010000","001111101010011001100001100"),
("000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","001110111110110001001010010","001110101000001100010010011","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000"),
("001111101010010110010110011","001111101011100110010110100","001111101011000100101101010","001111101001010101000000000","001111101000010011111100110","001111100111100101001110111","001111100110011010101010000","001111100101010100100011001","001111100011101001100111011","001111100010110111011010000","001111100010100100111111111","001111100010101110101101110","001111100100001010011101110","001111100111111100010111001","001111101010100100001111000","001111101100100011100010100","001111101100011110110101011","001111101010101110101011001","001111101000100001101011100","001111100011100011000101100","001111011110101111000001011","001111011100011111100101101","001111011111111101000010101","001111100011011110111010101","001111100111010110101101010","001111101010000111110010000","001111101100011001101110001","001111101101001111001100110","001111101100010010100111000","001111100111000001110110110"),
("000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","001111011000001110001110101","001111100011100110100110101","001111101001001101000001010","001111101100001010001100100","001111101110001010101010111","001111101110100000100101011","001111101101101110001101111","001111101100000010101101000","001111101001101000110110100","001111100100111110110000000","001111011110111111111100000","001111010010000101101011010","000000000000000000000000000","000000000000000000000000000"),
("001111100011000111101111111","001111100110011101010000110","001111100101110011110111100","001111100011110001110111100","001111100011000001101100110","001111100010010010111110110","001111100001101001111010010","001111100001011001001110010","001111100000011010101001001","001111011110111000100101010","001111011101000010001101010","001111011100101011011111011","001111011101011000001001010","001111100000010101110111100","001111100001101011111110111","001111100100101100110011000","001111100111010011100000100","001111101000011011001101100","001111101000110100001001111","001111101001010101111100111","001111101001110101101101010","001111101010110011010101101","001111101011110111101010000","001111101100101010111110110","001111101100110100010010100","001111101100100000110111111","001111101100010110110010001","001111101011101001010101100","001111101010000101011001100","001111100100010010110111011"),
("001111010010010100001111100","001111100011110010101011001","001111100110111000000101010","001111101000001101101011100","001111101000001011111010100","001111101000010101000111010","001111101000010010110001101","001111100111111101000110101","001111100111001101000010001","001111100101010001110011110","001111100011001111111010111","001111100001000111000010000","001111011101100011000100101","001111010110001010100101111","001111000000010001110110111","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","001111001001000001001001001","001111011011011010100001111","001111100000010001001000100","001111100101010100111101111"),
("001111011010110111111000001","001111100001110110110010011","001111100100011110011001101","001111100110000011001000100","001111100111000011011011011","001111100111011110111110110","001111101000000110111001011","001111101000010110111111110","001111101000101010100001100","001111101000111010111111000","001111101001000111000111100","001111101001011011111000000","001111101001010110111010011","001111101000001111111001111","001111100011111100101011011","001111011011101101001001100","001111001001101011110111110","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","001111001111010100101101101","001111011000001101000011101","001111010000110011101001000"),
("001111100000100111111100011","001111011100100100000000110","001111011000101101111010101","001111010011111010100101111","001111010010111100111011001","001111010010101000101010000","001111010001000010010010100","001111000010010100100110100","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","001111001110100000110111111","001111011000011011000100001","001111011100101001111000101","001111011010001100111011010","000000000000000000000000000"),
("000000000000000000000000000","001111011010110111111011110","001111011111100011110101011","001111011110100110010000111","001111011010111001111011110","001111011000110110110111001","001111011001100010110010111","001111011001111110010111101","001111011010110011100111100","001111011100001110110111000","001111011100110001111001011","001111011100101111000111001","001111011100110010100110100","001111011011011000011101010","001111011011111000101101011","001111011101101010011110101","001111011100110011100101011","001111011001110111111010100","001111010110011111110010110","001111001100001100000100110","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","001110111110010111101110110","001111010111001111101000100","001111011100101010011100010","001111011100100101000001010"),
("001111100010100110000010010","001111100100000110101101111","001111100100101011001010111","001111100100000111000010111","001111100011010000001100100","001111100010101100000100101","001111100010101101110100100","001111100010110001011001011","001111100010000000010010000","001111100000111110000000110","001111011111101100100010010","001111011101010101010111100","001111011010011010101011000","001111010111000000111001111","001111010100110010110100101","001111010110111000101100100","001111001110011011010111101","001111000011000111110110100","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","001111010110101111010110111","001111011101101011000011111","001111011110111110010111011","001111100001010011111000111"),
("001111101010001110000000001","001111101001001110111010101","001111101000010111010011110","001111100111001011110111001","001111100110110000111101101","001111100111011001010000000","001111101000001000001010011","001111101000000111000100000","001111100110101110010101111","001111100100111101011100101","001111100010011111111110000","001111011110111100110101010","001111011000000001110100011","001111010010110011010011100","001111010001111001010010100","001111010100011011011010010","001111001110000110010101010","001110010011110111001010110","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","001111001011000000010110010","001111011011101001111011000","001111100010010110110111100","001111100110101110100010011","001111100111110001111100110","001111100110001010010011010","001111010100110010100111000"),
("000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","001111000000110000010001000","001111010000000110100011011","001111010000100111000101111","001111001100011111111001100","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000"),
("001111100110011100110010000","001111101100110000100000011","001111101101000110110000100","001111101100101000011001111","001111101100001100000011110","001111101100011000011111000","001111101100100010101011100","001111101100010000110011111","001111101011011000001010111","001111101010000101101011011","001111101000101000001100101","001111100101111001101000000","001111100010010010110000000","001111011110010111110101101","001111011100111010100111010","001111011111101011101001001","001111100000100010011000111","001111011111000010011001010","001111011011011000111101110","001111010011000101100111111","001111000011011100011011100","001110111001100011101101101","001111010001000111001100000","001111011011001000010101111","001111100010100001110000100","001111101000001000110100111","001111101010001101101011100","001111101100001001000101101","001111101011110000111100000","001111101000110011000010110"),
("000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000"),
("001111011011001101010011001","001111100110001000011011011","001111100111110010100010110","001111101000010001110011001","001111101000000010110100101","001111101000000111100000011","001111100111100101101011011","001111100111000100101000011","001111100110101100100000011","001111100110011100110010000","001111100110111010101011101","001111100111010000100101101","001111101000000111101111011","001111101001000001001010001","001111101001110001010011011","001111101001101101010100000","001111101000100100110000001","001111100110000001111111111","001111100010111001110000110","001111011110100011001100110","001111011011011011100010111","001111011011110000100010101","001111011110100111001111110","001111100000100101111101100","001111100011100110001110000","001111100101100101111000110","001111100111100000110100000","001111101010010111101110101","001111101010011101001011000","001111101001000101000000111"));
        
        
        
        wait for 300ns;
        wait;
        
    end process;
         

end Behavioral;