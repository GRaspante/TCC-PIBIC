----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.08.2023 11:45:37
-- Design Name: 
-- Module Name: cnn_conv4_tb - Behavioral
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

entity cnn_conv4_tb is
--  Port ( );
end cnn_conv4_tb;

architecture Behavioral of cnn_conv4_tb is

component cnn_conv4 is
Port (  reset : in STD_LOGIC;
        clk : in STD_LOGIC;
        startloop : in std_logic;
        sample_adjusted_aux : in aux_filter4;        
        conv4_Bias : in std_logic_vector (FP_WIDTH-1 downto 0);       
        filter_aux : in aux_filter4;     
        ready_loop : out std_logic;
        ready_soma : out std_logic;
      --  save : out std_logic;
        --output_loopb : out out_loop;
        output_final : out std_logic_vector (FP_WIDTH-1 downto 0));        
end component;

signal sreset, sclk, s_startloop, sready_loop, sready_soma : std_logic;

signal s_conv4_Bias, soutput_final : std_logic_vector (FP_WIDTH-1 downto 0);
signal sfilter_aux, s_sample_adjusted_aux : aux_filter4;

--signal soutput_loopb : out_loop; 

begin

    uut: cnn_conv4 port map ( reset                   => sreset,
                                clk                     => sclk,
                                startloop               => s_startloop,
                                ready_loop              => sready_loop,
                                sample_adjusted_aux     => s_sample_adjusted_aux,                                    
                                filter_aux              => sfilter_aux,
                                --output_loopb            => soutput_loopb,
                                conv4_Bias              => s_conv4_Bias,
                             --   save                    => s_save,
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
            s_sample_adjusted_aux <= ((others => (others => '0')));
            s_conv4_Bias <= (others => '0');
            sfilter_aux <= ((others => (others => '0')));
            wait for 20ns;
            sreset <= '0';
            wait for 10ns;
            s_startloop <= '1';
            
            s_sample_adjusted_aux <= (("001111100101100100110000101"),
("001111011000001001011001010"),
("000000000000000000000000000"),
("001111100000010010000000000"),
("000000000000000000000000000"),
("001111101100001010001110101"),
("001111100111110001111001111"),
("001111011110100011010000100"),
("000000000000000000000000000"),
("000000000000000000000000000"),
("001111100111101100010011000"),
("000000000000000000000000000"),
("000000000000000000000000000"),
("001111100011100011011100110"),
("001111100001110110110001011"),
("000000000000000000000000000"),
("000000000000000000000000000"),
("001111100101000010101001010"),
("000000000000000000000000000"),
("001111101010010110010110011"),
("000000000000000000000000000"),
("001111100011000111101111111"),
("001111010010010100001111100"),
("001111011010110111111000001"),
("001111100000100111111100011"),
("000000000000000000000000000"),
("001111100010100110000010010"),
("001111101010001110000000001"),
("000000000000000000000000000"),
("001111100110011100110010000"),
("000000000000000000000000000"),
("001111011011001101010011001"));
            
            s_conv4_Bias <= "001110101111011100001101101";
            
            sfilter_aux <= (("101111100111101101100000110"),
                            ("001111100000100110111011011"),
                            ("101111011011110100101001001"),
                            ("001111100001111101101110000"),
                            ("001111100001101001010001011"),
                            ("001111100000000100010010111"),
                            ("001111100110111010001000100"),
                            ("101111100110001111010111101"),
                            ("101111101100100111011111001"),
                            ("101111100000111010110001011"),
                            ("101111101000101001010110101"),
                            ("101111011011000010111000010"),
                            ("001111010001110011101010110"),
                            ("001111100100000001010110110"),
                            ("001111100010000100110001001"),
                            ("101111010110110000001000111"),
                            ("101111011010011100111101001"),
                            ("001111100100111101110001011"),
                            ("101111100011010110110010101"),
                            ("001111101011000100111000001"),
                            ("101111011000111100011001111"),
                            ("001111101000011110111010111"),
                            ("101111101000100001010011110"),
                            ("001111100000101100011010111"),
                            ("001111011101100010101000110"),
                            ("101111100110010100110110101"),
                            ("001111101001010101110110100"),
                            ("101111011100100001110100000"),
                            ("001111100001001110000111111"),
                            ("101111100110000100001100110"),
                            ("001111100001110110000101101"),
                            ("001111100001100000101101010"));
                                        
            
            wait for 150ns;
            wait;
    end process;
end Behavioral;





