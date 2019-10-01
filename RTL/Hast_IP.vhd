-- Generated by Hastlayer (hastlayer.com) at 2019-10-01 11:35:51 UTC for the following hardware entry points: 
-- * System.Void Hast.Samples.SampleAssembly.Loopback::Run(Hast.Transformer.Abstractions.SimpleMemory.SimpleMemory)

-- VHDL libraries necessary for the generated code to work. These libraries are included here instead of being managed separately in the Hardware Framework so they can be more easily updated.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package TypeConversion is
    function SmartResize(input: unsigned; size: natural) return unsigned;
    function SmartResize(input: signed; size: natural) return signed;
    function ToUnsignedAndExpand(input: signed; size: natural) return unsigned;
end TypeConversion;
        
package body TypeConversion is

    -- The .NET behavior is different than that of resize() ("To create a larger vector, the new [leftmost] bit 
    -- positions are filled with the sign bit(ARG'LEFT). When truncating, the sign bit is retained along with the 
    -- rightmost part.") when casting to a smaller type: "If the source type is larger than the destination type, 
    -- then the source value is truncated by discarding its "extra" most significant bits. The result is then 
    -- treated as a value of the destination type." Thus we need to simply truncate when casting down. See:
    -- https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/language-specification/conversions
    function SmartResize(input: unsigned; size: natural) return unsigned is
    begin
        if (size < input'LENGTH) then
            return input(size - 1 downto 0);
        else
            -- Resize() is supposed to work with little endian numbers: "When truncating, the sign bit is retained
            -- along with the rightmost part." for signed numbers and "When truncating, the leftmost bits are 
            -- dropped." for unsigned ones. See: http://www.csee.umbc.edu/portal/help/VHDL/numeric_std.vhdl
            return resize(input, size);
        end if;
    end SmartResize;

    function SmartResize(input: signed; size: natural) return signed is
    begin
        if (size < input'LENGTH) then
            return input(size - 1 downto 0);
        else
            return resize(input, size);
        end if;
    end SmartResize;

    function ToUnsignedAndExpand(input: signed; size: natural) return unsigned is
        variable result: unsigned(size - 1 downto 0);
    begin
        if (input >= 0) then
            return resize(unsigned(input), size);
        else 
            result := (others => '1');
            result(input'LENGTH - 1 downto 0) := unsigned(input);
            return result;
        end if;
    end ToUnsignedAndExpand;

end TypeConversion;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
        
package SimpleMemory is
    -- Data conversion functions:
    function ConvertUInt32ToStdLogicVector(input: unsigned(31 downto 0)) return std_logic_vector;
    function ConvertStdLogicVectorToUInt32(input : std_logic_vector) return unsigned;
        
    function ConvertBooleanToStdLogicVector(input: boolean) return std_logic_vector;
    function ConvertStdLogicVectorToBoolean(input : std_logic_vector) return boolean;
        
    function ConvertInt32ToStdLogicVector(input: signed(31 downto 0)) return std_logic_vector;
    function ConvertStdLogicVectorToInt32(input : std_logic_vector) return signed;
end SimpleMemory;
        
package body SimpleMemory is

    function ConvertUInt32ToStdLogicVector(input: unsigned(31 downto 0)) return std_logic_vector is
    begin
        return std_logic_vector(input);
    end ConvertUInt32ToStdLogicVector;
    
    function ConvertStdLogicVectorToUInt32(input : std_logic_vector) return unsigned is
    begin
        return unsigned(input);
    end ConvertStdLogicVectorToUInt32;
    
    function ConvertBooleanToStdLogicVector(input: boolean) return std_logic_vector is 
    begin
        case input is
            when true => return X"FFFFFFFF";
            when false => return X"00000000";
            when others => return X"00000000";
        end case;
    end ConvertBooleanToStdLogicVector;

    function ConvertStdLogicVectorToBoolean(input : std_logic_vector) return boolean is 
    begin
        -- In .NET a false is all zeros while a true is at least one 1 bit (or more), so using the same logic here.
        return not(input = X"00000000");
    end ConvertStdLogicVectorToBoolean;

    function ConvertInt32ToStdLogicVector(input: signed(31 downto 0)) return std_logic_vector is
    begin
        return std_logic_vector(input);
    end ConvertInt32ToStdLogicVector;

    function ConvertStdLogicVectorToInt32(input : std_logic_vector) return signed is
    begin
        return signed(input);
    end ConvertStdLogicVectorToInt32;

end SimpleMemory;

-- Hast_IP, logic generated from the input .NET assemblies starts here.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.TypeConversion.all;
library work;
use work.SimpleMemory.all;

entity Hast_IP is 
    port(
        \DataIn\: In std_logic_vector(511 downto 0);
        \DataOut\: Out std_logic_vector(511 downto 0);
        \CellIndex\: Out integer;
        \ReadEnable\: Out boolean;
        \WriteEnable\: Out boolean;
        \ReadsDone\: In boolean;
        \WritesDone\: In boolean;
        \MemberId\: In integer;
        \Reset\: In std_logic;
        \Started\: In boolean;
        \Finished\: Out boolean;
        \Clock\: In std_logic
    );
    -- Hast_IP ID: 694ce5b6e774533122eda1ea2a77e91bbca50b0610100a8de3abf5b02022e5c6
    -- Date and time: 2019-10-01 11:35:51 UTC
    -- Generated by Hastlayer - hastlayer.com

    -- Hast_IP's simple interface makes it suitable to plug it into any hardware implementation. The meaning and usage of the ports are as below:
    -- * MemberId: Each transformed .NET hardware entry point member (i.e. methods that are configured to be available to be called from the host PC) has a unique zero-based numeric ID. When selecting which one to execute this ID should be used. 
    -- * Started: Indicates whether the execution of a given hardware entry point member is started. Used in the following way:
    --     1. Started is set to TRUE by the consuming framework, after which the execution of the given member starts internally. The Finished port will be initially set to FALSE.
    --     2. Once the execution is finished, the Finished port will be set to TRUE.
    --     3. The consuming framework sets Started to FALSE, after which Finished will also be set to FALSE.
    -- * Finished: Indicates whether the execution of a given hardware entry point member is complete. See the documentation of the Started port above on how it is used.
    -- * Reset: Synchronous reset.
    -- * Clock: The main clock.
    -- * DataIn: Data read out from the memory (usually on-board DDR RAM, but depends on the framework) should be assigned to this port by the framework. The width of this port depends on the hardware platform but is at least 32b. Inputs of the algorithm implemented in Hast_IP all come through this port.
    -- * DataOut: Data to be written to the memory is assigned to this port. The width of this port depends on the hardware platform but is at least 32b. Outputs of the algorithm implemented in Hast_IP all go through this port.
    -- * CellIndex: Zero-based index of the SimpleMemory memory cell currently being read or written. Transformed code in Hastlayer can access memory in a simplified fashion by addressing 32b "cells", the accessible physical memory space being divided up in such individually addressable cells. The value of CellIndex is always aligned to the width of the DataIn and DataOut ports, so e.g. with 128b data ports CellIndex will always contain a value which is a >= 0 integer multiple of 4 (since 128 / 32 = 4).
    -- * ReadEnable: Indicates whether a memory read operation is initiated. The process of a memory read is as following:
    --     1. ReadEnable is FALSE by default. It's set to TRUE when a memory read is started. CellIndex is set to the index of the memory cell to be read out.
    --     2. Waiting for ReadsDone to be TRUE.
    --     3. Once ReadsDone is TRUE, data from DataIn will be read out and ReadEnable set to FALSE.
    -- * WriteEnable: Indicates whether a memory write operation is initiated. The process of a memory write is as following:
    --     1. WriteEnable is FALSE by default. It's set to TRUE when a memory write is started. CellIndex is set to the index of the memory cell to be written and the output data is assigned to DataOut.
    --     2. Waiting for WritesDone to be TRUE.
    --     3. Once WritesDone is TRUE, WriteEnable is set to FALSE.
    -- * ReadsDone: Indicates whether a memory read operation is completed.
    -- * WritesDone: Indicates whether a memory write operation is completed.

end Hast_IP;

architecture Imp of Hast_IP is 
    -- This IP was generated by Hastlayer from .NET code to mimic the original logic. Note the following:
    -- * For each member (methods, functions, properties) in .NET a state machine was generated. Each state machine's name corresponds to 
    --   the original member's name.
    -- * Inputs and outputs are passed between state machines as shared objects.
    -- * There are operations that take multiple clock cycles like interacting with the memory and long-running arithmetic operations 
    --   (modulo, division, multiplication). These are awaited in subsequent states but be aware that some states can take more 
    --   than one clock cycle to produce their output.
    -- * The ExternalInvocationProxy process dispatches invocations that were started from the outside to the state machines.
    -- * The InternalInvocationProxy processes dispatch invocations between state machines.

    -- System.Void Hast.Samples.SampleAssembly.Loopback::Run(Hast.Transformer.Abstractions.SimpleMemory.SimpleMemory).0 declarations start
    -- State machine states:
    type \Loopback::Run(SimpleMemory).0._States\ is (
        \Loopback::Run(SimpleMemory).0._State_0\, 
        \Loopback::Run(SimpleMemory).0._State_1\, 
        \Loopback::Run(SimpleMemory).0._State_2\, 
        \Loopback::Run(SimpleMemory).0._State_3\, 
        \Loopback::Run(SimpleMemory).0._State_4\);
    -- Signals:
    Signal \Loopback::Run(SimpleMemory).0._Finished\: boolean := false;
    Signal \Loopback::Run(SimpleMemory).0.SimpleMemory.CellIndex\: signed(31 downto 0) := to_signed(0, 32);
    Signal \Loopback::Run(SimpleMemory).0.SimpleMemory.DataOut\: std_logic_vector(511 downto 0) := (others => '0');
    Signal \Loopback::Run(SimpleMemory).0.SimpleMemory.ReadEnable\: boolean := false;
    Signal \Loopback::Run(SimpleMemory).0.SimpleMemory.WriteEnable\: boolean := false;
    Signal \Loopback::Run(SimpleMemory).0._Started\: boolean := false;
    -- System.Void Hast.Samples.SampleAssembly.Loopback::Run(Hast.Transformer.Abstractions.SimpleMemory.SimpleMemory).0 declarations end


    -- System.Void Hast::ExternalInvocationProxy() declarations start
    -- Signals:
    Signal \FinishedInternal\: boolean := false;
    Signal \Hast::ExternalInvocationProxy().Loopback::Run(SimpleMemory)._Started.0\: boolean := false;
    Signal \Hast::ExternalInvocationProxy().Loopback::Run(SimpleMemory)._Finished.0\: boolean := false;
    -- System.Void Hast::ExternalInvocationProxy() declarations end


    -- \System.Void Hast::InternalInvocationProxy()._CommonDeclarations\ declarations start
    type \InternalInvocationProxy_boolean_Array\ is array (integer range <>) of boolean;
    type \Hast::InternalInvocationProxy()._RunningStates\ is (
        WaitingForStarted, 
        WaitingForFinished, 
        AfterFinished);
    -- \System.Void Hast::InternalInvocationProxy()._CommonDeclarations\ declarations end

begin 

    -- System.Void Hast.Samples.SampleAssembly.Loopback::Run(Hast.Transformer.Abstractions.SimpleMemory.SimpleMemory).0 state machine start
    \Loopback::Run(SimpleMemory).0._StateMachine\: process (\Clock\) 
        Variable \Loopback::Run(SimpleMemory).0._State\: \Loopback::Run(SimpleMemory).0._States\ := \Loopback::Run(SimpleMemory).0._State_0\;
        Variable \Loopback::Run(SimpleMemory).0.dataIn.0\: std_logic_vector(511 downto 0) := (others => '0');
        Variable \Loopback::Run(SimpleMemory).0.binaryOperationResult.0\: signed(31 downto 0) := to_signed(0, 32);
    begin 
        if (rising_edge(\Clock\)) then 
            if (\Reset\ = '1') then 
                -- Synchronous reset
                \Loopback::Run(SimpleMemory).0._Finished\ <= false;
                \Loopback::Run(SimpleMemory).0.SimpleMemory.CellIndex\ <= to_signed(0, 32);
                \Loopback::Run(SimpleMemory).0.SimpleMemory.DataOut\ <= (others => '0');
                \Loopback::Run(SimpleMemory).0.SimpleMemory.ReadEnable\ <= false;
                \Loopback::Run(SimpleMemory).0.SimpleMemory.WriteEnable\ <= false;
                \Loopback::Run(SimpleMemory).0._State\ := \Loopback::Run(SimpleMemory).0._State_0\;
                \Loopback::Run(SimpleMemory).0.dataIn.0\ := (others => '0');
                \Loopback::Run(SimpleMemory).0.binaryOperationResult.0\ := to_signed(0, 32);
            else 
                case \Loopback::Run(SimpleMemory).0._State\ is 
                    when \Loopback::Run(SimpleMemory).0._State_0\ => 
                        -- Start state
                        -- Waiting for the start signal.
                        if (\Loopback::Run(SimpleMemory).0._Started\ = true) then 
                            \Loopback::Run(SimpleMemory).0._State\ := \Loopback::Run(SimpleMemory).0._State_2\;
                        end if;
                        -- Clock cycles needed to complete this state (approximation): 0
                    when \Loopback::Run(SimpleMemory).0._State_1\ => 
                        -- Final state
                        -- Signaling finished until Started is pulled back to false, then returning to the start state.
                        if (\Loopback::Run(SimpleMemory).0._Started\ = true) then 
                            \Loopback::Run(SimpleMemory).0._Finished\ <= true;
                        else 
                            \Loopback::Run(SimpleMemory).0._Finished\ <= false;
                            \Loopback::Run(SimpleMemory).0._State\ := \Loopback::Run(SimpleMemory).0._State_0\;
                        end if;
                        -- Clock cycles needed to complete this state (approximation): 0
                    when \Loopback::Run(SimpleMemory).0._State_2\ => 
                        -- The following section was transformed from the .NET statement below:
                        -- memory.WriteInt32 (0, memory.ReadInt32 (0) + 1);
                        -- 
                        -- Begin SimpleMemory read.
                        \Loopback::Run(SimpleMemory).0.SimpleMemory.CellIndex\ <= resize(to_signed(0, 32), 32);
                        \Loopback::Run(SimpleMemory).0.SimpleMemory.ReadEnable\ <= true;
                        \Loopback::Run(SimpleMemory).0._State\ := \Loopback::Run(SimpleMemory).0._State_3\;
                        -- Clock cycles needed to complete this state (approximation): 0
                    when \Loopback::Run(SimpleMemory).0._State_3\ => 
                        -- Waiting for the SimpleMemory operation to finish.
                        if (\ReadsDone\ = true) then 
                            -- SimpleMemory read finished.
                            \Loopback::Run(SimpleMemory).0.SimpleMemory.ReadEnable\ <= false;
                            \Loopback::Run(SimpleMemory).0.dataIn.0\ := \DataIn\;
                            \Loopback::Run(SimpleMemory).0.binaryOperationResult.0\ := ConvertStdLogicVectorToInt32(\Loopback::Run(SimpleMemory).0.dataIn.0\(31 downto 0)) + to_signed(1, 32);
                            -- Begin SimpleMemory write.
                            \Loopback::Run(SimpleMemory).0.SimpleMemory.CellIndex\ <= resize(to_signed(0, 32), 32);
                            \Loopback::Run(SimpleMemory).0.SimpleMemory.WriteEnable\ <= true;
                            \Loopback::Run(SimpleMemory).0.SimpleMemory.DataOut\(31 downto 0) <= ConvertInt32ToStdLogicVector(\Loopback::Run(SimpleMemory).0.binaryOperationResult.0\);
                            \Loopback::Run(SimpleMemory).0._State\ := \Loopback::Run(SimpleMemory).0._State_4\;
                        end if;
                        -- Clock cycles needed to complete this state (approximation): 0.3981
                    when \Loopback::Run(SimpleMemory).0._State_4\ => 
                        -- Waiting for the SimpleMemory operation to finish.
                        if (\WritesDone\ = true) then 
                            -- SimpleMemory write finished.
                            \Loopback::Run(SimpleMemory).0.SimpleMemory.WriteEnable\ <= false;
                            \Loopback::Run(SimpleMemory).0._State\ := \Loopback::Run(SimpleMemory).0._State_1\;
                        end if;
                        -- Clock cycles needed to complete this state (approximation): 0
                end case;
            end if;
        end if;
    end process;
    -- System.Void Hast.Samples.SampleAssembly.Loopback::Run(Hast.Transformer.Abstractions.SimpleMemory.SimpleMemory).0 state machine end


    -- System.Void Hast::ExternalInvocationProxy() start
    \Finished\ <= \FinishedInternal\;
    \Hast::ExternalInvocationProxy()\: process (\Clock\) 
    begin 
        if (rising_edge(\Clock\)) then 
            if (\Reset\ = '1') then 
                -- Synchronous reset
                \FinishedInternal\ <= false;
                \Hast::ExternalInvocationProxy().Loopback::Run(SimpleMemory)._Started.0\ <= false;
            else 
                if (\Started\ = true and \FinishedInternal\ = false) then 
                    -- Starting the state machine corresponding to the given member ID.
                    case \MemberId\ is 
                        when 0 => 
                            if (\Hast::ExternalInvocationProxy().Loopback::Run(SimpleMemory)._Started.0\ = false) then 
                                \Hast::ExternalInvocationProxy().Loopback::Run(SimpleMemory)._Started.0\ <= true;
                            elsif (\Hast::ExternalInvocationProxy().Loopback::Run(SimpleMemory)._Started.0\ = \Hast::ExternalInvocationProxy().Loopback::Run(SimpleMemory)._Finished.0\) then 
                                \Hast::ExternalInvocationProxy().Loopback::Run(SimpleMemory)._Started.0\ <= false;
                                \FinishedInternal\ <= true;
                            end if;
                        when others => 
                            null;
                    end case;
                else 
                    -- Waiting for Started to be pulled back to zero that signals the framework noting the finish.
                    if (\Started\ = false and \FinishedInternal\ = true) then 
                        \FinishedInternal\ <= false;
                    end if;
                end if;
            end if;
        end if;
    end process;
    -- System.Void Hast::ExternalInvocationProxy() end


    -- System.Void Hast::InternalInvocationProxy().System.Void Hast.Samples.SampleAssembly.Loopback::Run(Hast.Transformer.Abstractions.SimpleMemory.SimpleMemory) start
    -- Signal connections for System.Void Hast::ExternalInvocationProxy() (#0):
    \Loopback::Run(SimpleMemory).0._Started\ <= \Hast::ExternalInvocationProxy().Loopback::Run(SimpleMemory)._Started.0\;
    \Hast::ExternalInvocationProxy().Loopback::Run(SimpleMemory)._Finished.0\ <= \Loopback::Run(SimpleMemory).0._Finished\;
    -- System.Void Hast::InternalInvocationProxy().System.Void Hast.Samples.SampleAssembly.Loopback::Run(Hast.Transformer.Abstractions.SimpleMemory.SimpleMemory) end


    -- System.Void Hast::SimpleMemoryOperationProxy() start
    \CellIndex\ <= to_integer(\Loopback::Run(SimpleMemory).0.SimpleMemory.CellIndex\) when \Loopback::Run(SimpleMemory).0.SimpleMemory.ReadEnable\ or \Loopback::Run(SimpleMemory).0.SimpleMemory.WriteEnable\ else 0;
    \DataOut\ <= \Loopback::Run(SimpleMemory).0.SimpleMemory.DataOut\ when \Loopback::Run(SimpleMemory).0.SimpleMemory.WriteEnable\ else (others => '0');
    \ReadEnable\ <= \Loopback::Run(SimpleMemory).0.SimpleMemory.ReadEnable\;
    \WriteEnable\ <= \Loopback::Run(SimpleMemory).0.SimpleMemory.WriteEnable\;
    -- System.Void Hast::SimpleMemoryOperationProxy() end

end Imp;
