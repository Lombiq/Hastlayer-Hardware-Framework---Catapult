library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library Hast;
use Hast.SimpleMemory.all;
		
entity Hast_IP is
	port(
		\Clock\        : in  std_logic;
		\Reset\        : in  std_logic;
		\MemberId\     : in  integer;
		\DataIn\       : in  std_logic_vector(31 downto 0);
		\DataOut\      : out std_logic_vector(31 downto 0);
		\ReadEnable\   : out boolean;
		\WriteEnable\  : out boolean;
		\CellIndex\    : out integer;
		\Started\      : in  boolean;
		\Finished\     : out boolean;
		\ReadsDone\    : in  boolean;
		\WritesDone\   : in  boolean
		);
end Hast_IP;
		                                                                                                  
architecture Imp of Hast_IP is                                                                                
		
		
	signal \number.param\                  : integer;
	signal IsPrimenum_number_param         : integer;
	signal ArePrimenums_number_param       : integer;
		                                   
	signal \number.iter\                   : integer;
		
	signal \result\                        : std_logic;
	signal \result_0\                      : std_logic;
	signal \result_1\                      : std_logic;
	signal \result_2\                      : std_logic;
		
	signal \PrimeCalcDataOut_0\            : std_logic;
	signal \PrimeCalcDataOut_1\            : std_logic;
	signal \PrimeCalcDataOut_2\            : std_logic;
		
	signal \Primecalc_result_0\            : std_logic;
	signal \Primecalc_result_1\            : std_logic;
	signal \Primecalc_result_2\            : std_logic;
		
	signal \num_incr\                      : integer;
		                                                          
	signal StartPrimeCalculator_0          : std_logic;
	signal StartPrimeCalculator_1          : std_logic;
	signal StartPrimeCalculator_2          : std_logic;
		                                   
	signal Primecalc_Finished_0            : std_logic;
	signal Primecalc_Finished_1            : std_logic;
	signal Primecalc_Finished_2            : std_logic;
		
	--ISPRIMENUM SIGNALS
	signal IsPrimenum_ReadEna              : boolean;
	signal IsPrimenum_ReadAddr             : integer;
	signal IsPrimenum_WriteEna             : boolean;
	signal IsPrimenum_WriteAddr            : integer;
	signal IsPrimenum_DataOut              : std_logic_vector(31 downto 0);
	signal IsPrimenum_Finish               : boolean;
	signal IsPrimenum_StartPrimeCalc_0     : std_logic;
	signal IsPrimenum_StartPrimeCalc_1     : std_logic;
	signal IsPrimenum_StartPrimeCalc_2     : std_logic;
		
	signal IsPrimenum_Primecalc_instance   : std_logic_vector(7 downto 0);
	signal IsPrimenum_FinishedPrimecalc    : std_logic;
		
	--AREPRIMENUMS SIGNALS
	signal ArePrimenums_ReadEna            : boolean;
	signal ArePrimenums_ReadAddr           : integer;
	signal ArePrimenums_WriteEna           : boolean;
	signal ArePrimenums_WriteAddr          : integer;
	signal ArePrimenums_DataOut            : std_logic_vector(31 downto 0);
	signal ArePrimenums_Finish             : boolean;
	signal ArePrimenums_StartPrimeCalc_0   : std_logic;   
	signal ArePrimenums_StartPrimeCalc_1   : std_logic; 
	signal ArePrimenums_StartPrimeCalc_2   : std_logic; 
		
	signal ArePrimenums_Primecalc_instance : std_logic_vector(7 downto 0);
	signal ArePrimenums_FinishedPrimecalc  : std_logic;
		
	signal \PC0_num2\            : integer range -1048576 to 1048575;
	signal \PC0_num\             : integer range -1048576 to 1048575;
	signal \PC0_number\          : integer range -1048576 to 1048575;
	signal \PC0_PrimeCalcDataIn\ : integer;
	signal \PC0_op\              : integer range -1048576 to 1048575;
		  
		
	--SM_Primecalc_0 state machine states
	type SM_Primecalculator_0 is (
					ST000_Primecalculator_0,
					ST001_Primecalculator_0,
					ST002_Primecalculator_0,
					ST002a_Primecalculator_0,
					ST002b_Primecalculator_0,
					ST002c_Primecalculator_0,
					ST003_Primecalculator_0,
					ST003d0_Primecalculator_0,
					ST003d1_Primecalculator_0,
					ST003d2_Primecalculator_0,
					ST003d3_Primecalculator_0,
					ST004_Primecalculator_0,
					ST005_Primecalculator_0,
					ST006_Primecalculator_0,
					ST006y_Primecalculator_0,
					ST007_Primecalculator_0,
					ST008_Primecalculator_0,
					ST009_Primecalculator_0
					); 
	signal state_SM_Primecalculator_0 : SM_Primecalculator_0; 
		
	--SM_Primecalc_1 state machine states
	type SM_Primecalculator_1 is (
					ST000_Primecalculator_1,
					ST001_Primecalculator_1,
					ST002_Primecalculator_1,
					ST003_Primecalculator_1,
					ST004_Primecalculator_1,
					ST005_Primecalculator_1,
					ST006_Primecalculator_1,
					ST007_Primecalculator_1,
					ST008_Primecalculator_1,
					ST009_Primecalculator_1
					); 
	signal state_SM_Primecalculator_1 : SM_Primecalculator_1; 
		
	--SM_Primecalc_2 state machine states
	type SM_Primecalculator_2 is (
					ST000_Primecalculator_2,
					ST001_Primecalculator_2,
					ST002_Primecalculator_2,
					ST003_Primecalculator_2,
					ST004_Primecalculator_2,
					ST005_Primecalculator_2,
					ST006_Primecalculator_2,
					ST007_Primecalculator_2,
					ST008_Primecalculator_2,
					ST009_Primecalculator_2
					); 
	signal state_SM_Primecalculator_2 : SM_Primecalculator_2; 
		  
	--SM_IsPrimeNumber state machine states
	type SM_IsPrimeNumber is (
					ST000_IsPrimeNumber,
					ST001_IsPrimeNumber,
					ST002a_IsPrimeNumber,
					ST002b_IsPrimeNumber,
					ST002c_IsPrimeNumber,
					ST002d_IsPrimeNumber,
					ST002e_IsPrimeNumber,
					ST002f_IsPrimeNumber,
					ST003_IsPrimeNumber,
					ST004_IsPrimeNumber
					); 
	signal state_SM_IsPrimeNumber : SM_IsPrimeNumber; 
		
	--SM_ArePrimeNumbers state machine states
	type SM_ArePrimeNumbers is (
					ST000_ArePrimeNumbers,
					ST001_ArePrimeNumbers,
					ST002_ArePrimeNumbers,
					ST003_ArePrimeNumbers,
					ST004_ArePrimeNumbers,
					ST005a_ArePrimeNumbers,
					ST005b_ArePrimeNumbers,
					ST005c_ArePrimeNumbers,
					ST005d_ArePrimeNumbers,
					ST005e_ArePrimeNumbers,
					ST005f_ArePrimeNumbers,
					ST006_ArePrimeNumbers,  
					ST007_ArePrimeNumbers,
					ST008_ArePrimeNumbers, 
					ST009_ArePrimeNumbers
					); 
	signal state_SM_ArePrimeNumbers : SM_ArePrimeNumbers; 
		
		
