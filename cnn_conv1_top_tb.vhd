----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.04.2023 11:45:19
-- Design Name: 
-- Module Name: cnn_conv1_top_tb - Behavioral
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

entity cnn_conv1_top_tb is
--  Port ( );
end cnn_conv1_top_tb;

architecture Behavioral of cnn_conv1_top_tb is

component cnn_conv1_top
    Port (      reset_conv : in STD_LOGIC;
                clk : in STD_LOGIC;
                start_conv : in std_logic;
                sample_adjust : in samples_adjust; -- (1x60x27bits)
                first_filter : in filter; -- (32x7x27bits)
                first_bias : in biasConv; -- (1x32x27bits)
                out_conv7 : out std_logic_vector(FP_WIDTH-1 downto 0);--teste noready_conv7 : out std_logic;--teste no ILA
                output_conv : out outConv; -- (32x60x27bits)
                ready_conv : out std_logic;--teste no ILA
--                led_inicio : out std_logic;--teste no ILA
--                led_atualiza_entradas : out std_logic;--teste no ILA
--                led_reg_saida : out std_logic;--teste no ILA
--                counter : out std_logic_vector(1 downto 0);--teste no ILA
               count_i : out std_logic_vector(6 downto 0);--teste no ILA
                count_j : out std_logic_vector(5 downto 0)--teste no ILA
    );
end component;

signal s_reset_conv, sclk, s_start_conv, s_ready_conv : std_logic;
signal first_filter : filter := firstConvFilter;
signal first_bias : biasConv := firstConvBias;
signal s_sample_adjust : samples_adjust;
signal s_out_conv7 : std_logic_vector(FP_WIDTH-1 downto 0);
signal s_output_conv : outConv;
signal s_count_i : std_logic_vector(6 downto 0);
signal s_count_j : std_logic_vector(5 downto 0);

begin
    uut: cnn_conv1_top port map (   reset_conv      => s_reset_conv,
                                    clk             => sclk,
                                    start_conv      => s_start_conv,
                                    sample_adjust   => s_sample_adjust,
                                    first_filter    => first_filter,
                                    first_bias      => first_bias,                                
                                    out_conv7       => s_out_conv7,
                                    output_conv     => s_output_conv,
                                    ready_conv      => s_ready_conv,
                                    --led_inicio      => s_led_inicio,
                                  --  led_atualiza_entradas => s_led_atualiza_entradas,
                                   -- led_reg_saida   => s_led_reg_saida,
                                  --  counter         => s_counter,
                                    count_i         => s_count_i,
                                    count_j         => s_count_j);
                                    
     clk: process
        begin
            sclk <= '0';
            wait for 5ns;
            sclk <= '1';
            wait for 5ns;            
        end process;
        

    stimulus: process
        begin
            s_reset_conv <= '1';
            s_start_conv <= '0';  
            s_sample_adjust <= ("000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","000000000000000000000000000","001111011001100001111100111","001111011001000111011110111","001111011100000011001010111","001111011100000100110001101","001111011001101011010101101","001111011111001101100010011","001111011100110010100100011","001111011111101111100111011","001111011110011001101011101","001111100001100010100011001","001111100000111010111100010","001111100000010100100011111","001111100010001000101011101","001111100000110001011001011","001111100010000110110011001","001111100101011101001011110","001111100100110010101000000","001111100101100100111011001","001111100100100000100110101","001111100101000001011111101","001111100101001010111010100","001111100101000110101111001","001111100100011000010111110","001111100011010010001111110","001111100101000101011000101","001111100010001111010111000","001111100010100111001010000","001111011111111110010111001","001111011011100001011110100","001111010110010100001111100","001111001101011110100001001","001111010011101001110111010","001111001010011010100000000","101111010010011010011001110","101111010100010110111001111","101111011001010001001100001","101111000100111011001100100","101111011001101100001001001","101111011001010001101000000","101111011010110010100101011","101111011001000001111011111","101111011110111111100001110","101111100001011100100100011","101111011111110110011010100","101111011100101000101010100","101111100011101001100000110","101111011100111100101100111","101111011101001111101000000","101111011100010010100001011","101111011011111110001110001","101111011101010010101010000","101111010101101001110110110","101111011110000011000100100","101111010100111011010101111","101111001001110000111100111","101111000001111011101110011","101111010100111000011001001","101111011000010100110000000","001111000011111101000100010","001111000100111011011001000");                    
            wait for 100ns;
            s_reset_conv <= '0';
            s_start_conv <= '1';
            wait;
            
        end process;
    
    
end Behavioral;
