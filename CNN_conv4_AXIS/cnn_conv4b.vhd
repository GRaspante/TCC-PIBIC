----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.08.2023 12:35:22
-- Design Name: 
-- Module Name: cnn_conv4b - Behavioral
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

entity cnn_conv4b is
    Port (  reset_conv4 : in STD_LOGIC;
            clk : in STD_LOGIC;
            start_conv4 : in STD_LOGIC;
            samples_conv4 : in in_Conv4;
--            filter_conv4 : in filter4;
--            bias_conv4 : in biasConv;
            ready_conv4: out STD_LOGIC;            
            output_conv4: out out_Conv2);
--            out_conv4: out std_logic_vector (FP_WIDTH-1 downto 0));--ILA
end cnn_conv4b;

architecture Behavioral of cnn_conv4b is

component cnn_conv4 is
Port (  reset : in STD_LOGIC;
        clk : in STD_LOGIC;
        startloop : in std_logic;
        sample_adjusted_aux : in aux_filter4;        
        conv4_Bias : in std_logic_vector (FP_WIDTH-1 downto 0);       
        filter_aux : in aux_filter4;     
        ready_loop : out std_logic;
        ready_soma : out std_logic;
        output_final : out std_logic_vector (FP_WIDTH-1 downto 0));        
end component;

--signal sfilter_conv4 : filter4 := fourthConvfilter; 
--signal sbias_conv4 : biasConv := fourthConvBias;
signal soutput_conv4 : out_Conv2;
signal start_conv4_delay : std_logic;
signal s_sample_adjusted_aux : aux_filter4;
signal sfilter_aux : aux_filter4;     
signal sconv4_Bias, soutput_final : std_logic_vector (FP_WIDTH-1 downto 0);
signal s_startloop, sready_conv4 : std_logic;
--signal s_save : std_logic;

signal sready_loop, sready_soma : std_logic;
signal done : std_logic := '0';

signal i : integer range 0 to (numberOfFilters-1):= numberOfFilters-1;
signal l : integer range 0 to (numberOfFilters-1):= numberOfFilters-1;
signal k : integer range 0 to (outConvs-1):= outConvs-1;

TYPE estados is (inicio, atualiza_entradas, reg_saida, fim);
signal estado_atual, proximo_estado : estados;

begin
    loop_soma :         cnn_conv4 port map(
                        reset => reset_conv4,
                        clk => clk,
                        startloop => s_startloop,
                        sample_adjusted_aux => s_sample_adjusted_aux,      
                        conv4_Bias => sconv4_Bias,     
                        filter_aux => sfilter_aux,        
                        ready_loop => sready_loop,
                        ready_soma => sready_soma,
                        output_final => soutput_final);        
            
state_reg: process(clk, reset_conv4)
begin
    if reset_conv4 = '1' then
        estado_atual <= inicio;
    elsif rising_edge (clk) then
        estado_atual <= proximo_estado;
    end if;
end process;

next_state_logic: process(clk)
begin
    if rising_edge(clk) then
        case estado_atual is
        when inicio =>
            if (start_conv4 or start_conv4_delay) = '1' then            
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
            proximo_estado <= inicio;
           
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
                k <= 29;
                done <= '0';
                sready_conv4 <= '0';
                start_conv4_delay <= start_conv4;
                
            when atualiza_entradas => -- ESTADO QUE ATUALIZA AS ENTRADAS DA CONVOLUÇÃO
                s_sample_adjusted_aux(i) <= samples_conv4(i,k);
                sfilter_aux(i) <= fourthConvfilter(l,i);
                sconv4_Bias <= fourthConvBias(l);
                
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
                    soutput_conv4(l,k) <= soutput_final;
                    count := "00";
                        if k<=0 and l>0 then
                            k <= 29;
                            l <= l-1;
                        elsif k<=0 and l=0 then
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
           
            when fim => -- ESTADO FIM COM A CONVOLUÇÃO COMPLETA E REGISTRO COMPLETOS Ns_start <= '0';
                s_startloop <= '0';
                sready_conv4 <= '1';                
               -- output_loopb <=  s_output_loopb;
              
            when others => -- outros estados
                s_startloop <= '0';
            end case;
end if;
end process;

ready_conv4 <= sready_conv4;
output_conv4 <= soutput_conv4;

end Behavioral;