--: Original PrimeCalc:
--------------------------

-- This is the original version of the PrimeCalc procedure. Now it is deprecated, as its function is now implemented with SM_Primecalculator_x State machine.

		
	--procedure \PrimeCalc\(Signal \Clock\ : In  std_logic; Signal \Reset\ : In std_logic; Variable \PrimeCalcDataIn\ : In natural; Variable \PrimeCalcDataOut\ : Out boolean) is
	--	Variable \number\ : natural;
	--	Variable \num\    : natural;
	--	Variable \num2\   : natural;
	--	Variable \result\ : boolean;
	--begin
	--	\number\     := \PrimeCalcDataIn\;--\number.param\;
	--	\num\        := \number\ / 2;
	--	\num2\       := 2;
	--	\PrimeCalcDataOut\ := \result\;
	--	while \num2\ <= \num\ loop
	--		if (\number\ mod \num2\ = 0) then
	--			\result\ := False;
	--			\PrimeCalcDataOut\ := \result\;
	--			return;
	--		end if; 
	--		\num2\ := \num2\ + 1;
	--	end loop;
	--	\result\ := True;
	--	\PrimeCalcDataOut\ := \result\;
	--	return;
	--end procedure;
		
begin
		
	------------------------------------
	-- SM_Primecalculator_0 STATE MACHINE --
	------------------------------------
	-- @Andris:
	-- http://stackoverflow.com/questions/21653831/vhdl-variable-vs-signal-behaviour-in-queue
	-- http://www.sigasi.com/content/vhdls-crown-jewel
		  
	STM_Primecalculator_0: process (\Clock\)
	begin
		if (rising_edge(\Clock\)) then
			if \Reset\ = '1' then
				state_SM_Primecalculator_0 <= ST000_Primecalculator_0;
				\PC0_num2\ <= 0;
				\PC0_num\  <= 0;
				\PC0_number\ <= 0;
				\PC0_PrimeCalcDataIn\ <= 0;
			else
				case (state_SM_Primecalculator_0) is
					
					when ST000_Primecalculator_0 =>
						Primecalc_Finished_0 <= '0';
						if StartPrimeCalculator_0 = '1' then
							state_SM_Primecalculator_0 <= ST001_Primecalculator_0;
						end if; 
						
					when ST001_Primecalculator_0 =>
						\PC0_PrimeCalcDataIn\ <= \number.param\;
						state_SM_Primecalculator_0 <= ST002a_Primecalculator_0;
						
					when ST002a_Primecalculator_0 =>
						\PC0_number\ <= \PC0_PrimeCalcDataIn\;
						state_SM_Primecalculator_0 <= ST002b_Primecalculator_0;
					
					when ST002b_Primecalculator_0 =>
						\PC0_num2\ <= 2;  
						state_SM_Primecalculator_0 <= ST002c_Primecalculator_0;
						
					when ST002c_Primecalculator_0 =>
						\PrimeCalcDataOut_0\ <= \Primecalc_result_0\;
						state_SM_Primecalculator_0 <= ST003_Primecalculator_0;
						
					when ST003_Primecalculator_0 =>
						\PC0_num\    <= \PC0_number\ / 2;
						state_SM_Primecalculator_0 <= ST003d0_Primecalculator_0;
						
					when ST003d0_Primecalculator_0 =>
						\PC0_op\ <= \PC0_number\ / \PC0_num2\;
						state_SM_Primecalculator_0 <= ST003d1_Primecalculator_0;
						
					when ST003d1_Primecalculator_0 =>
						\PC0_op\ <= \PC0_op\ * \PC0_num2\;
						state_SM_Primecalculator_0 <= ST003d2_Primecalculator_0;
						
					when ST003d2_Primecalculator_0 =>
						\PC0_op\ <= \PC0_number\ - \PC0_op\;
						state_SM_Primecalculator_0 <= ST003d3_Primecalculator_0;
						
					when ST003d3_Primecalculator_0 =>
						if (not (\PC0_op\ /= 0)) then
							state_SM_Primecalculator_0 <= ST004_Primecalculator_0;
						else
							state_SM_Primecalculator_0 <= ST006_Primecalculator_0;
						end if;
						
					--when ST003x_Primecalculator_0 =>
					--	if (not (\PC0_number\ mod \PC0_num2\ /= 0)) then
					--		state_SM_Primecalculator_0 <= ST004_Primecalculator_0;
					--	else
					--		state_SM_Primecalculator_0 <= ST006_Primecalculator_0;
					--	end if;
						
					when ST004_Primecalculator_0 =>
						\Primecalc_result_0\ <= '0';
						state_SM_Primecalculator_0 <= ST005_Primecalculator_0;
						
					when ST005_Primecalculator_0 =>
						\PrimeCalcDataOut_0\ <= \Primecalc_result_0\;
						state_SM_Primecalculator_0 <= ST008_Primecalculator_0;
						
					when ST006_Primecalculator_0 =>
						\PC0_num2\ <= \PC0_num2\ + 1;
						state_SM_Primecalculator_0 <= ST006y_Primecalculator_0;
					
					when ST006y_Primecalculator_0 =>
						if \PC0_num2\ <= \PC0_num\ then
							state_SM_Primecalculator_0 <= ST003_Primecalculator_0;
						else 
							state_SM_Primecalculator_0 <= ST007_Primecalculator_0;
						end if;
						
					when ST007_Primecalculator_0 =>
						\Primecalc_result_0\ <= '1';
						state_SM_Primecalculator_0 <= ST005_Primecalculator_0;
						
					when ST008_Primecalculator_0 =>
						\result_0\ <= \PrimeCalcDataOut_0\;
						state_SM_Primecalculator_0 <= ST009_Primecalculator_0;  
						
					when ST009_Primecalculator_0 =>  
						Primecalc_Finished_0 <= '1';                              
						state_SM_Primecalculator_0 <= ST000_Primecalculator_0;  
						     
					when others => null;  
					                                     
				end case;
			end if;
		end if;                                                      
	end process;                                                       
	----------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------
		
		
	------------------------------------
	-- SM_Primecalculator_1 STATE MACHINE --
	------------------------------------
		  
	STM_Primecalculator_1: process (\Clock\)
		variable \num2\            : natural;
		variable \num\             : natural;
		variable \number\          : natural;
		variable \PrimeCalcDataIn\ : integer;
	begin
		if (rising_edge(\Clock\)) then
			if \Reset\ = '1' then
				state_SM_Primecalculator_1 <= ST000_Primecalculator_1;
			else
				case (state_SM_Primecalculator_1) is
					
					when ST000_Primecalculator_1 =>
						Primecalc_Finished_1 <= '0';
						if StartPrimeCalculator_1 = '1' then
							state_SM_Primecalculator_1 <= ST001_Primecalculator_1; 
						end if;
						
					when ST001_Primecalculator_1 =>
						\PrimeCalcDataIn\ := \number.param\;
						state_SM_Primecalculator_1 <= ST002_Primecalculator_1;
						
					when ST002_Primecalculator_1 =>
						\number\ := \PrimeCalcDataIn\;
						\num2\   := 2;  
						\PrimeCalcDataOut_1\ <= \Primecalc_result_1\;
						state_SM_Primecalculator_1 <= ST003_Primecalculator_1;
						
					when ST003_Primecalculator_1 =>
						\num\    := \number\ /2;
						if (not (\number\ mod \num2\ /= 0)) then
							state_SM_Primecalculator_1 <= ST004_Primecalculator_1;
						else
							state_SM_Primecalculator_1 <= ST006_Primecalculator_1;
						end if;
						
					when ST004_Primecalculator_1 =>
						\Primecalc_result_1\ <= '0';
						state_SM_Primecalculator_1 <= ST005_Primecalculator_1;
						
					when ST005_Primecalculator_1 =>
						\PrimeCalcDataOut_1\ <= \Primecalc_result_1\;
						state_SM_Primecalculator_1 <= ST008_Primecalculator_1;
						
					when ST006_Primecalculator_1 =>
						\num2\ := \num2\ + 1;
						if \num2\ <= \num\ then
							state_SM_Primecalculator_1 <= ST003_Primecalculator_1;
						else 
							state_SM_Primecalculator_1 <= ST007_Primecalculator_1;
						end if;
						
					when ST007_Primecalculator_1 =>
						\Primecalc_result_1\ <= '1';
						state_SM_Primecalculator_1 <= ST005_Primecalculator_1;
						
					when ST008_Primecalculator_1 =>
						\result_1\ <= \PrimeCalcDataOut_1\;
						state_SM_Primecalculator_1 <= ST009_Primecalculator_1;  
						
					when ST009_Primecalculator_1 =>  
						Primecalc_Finished_1 <= '1';                             
						state_SM_Primecalculator_1 <= ST000_Primecalculator_1;   
						     
					when others => null;         
					                              
				end case; 
			end if;  
		end if;                                                   
	end process;                                                       
		
	----------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------
		
	------------------------------------
	-- SM_Primecalculator_2 STATE MACHINE --
	------------------------------------
		  
	STM_Primecalculator_2: process (\Clock\)
		variable \num2\            : natural;
		variable \num\             : natural;
		variable \number\          : natural;
		variable \PrimeCalcDataIn\ : integer;
	begin
		if (rising_edge(\Clock\)) then
			if \Reset\ = '1' then
				state_SM_Primecalculator_2 <= ST000_Primecalculator_2;
			else
				case (state_SM_Primecalculator_2) is
					
					when ST000_Primecalculator_2 =>
						Primecalc_Finished_2 <= '0';
						if StartPrimeCalculator_2 = '1' then
							state_SM_Primecalculator_2 <= ST001_Primecalculator_2; 
						end if;
						
					when ST001_Primecalculator_2 =>
						\PrimeCalcDataIn\ := \number.param\;
						state_SM_Primecalculator_2 <= ST002_Primecalculator_2;
						
					when ST002_Primecalculator_2 =>
						\number\ := \PrimeCalcDataIn\;
						\num2\   := 2;  
						\PrimeCalcDataOut_2\ <= \Primecalc_result_2\;
						state_SM_Primecalculator_2 <= ST003_Primecalculator_2;
						
					when ST003_Primecalculator_2 =>
						\num\    := \number\ /2;
						if (not (\number\ mod \num2\ /= 0)) then
							state_SM_Primecalculator_2 <= ST004_Primecalculator_2;
						else
							state_SM_Primecalculator_2 <= ST006_Primecalculator_2;
						end if;
						
					when ST004_Primecalculator_2 =>
						\Primecalc_result_2\ <= '0';
						state_SM_Primecalculator_2 <= ST005_Primecalculator_2;
						
					when ST005_Primecalculator_2 =>
						\PrimeCalcDataOut_2\ <= \Primecalc_result_2\;
						state_SM_Primecalculator_2 <= ST008_Primecalculator_2;
						
					when ST006_Primecalculator_2 =>
						\num2\ := \num2\ + 1;
						if \num2\ <= \num\ then
							state_SM_Primecalculator_2 <= ST003_Primecalculator_2;
						else 
							state_SM_Primecalculator_2 <= ST007_Primecalculator_2;
						end if;
						
					when ST007_Primecalculator_2 =>
						\Primecalc_result_2\ <= '1';
						state_SM_Primecalculator_2 <= ST005_Primecalculator_2;
						
					when ST008_Primecalculator_2 =>
						\result_2\ <= \PrimeCalcDataOut_2\;
						state_SM_Primecalculator_2 <= ST009_Primecalculator_2;  
						
					when ST009_Primecalculator_2 =>    
						Primecalc_Finished_2 <= '1';                           
						state_SM_Primecalculator_2 <= ST000_Primecalculator_2; 
						       
					when others => null;    
					                                   
				end case; 
			end if;
		end if;                                                     
	end process;                                                       
		
	----------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------
		
	------------------------------------
	-- SM_IsPrimeNumber STATE MACHINE --
	------------------------------------
		  
	STM_IsPrimeNumber: process (\Clock\)
	begin
		if (rising_edge(\Clock\)) then
			if \Reset\ = '1' then
				state_SM_IsPrimeNumber <= ST000_IsPrimeNumber;
				IsPrimenum_Finish             <= false;
				IsPrimenum_WriteEna           <= false;
				IsPrimenum_WriteAddr          <= 0;
				IsPrimenum_ReadEna            <= false;
				IsPrimenum_ReadAddr           <= 0;
				IsPrimenum_StartPrimeCalc_0   <= '0';
				IsPrimenum_StartPrimeCalc_1   <= '0';
				IsPrimenum_StartPrimeCalc_2   <= '0';
				IsPrimenum_DataOut            <= X"00000000";
				IsPrimenum_number_param       <= 0;
				IsPrimenum_Primecalc_instance <= x"00";
			else
				case (state_SM_IsPrimeNumber) is
						
					when ST000_IsPrimeNumber =>
						IsPrimenum_WriteEna         <= false;
						IsPrimenum_StartPrimeCalc_0 <= '0';
						IsPrimenum_StartPrimeCalc_1 <= '0';
						IsPrimenum_StartPrimeCalc_2 <= '0';
						if \MemberId\ = 1 and \Started\ = true and IsPrimenum_Finish = false then
								state_SM_IsPrimeNumber <= ST001_IsPrimeNumber;
								IsPrimenum_ReadEna <= true;
								IsPrimenum_ReadAddr <= 2;
								IsPrimenum_Finish  <= false;
						else 
								IsPrimenum_ReadEna  <= false;
						end if;
						
					--@Andris: removed dummy cycle
						
					when ST001_IsPrimeNumber => 
						SimpleMemoryReadUInt32(\DataIn\, IsPrimenum_number_param);   
						if \ReadsDone\ = true then --Wait until \ReadsDone\
							IsPrimenum_ReadEna <= false;
							if state_SM_Primecalculator_0 = ST000_Primecalculator_0 then
								state_SM_IsPrimeNumber <= ST002a_IsPrimeNumber;
							elsif (state_SM_Primecalculator_1 = ST000_Primecalculator_1) then
								state_SM_IsPrimeNumber <= ST002c_IsPrimeNumber;
							elsif (state_SM_Primecalculator_2 = ST000_Primecalculator_2) then
								state_SM_IsPrimeNumber <= ST002e_IsPrimeNumber;
							end if;
						end if;
						                                                                                                               
					when ST002a_IsPrimeNumber =>
						IsPrimenum_StartPrimeCalc_0 <= '1';  
						IsPrimenum_Primecalc_instance <= x"00";
						state_SM_IsPrimeNumber <= ST002b_IsPrimeNumber;
						
					when ST002b_IsPrimeNumber =>
						IsPrimenum_StartPrimeCalc_0 <= '0'; 
						if IsPrimenum_FinishedPrimecalc = '1' then
							state_SM_IsPrimeNumber <= ST003_IsPrimeNumber;
						end if;
						
					when ST002c_IsPrimeNumber =>
						IsPrimenum_StartPrimeCalc_1 <= '1';  
						IsPrimenum_Primecalc_instance <= x"01";
						state_SM_IsPrimeNumber <= ST002d_IsPrimeNumber;
						
					when ST002d_IsPrimeNumber =>
						IsPrimenum_StartPrimeCalc_1 <= '0';
						if IsPrimenum_FinishedPrimecalc = '1' then
							state_SM_IsPrimeNumber <= ST003_IsPrimeNumber;
						end if;
						
					when ST002e_IsPrimeNumber =>
						IsPrimenum_StartPrimeCalc_2 <= '1';  
						IsPrimenum_Primecalc_instance <= x"02";
						state_SM_IsPrimeNumber <= ST002f_IsPrimeNumber;
						
					when ST002f_IsPrimeNumber =>
						IsPrimenum_StartPrimeCalc_2 <= '0';
						if IsPrimenum_FinishedPrimecalc = '1' then
							state_SM_IsPrimeNumber <= ST003_IsPrimeNumber;
						end if;
						
					when ST003_IsPrimeNumber =>
						SimpleMemoryWriteBoolean(\result\, IsPrimenum_DataOut);
						IsPrimenum_WriteAddr <= 2;
						IsPrimenum_WriteEna <= true;
						state_SM_IsPrimeNumber <= ST004_IsPrimeNumber;
						
					--@Andris: removed dummy cycle 
						
					when ST004_IsPrimeNumber =>
						if \WritesDone\ = true then --Wait until \WritesDone\
							IsPrimenum_Finish   <= true;
							IsPrimenum_WriteEna <= false;
						end if;
						
						if \Started\ = false then -- Wait for Started to be pulled back to 0
							state_SM_IsPrimeNumber <= ST000_IsPrimeNumber;
							IsPrimenum_Finish  <= false;
						end if;
						                 
					when others => null;   
						                                    
				end case;     
			end if;
		end if;                                                 
	end process;                                                       
		
	----------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------
		
	--------------------------------------
	-- SM_ArePrimeNumbers STATE MACHINE --
	--------------------------------------
		  
	STM_ArePrimeNumbers: process (\Clock\)
		variable NumOfElements : integer;
	begin
		if (rising_edge(\Clock\)) then
			if \Reset\ = '1' then
				state_SM_ArePrimeNumbers <= ST000_ArePrimeNumbers;
				ArePrimenums_Finish             <= false;
				ArePrimenums_WriteEna           <= false; 
				ArePrimenums_WriteAddr          <= 0;
				ArePrimenums_ReadEna            <= false;
				ArePrimenums_ReadAddr           <= 0;
				ArePrimenums_StartPrimeCalc_0   <= '0';
				ArePrimenums_StartPrimeCalc_1   <= '0';
				ArePrimenums_StartPrimeCalc_2   <= '0';
				\num_incr\                      <= 0;
				\number.iter\                   <= 0;
				ArePrimenums_DataOut            <= X"00000000";
				ArePrimenums_number_param       <= 0;
				ArePrimenums_Primecalc_instance <= x"00";
			else
				case (state_SM_ArePrimeNumbers) is
					when ST000_ArePrimeNumbers =>
						ArePrimenums_WriteEna         <= false;
						ArePrimenums_StartPrimeCalc_0 <= '0';
						ArePrimenums_StartPrimeCalc_1 <= '0';
						ArePrimenums_StartPrimeCalc_2 <= '0';
						\num_incr\ <= 0;
						if \MemberId\ = 2 and \Started\ = true and ArePrimenums_Finish = false then
								state_SM_ArePrimeNumbers <= ST001_ArePrimeNumbers;
								ArePrimenums_ReadEna  <= true;
								ArePrimenums_ReadAddr <= 2;
								ArePrimenums_Finish   <= false;
						else 
								ArePrimenums_ReadEna  <= false;
						end if;
						
					--@Andris: removed dummy cycle
						
					when ST001_ArePrimeNumbers =>
						SimpleMemoryReadUInt32(\DataIn\, \number.iter\);
						if \ReadsDone\ = true then --Wait until \ReadsDone\
							ArePrimenums_ReadEna <= false;
							state_SM_ArePrimeNumbers <= ST002_ArePrimeNumbers;
						end if;
						
					when ST002_ArePrimeNumbers =>
						NumOfElements            :=  \number.iter\;
						state_SM_ArePrimeNumbers <= ST003_ArePrimeNumbers;
						
					when ST003_ArePrimeNumbers =>
						ArePrimenums_ReadAddr <= 2 + 1 + \num_incr\;
						ArePrimenums_ReadEna  <= true;
						state_SM_ArePrimeNumbers <= ST004_ArePrimeNumbers;
						
					--@Andris: removed dummy cycle
						
					when ST004_ArePrimeNumbers =>
						if \ReadsDone\ = true then --Wait until \ReadsDone\
							SimpleMemoryReadUInt32(\DataIn\, ArePrimenums_number_param);
							ArePrimenums_ReadEna <= false;
							if state_SM_Primecalculator_0 = ST000_Primecalculator_0 then
								state_SM_ArePrimeNumbers <= ST005a_ArePrimeNumbers;
							elsif (state_SM_Primecalculator_1 = ST000_Primecalculator_1) then
								state_SM_ArePrimeNumbers <= ST005c_ArePrimeNumbers;
							elsif (state_SM_Primecalculator_2 = ST000_Primecalculator_2) then
								state_SM_ArePrimeNumbers <= ST005e_ArePrimeNumbers;
							end if;  
						end if;    
						
					when ST005a_ArePrimeNumbers =>
						ArePrimenums_StartPrimeCalc_0   <= '1';  
						ArePrimenums_Primecalc_instance <= x"00";
						state_SM_ArePrimeNumbers   <= ST005b_ArePrimeNumbers;
						
					when ST005b_ArePrimeNumbers =>
						ArePrimenums_StartPrimeCalc_0 <= '0';
						if ArePrimenums_FinishedPrimecalc = '1' then 
							state_SM_ArePrimeNumbers <= ST006_ArePrimeNumbers;
						end if;
						
					when ST005c_ArePrimeNumbers =>
						ArePrimenums_StartPrimeCalc_1   <= '1'; 
						ArePrimenums_Primecalc_instance <= x"01";
						state_SM_ArePrimeNumbers <= ST005d_ArePrimeNumbers;
						
					when ST005d_ArePrimeNumbers =>
						ArePrimenums_StartPrimeCalc_1 <= '0';
						if ArePrimenums_FinishedPrimecalc = '1' then
							state_SM_ArePrimeNumbers <= ST006_ArePrimeNumbers;
						end if;
						
					when ST005e_ArePrimeNumbers =>
						ArePrimenums_StartPrimeCalc_2   <= '1'; 
						ArePrimenums_Primecalc_instance <= x"02";
						state_SM_ArePrimeNumbers <= ST005f_ArePrimeNumbers;
						
					when ST005f_ArePrimeNumbers =>
						ArePrimenums_StartPrimeCalc_2   <= '0';
						if ArePrimenums_FinishedPrimecalc = '1' then
							state_SM_ArePrimeNumbers <= ST006_ArePrimeNumbers;
						end if;
						
					when ST006_ArePrimeNumbers =>
						SimpleMemoryWriteBoolean(\result\, ArePrimenums_DataOut);
						ArePrimenums_WriteAddr <= 2 + 1 + \num_incr\;
						ArePrimenums_WriteEna <= true;
						state_SM_ArePrimeNumbers <= ST007_ArePrimeNumbers;
						
					--@Andris: removed dummy cycle
						
					when ST007_ArePrimeNumbers =>
						if \WritesDone\ = true then  --Wait until \WritesDone\
							ArePrimenums_WriteEna <= false;
							state_SM_ArePrimeNumbers <= ST008_ArePrimeNumbers;
							\num_incr\ <= \num_incr\ + 1;
						end if;
						
					when ST008_ArePrimeNumbers =>
						if (\num_incr\ < NumOfElements) then
							state_SM_ArePrimeNumbers <= ST003_ArePrimeNumbers;
						else
							state_SM_ArePrimeNumbers <= ST009_ArePrimeNumbers;
						end if;
						
					when ST009_ArePrimeNumbers =>
						ArePrimenums_Finish   <= true;
						if \Started\ = false then -- Wait for Started to be pulled back to 0
							state_SM_ArePrimeNumbers <= ST000_ArePrimeNumbers;
							ArePrimenums_Finish   <= false;
						end if;
						   
					when others => null;   
					                                    
				end case; 
			end if;    
		end if;                                          
	end process;                                                       
		
		
