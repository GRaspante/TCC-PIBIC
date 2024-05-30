----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.08.2023 21:11:02
-- Design Name: 
-- Module Name: cnn_conv3c - Behavioral
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

entity cnn_conv3c is
    Port (  reset_conv3 : in STD_LOGIC;
            clk : in STD_LOGIC;
            start_conv3 : in STD_LOGIC;
            samples_conv3 : in in_Conv3;
--            filter_conv3 : in filter3;
--            bias_conv3 : in biasConv;
            ready_conv3: out STD_LOGIC;            
--            output_conv3: out out_Conv2;
            out_conv3: out std_logic_vector (FP_WIDTH-1 downto 0) --ILA
            );
end cnn_conv3c;

architecture Behavioral of cnn_conv3c is

component cnn_conv3b is
Port (   reset : in STD_LOGIC;
        clk : in STD_LOGIC;
        startloop : in std_logic;
        sample_adjusted_aux : in aux_filter3;        
        conv3_Bias : in std_logic_vector (FP_WIDTH-1 downto 0);       
        filter_aux : in aux_filter3;     
        ready_loop : out std_logic;
        ready_soma : out std_logic;
        -- save : out std_logic;
        --output_loopb : out out_loop;
        output_final : out std_logic_vector (FP_WIDTH-1 downto 0));        
end component;

--signal sfilter_conv3 : filter3 := thirdConvfilter; 
--signal sbias_conv3 : biasConv := thirdConvBias;

-- signal soutput_conv3 : out_Conv2;

signal s_sample_adjusted_aux : aux_filter3;
signal sfilter_aux : aux_filter3;     
signal sconv3_Bias, soutput_final, s_out_conv3 : std_logic_vector (FP_WIDTH-1 downto 0);
signal s_startloop, sready_conv3 : std_logic;
-- signal s_save : std_logic;

signal sready_loop, sready_soma : std_logic;
signal done : std_logic := '0';

signal i : integer range 0 to (numberOfFilters-1):= numberOfFilters-1;
signal l : integer range 0 to (numberOfFilters-1):= numberOfFilters-1;
signal k : integer range 0 to (inConvs2-1):= inConvs2-1;

TYPE estados is (inicio, atualiza_entradas, reg_saida, fim);
signal estado_atual, proximo_estado : estados;

begin
    loop_soma :         cnn_conv3b port map(
                        reset => reset_conv3,
                        clk => clk,
                        startloop => s_startloop,
                        sample_adjusted_aux => s_sample_adjusted_aux,      
                        conv3_Bias => sconv3_Bias,     
                        filter_aux => sfilter_aux,        
                        ready_loop => sready_loop,
                        ready_soma => sready_soma,
--                        save => s_save,
                       -- output_loopb : out out_loop;
                        output_final => soutput_final);        
            
state_reg: process(clk, reset_conv3)
begin
    if reset_conv3 = '1' then
        estado_atual <= inicio;
    elsif rising_edge (clk) then
        estado_atual <= proximo_estado;
    end if;
end process;

next_state_logic: process(clk)
begin
    if rising_edge(clk) then
        case proximo_estado is
        when inicio =>
            if start_conv3 = '1' then            
                proximo_estado <= atualiza_entradas;
            else
                proximo_estado <= inicio;
            end if;
            
        when atualiza_entradas =>
            if done = '1' then
                proximo_estado <= fim;
            elsif (s_startloop and sready_soma) = '1' then
                proximo_estado <= reg_saida;
            else
                proximo_estado <= atualiza_entradas;
            end if;
            
        when reg_saida =>
            if done = '1' then
                proximo_estado <= fim;            
            elsif sready_soma = '1' then
                proximo_estado <= reg_saida;
            else
                proximo_estado <= atualiza_entradas;        
            end if;
            
        when fim =>            
                proximo_estado <= fim;
           
        when others =>
            proximo_estado <= inicio;
        end case;
    end if;
end process;

output_logic: process(clk, estado_atual)
variable count : std_logic_vector(1 downto 0);
variable count1 : std_logic_vector(1 downto 0);
    begin
        if rising_edge(clk) then
            case estado_atual is
            when inicio => -- ESTADO INICIAL QUE ZERA OS VALORES DE ENTRADA DA CONVOLU
                s_startloop <= '0';
                count := "10";
                count1 := "10";
                i <= 31; 
                l <= 31;
                k <= 31;
                done <= '0';
                sready_conv3 <= '0';
                
            when atualiza_entradas => -- ESTADO QUE ATUALIZA AS ENTRADAS DA CONVOLUÇÃO
                s_sample_adjusted_aux(i,2) <= samples_conv3(i,k);
                s_sample_adjusted_aux(i,1) <= samples_conv3(i,k-1); 
                s_sample_adjusted_aux(i,0) <= samples_conv3(i,k-2); 
                       
                sfilter_aux(i,2) <= thirdConvfilter(l,i,2);
                sfilter_aux(i,1) <= thirdConvfilter(l,i,1);
                sfilter_aux(i,0) <= thirdConvfilter(l,i,0);
                
                sconv3_Bias <= thirdConvBias(l);
                
                if count1 = "10" then
                        if i<=0 then                        
                            i <= i;                       
                            s_startloop <= '1';
                            count1 := "00";
                            count := "10";
                        else
                            i <= i-1;                       
                            count1 := "00";                
                        end if;
                else
                    count1 := std_logic_vector(unsigned(count1)+1);
                end if;           
                
            when reg_saida => -- ESTADO QUE VARIA O i E j E REGISTRAS OS RESULTADOS DA CON
                s_startloop <= '0';
                i <= 31;
                if count = "10" then                
--                    soutput_conv3(l,(k-2)) <= soutput_final;
                    s_out_conv3 <= soutput_final;
                    count := "00";
                        if (k-2)<=0 and l>0 then
                            k <= 31;
                            l <= l-1;
                        elsif (k-2)<=0 and l=0 then
                            k <= k;
                            l <= l;
                            done <= '1';
                        else
                            k <= k-1;
                            l <= l;       
                        end if;
                else
                    count := std_logic_vector(unsigned(count)+1);
                end if;
                
            when fim => -- ESTADO FIM COM A CONVOLUÇÃO COMPLETA E REGISTRO COMPLETOS Ns_start <=
                s_startloop <= '0';
                sready_conv3 <= '1';              
               -- output_loopb <=  s_output_loopb;
              
            when others => -- outros estados
                s_startloop <= '0';
                     
    end case;
end if;
end process;

ready_conv3 <= sready_conv3;
--output_conv3 <= soutput_conv3;
out_conv3 <= s_out_conv3;

end Behavioral;
