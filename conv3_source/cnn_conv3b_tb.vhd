----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.08.2023 20:15:06
-- Design Name: 
-- Module Name: cnn_conv3b_tb - Behavioral
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

entity cnn_conv3b_tb is
--  Port ( );
end cnn_conv3b_tb;

architecture Behavioral of cnn_conv3b_tb is

component cnn_conv3b is
Port (   reset : in STD_LOGIC;
        clk : in STD_LOGIC;
        startloop : in std_logic;
        sample_adjusted_aux : in aux_filter3;        
        conv3_Bias : in std_logic_vector (FP_WIDTH-1 downto 0);       
        filter_aux : in aux_filter3;        
        ready_loop : out std_logic;
        ready_soma : out std_logic;
     --   save : out std_logic;
     --   output_loopb : out out_loop;
        output_final : out std_logic_vector (FP_WIDTH-1 downto 0));
end component;

signal sreset, sclk, s_startloop, sready_loop, sready_soma : std_logic;

signal s_conv3_Bias, soutput_final : std_logic_vector (FP_WIDTH-1 downto 0);
signal sfilter_aux, s_sample_adjusted_aux : aux_filter3;

--signal soutput_loopb : out_loop; 

begin

    uut: cnn_conv3b port map ( reset                   => sreset,
                                clk                     => sclk,
                                startloop               => s_startloop,
                                ready_loop              => sready_loop,
                                sample_adjusted_aux     => s_sample_adjusted_aux,                                    
                                filter_aux              => sfilter_aux,
                                --output_loopb            => soutput_loopb,
                                conv3_Bias              => s_conv3_Bias,
               --                 save                    => s_save,
                                ready_soma              => sready_soma,
                                output_final            => soutput_final);
                                
     clk: process
        begin
            sclk <= '0';
            wait for 5ns;
            sclk <= '1';
            wait for 5ns;            
        end process;
        
      stimulus: process
        begin
            sreset <= '0';
            s_startloop <= '0';            
            wait for 20ns;            
            sreset <= '1';
            s_sample_adjusted_aux <= ((others =>(others => (others => '0'))));
            s_conv3_Bias <= (others => '0');
            sfilter_aux <= ((others =>(others => (others => '0'))));
            wait for 20ns;
            sreset <= '0';
            wait for 10ns;
            s_startloop <= '1'; 
            
            s_sample_adjusted_aux <= (("000000000000000000000000000","001111001111101000000101000","001111011000000001001000010"),
                                        ("000000000000000000000000000","001111001011000010000011010","001111001100011111011000000"),
                                        ("000000000000000000000000000","000000000000000000000000000","000000000000000000000000000"),
                                        ("000000000000000000000000000","001111100001000110000101010","001111100100011100100000100"),
                                        ("000000000000000000000000000","001111100010100000001111110","001111100100100010010010111"),
                                        ("000000000000000000000000000","001111001011000110111001101","001111010100001011000101111"),
                                        ("000000000000000000000000000","001111100010001111010010100","001111100100000110000101100"),
                                        ("000000000000000000000000000","000000000000000000000000000","000000000000000000000000000"),
                                        ("000000000000000000000000000","001111010111000101000011001","001111011011001000011010101"),
                                        ("000000000000000000000000000","001111011001100001111111100","001111011000000001110010110"),
                                        ("000000000000000000000000000","001111011011011001000000111","001111011010110010101001101"),
                                        ("000000000000000000000000000","001111011010011101010101011","001111011100101101111000100"),
                                        ("000000000000000000000000000","001111000100000001101001111","001110110010010101111010011"),
                                        ("000000000000000000000000000","001111010111101100110100000","001111011100100010001001001"),
                                        ("000000000000000000000000000","001111001011010011000001101","001111001111111111101101001"),
                                        ("000000000000000000000000000","000000000000000000000000000","000000000000000000000000000"),
                                        ("000000000000000000000000000","001111010110111111010010000","001111011011010100000100110"),
                                        ("000000000000000000000000000","001111100001010010101111110","001111100011000010111101110"),
                                        ("000000000000000000000000000","000000000000000000000000000","000000000000000000000000000"),
                                        ("000000000000000000000000000","000000000000000000000000000","000000000000000000000000000"),
                                        ("000000000000000000000000000","001111100001001010001011101","001111100100101001100011001"),
                                        ("000000000000000000000000000","000000000000000000000000000","000000000000000000000000000"),
                                        ("000000000000000000000000000","001111010011111100011101100","001111001000001000111100100"),
                                        ("000000000000000000000000000","000000000000000000000000000","000000000000000000000000000"),
                                        ("000000000000000000000000000","000000000000000000000000000","000000000000000000000000000"),
                                        ("000000000000000000000000000","001111001111110101000101101","001111011000001001000111000"),
                                        ("000000000000000000000000000","001111010101101000011000011","001111010111010101011101111"),
                                        ("000000000000000000000000000","001111010010000111111101000","001111001111111100101100001"),
                                        ("000000000000000000000000000","001111100010101100011011101","001111100011011000111110010"),
                                        ("000000000000000000000000000","001110111100110100100000101","001111001000110010111101000"),
                                        ("000000000000000000000000000","001111100001000101101100101","001111100000111000000000100"),
                                        ("000000000000000000000000000","001111100010001000101110010","001111100011001100011000101"));

            s_conv3_Bias <= "001111011000111011111010111";
            
            sfilter_aux <= ((("101111010111010000110100100","001111011100101111011011011","101111001101111011000111011"),
("101111010110001101000111000","101111100000000001101110010","101111100000001000111000101"),
("101111100001010101100110111","001111100010111100001101011","101111011010110001001101111"),
("101111100011100110000100100","101111011110001010010010010","001111010001110000100111110"),
("101111011000011110101101111","001111011001001000111100000","001111100011000110100100001"),
("101111100000100100100110010","101111011011011101111011100","001111011001010110101011111"),
("101111000100000100101100100","001111100000100110110011001","001111100100010010001111110"),
("001111100000001101001000010","101111011100011010001011000","001111100000111000010101110"),
("101111011100011100011000101","001111100001101001000000000","001111001000110011111111111"),
("101111011110111100010110000","001111100101101100110000111","001111100100001111110101111"),
("001111011110100000101111001","101111001010010101100110011","001110111101101001101010100"),
("101111001110101000111101010","101111011010110011111010010","001111010110000111011000101"),
("001111100010111110010111101","001111011110011111100001111","001111100000100100001010010"),
("101111001111110001010011110","001111010111011000001000000","101111100001101111101101110"),
("001111010100010001011000010","001111010001110001010010101","001111011110100110111111101"),
("001111001010011011010100101","001111011101001011100110100","101111010011100100010111101"),
("001111011100000010110010001","101111010110001100100000000","001111000010100000111101110"),
("101111010101001110111100010","001111100010010100000100001","101111010010001110101010100"),
("001111100010101111010011101","001111011010111111010010110","101111001101100110111011111"),
("101111010000000000111000001","001110111000110110111101000","001111011111110101000101001"),
("001111100010110111001011010","001111010101101001111111100","001111100100011010010110000"),
("101111011100010110111010001","001111010111001001100010000","001111100000010001111001101"),
("101111011000100010110011000","101111010100100010000110111","101111100000000001001000010"),
("101111100001010001100110010","001111100000001100111111011","101111011001110010111111000"),
("001111100010000111100000101","001111100000101110110001100","101111001110101101010000011"),
("001111010000101001101001101","001111010111001110110001010","101111001110001000100111101"),
("001111100001011010000101101","101111011001010100010010000","001111100001011001001001001"),
("001111011111011111011101101","001111011011100000000010011","001111011101000100000101100"),
("001111100101000011110001100","001111011011110111000111001","101111001011000110000000111"),
("001111011110000001110111111","001111010010100011101011101","101111100011101110110010111"),
("001111011010101010110010110","101111010011101001101111000","001111010001101011011100111"),
("101111100000010011111011011","101111100110110110101110101","101111011101110000010110111")));
            
            
            wait for 150ns;
            wait;
    end process;
end Behavioral;