-- Signal assignments:
--------------------------
		
	\number.param\                 <= IsPrimenum_number_param      when \MemberId\ = 1 else ArePrimenums_number_param;
		
-- These go to the outpit ports of Hast_IP.vhd.
		
	\ReadEnable\                   <= IsPrimenum_ReadEna           when \MemberId\ = 1 else ArePrimenums_ReadEna; 
	\WriteEnable\                  <= IsPrimenum_WriteEna          when \MemberId\ = 1 else ArePrimenums_WriteEna;
		
-- \CellIndex\ will set Hast_IP_Read_Addr_out in case of \ReadEnable\ = '1' or Hast_IP_Write_Addr_out in case of \WriteEnable\ = '1'. This has been made in the Hast_ip_wrapper.vhd,
-- in the Read_Write_Address_Choice process.  
		
	\CellIndex\                 <= IsPrimenum_ReadAddr          when \MemberId\ = 1 and IsPrimenum_ReadEna    = true else
								   IsPrimenum_WriteAddr         when \MemberId\ = 1 and IsPrimenum_WriteEna   = true else
								   ArePrimenums_ReadAddr        when \MemberId\ = 2 and ArePrimenums_ReadEna  = true else
								   ArePrimenums_WriteAddr       when \MemberId\ = 2 and ArePrimenums_WriteEna = true else 0; 
	--\CellIndex\                 <= IsPrimenum_WriteAddr         when \MemberId\ = 1 else ArePrimenums_WriteAddr;
		
