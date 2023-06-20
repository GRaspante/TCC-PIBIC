----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.04.2023 22:42:56
-- Design Name: 
-- Module Name: cnn_conv1_top - Behavioral
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


entity cnn_conv1_top is
    Port (  reset_conv : in STD_LOGIC;
            clk : in STD_LOGIC;
            start_conv : in std_logic;
            sample_adjust : in samples_adjust; -- (1x60x27bits)
             first_filter : in filter; -- (32x7x27bits)
             first_bias : in biasConv; -- (1x32x27bits)
            out_conv7 : out std_logic_vector(FP_WIDTH-1 downto 0);--teste noready_conv7 : out std_logic;--teste no ILA
            output_conv : out outConv; -- (32x60x27bits)
            ready_conv : out std_logic;--teste no ILA
--            led_inicio : out std_logic;--teste no ILA
--            led_atualiza_entradas : out std_logic;--teste no ILA
--            led_reg_saida : out std_logic;--teste no ILA
--            counter : out std_logic_vector(1 downto 0);--teste no ILA
            count_i : out std_logic_vector(6 downto 0);--teste no ILA
           count_j : out std_logic_vector(5 downto 0)--teste no ILA
);
end cnn_conv1_top;

architecture Behavioral of cnn_conv1_top is

component cnn_conv1 is
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

-- sinais primários do top module que se comunicam com o SOFTWARE
signal s_first_filter : filter := firstConvFilter; -- (32x7x27bits)
signal s_first_bias : biasConv := firstConvBias; -- (1x32x27bits)
signal s_output_conv : outConv; -- (32x60x27bits)

-- sinais intermediários de comunicação com o componente
signal s_sample_adjusted0, s_sample_adjusted1, s_sample_adjusted2, s_sample_adjusted3, s_sample_adjusted4, s_sample_adjusted5, s_sample_adjusted6 : std_logic_vector (FP_WIDTH-1 downto 0);
signal s_filter0, s_filter1, s_filter2, s_filter3, s_filter4, s_filter5, s_filter6 : std_logic_vector (FP_WIDTH-1 downto 0);
signal s_bias, s_output : std_logic_vector (FP_WIDTH-1 downto 0):=(others => '0');
signal s_ready, done : std_logic :='0';
signal s_start : std_logic :='1';

signal i : integer range 6 to (sampleLength-1) := sampleLength-1;
signal j : integer range 0 to (numberOfFilters-1):= numberOfFilters-1;
TYPE estados is (inicio, atualiza_entradas, reg_saida, fim);
signal estado_atual, proximo_estado : estados;

begin

conv7samples:   cnn_conv1 port map (
                reset => reset_conv,
                clk => clk,
                start => s_start,
                sample_adjusted0 => s_sample_adjusted0,
                sample_adjusted1 => s_sample_adjusted1,
                sample_adjusted2 => s_sample_adjusted2,
                sample_adjusted3 => s_sample_adjusted3,
                sample_adjusted4 => s_sample_adjusted4,
                sample_adjusted5 => s_sample_adjusted5,
                sample_adjusted6 => s_sample_adjusted6,
                filter0 => s_filter0,
                filter1 => s_filter1,
                filter2 => s_filter2,
                filter3 => s_filter3,
                filter4 => s_filter4,
                filter5 => s_filter5,
                filter6 => s_filter6,
                bias => s_bias,
                ready => s_ready,
                output => s_output);

-- PROCESSO PARA ATRIBUIÇÃO DO ESTADO ATUAL E RESET
state_reg: process(clk, reset_conv)
begin
    if reset_conv = '1' then
        estado_atual <= inicio;
    elsif rising_edge (clk) then
        estado_atual <= proximo_estado;
    end if;
end process;

-- PROCESSO PARA TRANSIÇÃO DOS ESTADOS
next_state_logic: process(clk, start_conv, estado_atual, s_ready, done)
begin
    if rising_edge(clk) then
    case estado_atual is
    when inicio =>
        if start_conv = '1' then
            
            proximo_estado <= atualiza_entradas;
        else
            proximo_estado <= inicio;
        end if;
    when atualiza_entradas =>
        if done = '1' then
            proximo_estado <= fim;
        elsif s_ready = '1' then
            proximo_estado <= reg_saida;
        else
            proximo_estado <= atualiza_entradas;
        end if;
    when reg_saida =>
        if done = '1' then
            proximo_estado <= fim;
        else
            proximo_estado <= atualiza_entradas;
        --proximo_estado <= reg_saida; -- apenas para testes
        end if;
    when fim =>
        proximo_estado <= fim;
    when others =>
        proximo_estado <= inicio;
    end case;