-- These go to the output ports of Hast_IP.vhd.
		
	\DataOut\                      <= IsPrimenum_DataOut           when \MemberId\ = 1 else ArePrimenums_DataOut;
	\Finished\                     <= IsPrimenum_Finish            when \MemberId\ = 1 else ArePrimenums_Finish;
		
-- StartPrimeCalculator_0 is controlled by the other State Machines' states (SM_IsPrimeNumber or SM_ArePrimeNumbers based on \MemberId\). 
-- As there are 3 SM_Primecalculator_x State Machines, we have to use separate StartPrimeCalculator_x signals (If we used the same signal, Vivado would throw an error message which says "multiple driven signal...")
-- The SM_IsPrimeNumber and SM_ArePrimeNumbers State machines also have to set different signals, othervise it leads to an error. 
-- So IsPrimenum_StartPrimeCalc_x are set by SM_IsPrimeNumber states, and ArePrimenums_StartPrimeCalc_x are set by SM_ArePrimeNumbers State Machine.
		
	StartPrimeCalculator_0         <= IsPrimenum_StartPrimeCalc_0  when \MemberId\ = 1 else ArePrimenums_StartPrimeCalc_0;
	StartPrimeCalculator_1         <= IsPrimenum_StartPrimeCalc_1  when \MemberId\ = 1 else ArePrimenums_StartPrimeCalc_1;
	StartPrimeCalculator_2         <= IsPrimenum_StartPrimeCalc_2  when \MemberId\ = 1 else ArePrimenums_StartPrimeCalc_2;
		
-- Primecalc_Finished_x signs that the SM_Primecalculator_x finished with its operation. This is needed for the SM_IsPrimeNumber and SM_ArePrimeNumbers 
-- State Machines (based on MethodID) to go to the next state. 
-- As there are multiple "instances" of SM_Primecalculator_x, and both SM_IsPrimeNumber or SM_ArePrimeNumbers can "start" them, we have to know which instance runs (IsPrimenum_Primecalc_instance), and when it finished (Primecalc_Finished_0)
		
	IsPrimenum_FinishedPrimecalc   <= Primecalc_Finished_0 when \MemberId\ = 1 and IsPrimenum_Primecalc_instance = x"00" else
									  Primecalc_Finished_1 when \MemberId\ = 1 and IsPrimenum_Primecalc_instance = x"01" else
									  Primecalc_Finished_2 when \MemberId\ = 1 and IsPrimenum_Primecalc_instance = x"02" else '0';
		
	ArePrimenums_FinishedPrimecalc <= Primecalc_Finished_0 when \MemberId\ = 2 and ArePrimenums_Primecalc_instance = x"00" else           
									  Primecalc_Finished_1 when \MemberId\ = 2 and ArePrimenums_Primecalc_instance = x"01" else
									  Primecalc_Finished_2 when \MemberId\ = 2 and ArePrimenums_Primecalc_instance = x"02" else '0';
		
-- \result\ comes from one of the three SM_Primecalculator_x State Machines' \result_x\ signal. We run the same SM_Primecalculator_x State Machine when ie. the 
-- IsPrimenum_Primecalc_instance = x"00" or ArePrimenums_Primecalc_instance = x"00", so we have to assign the \result_0\ to \result\.
		  
	\result\                       <= \result_0\ when IsPrimenum_Primecalc_instance = x"00" or ArePrimenums_Primecalc_instance = x"00" else
									  \result_1\ when IsPrimenum_Primecalc_instance = x"01" or ArePrimenums_Primecalc_instance = x"01" else
									  \result_2\ when IsPrimenum_Primecalc_instance = x"02" or ArePrimenums_Primecalc_instance = x"02" else '0'; 
									  
		
end Imp;                                                      
                                                                                      
                                                              
                                                              