end if;
end process;

-- PROCESSO PARA DESCRIÇÃO DOS ESTADOS E ATRIBUIÇÃO PARA OS VALORES DE SAÍDA
output_logic: process(clk, estado_atual)
variable count : std_logic_vector(1 downto 0);

begin
    count_i <= std_logic_vector(to_unsigned(i,7));
   count_j <= std_logic_vector(to_unsigned(j,6));
if rising_edge(clk) then
    case estado_atual is
    when inicio => -- ESTADO INICIAL QUE ZERA OS VALORES DE ENTRADA DA CONVOLUs_start <= '0';
        s_sample_adjusted0 <= (others => '0'); -- (1x66x27bits)
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
        s_bias <= (others => '0');
--        led_inicio <= '1';
--        led_atualiza_entradas <= '0';
--        led_reg_saida <= '0';
        s_output_conv <=(others =>(others =>(others => '0')));
        output_conv <=(others =>(others =>(others => '0')));
        count := "00";
        i <= 65;
        j <= 31;
        ready_conv <='0';
    when atualiza_entradas => -- ESTADO QUE ATUALIZA AS ENTRADAS DA CONVOLUÇÃOs_start <= '1';
        s_sample_adjusted0 <= sample_adjust(i); -- (1x66x27bits)
        s_sample_adjusted1 <= sample_adjust(i-1);
        s_sample_adjusted2 <= sample_adjust(i-2);
        s_sample_adjusted3 <= sample_adjust(i-3);
        s_sample_adjusted4 <= sample_adjust(i-4);
        s_sample_adjusted5 <= sample_adjust(i-5);
        s_sample_adjusted6 <= sample_adjust(i-6);
        s_filter0 <= first_filter(j,6);
         s_filter1 <= first_filter(j,5);
         s_filter2 <= first_filter(j,4);
         s_filter3 <= first_filter(j,3);
         s_filter4 <= first_filter(j,2);
         s_filter5 <= first_filter(j,1);
         s_filter6 <= first_filter(j,0);
         s_bias <= first_bias(j);
--        s_filter0 <= firstConvFilter(j,6);
--        s_filter1 <= firstConvFilter(j,5);
--        s_filter2 <= firstConvFilter(j,4);
--        s_filter3 <= firstConvFilter(j,3);
--        s_filter4 <= firstConvFilter(j,2);
--        s_filter5 <= firstConvFilter(j,1);
--        s_filter6 <= firstConvFilter(j,0);
--        s_bias <= firstConvBias(j);
        ready_conv <='0';
        i <= i;
        j <= j;
--        led_inicio <= '0';
--        led_atualiza_entradas <= '1';
--        led_reg_saida <= '0';
    when reg_saida => -- ESTADO QUE VARIA O i E j E REGISTRAS OS RESULTADOS DA CONs_start <= '1';
        output_conv(j,i-6) <= s_output;
        if count = "10" then
            count := "00";
            s_output_conv(j,i-6) <= s_output;
                if (i-6)<=0 and j>0 then
                    i <= 65;
                    j <= j-1;
                    count := "00";
                elsif (i-6)<=0 and j=0 then
                    i <= i;
                    j <= j;
                    done <= '1';
                    count := "00";
                else
                    i <= i-1;
                    j <= j;
                count := "00";                
                end if;
        else
            count := std_logic_vector(unsigned(count)+1);
        end if;
   ready_conv <='0';
--    led_atualiza_entradas <= '0';
--    led_reg_saida <= '1'; -- apenas para teste
--    led_inicio <= '0';        
        --led_fim <= '0';
    when fim => -- ESTADO FIM COM A CONVOLUÇÃO COMPLETA E REGISTRO COMPLETOS Ns_start <= '0';
       ready_conv <= '1';
        s_start <= '0';
        i <= i;
        j <= j;
        output_conv <=  s_output_conv;
      --  led_inicio <= '0';
      --  led_atualiza_entradas <= '0';
      --  led_reg_saida <= '0';
    when others => -- outros estados
        s_start <= '0';
        ready_conv <= '0';
        i <= i;
        j <= j;
       -- led_inicio <= '0';
       -- led_atualiza_entradas <= '0';
       -- led_reg_saida <= '0';
end case;

--counter <= count;
end if;
end process;

out_conv7 <= s_output;
--ready_conv7 <= s_ready;
--ready_conv7 <= done; -- apenas para teste

end Behavioral;
