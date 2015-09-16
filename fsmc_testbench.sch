<?xml version="1.0" encoding="UTF-8"?>
<drawing version="7">
    <attr value="spartan6" name="DeviceFamilyName">
        <trait delete="all:0" />
        <trait editname="all:0" />
        <trait edittrait="all:0" />
    </attr>
    <netlist>
        <signal name="XLXN_22" />
        <signal name="XLXN_23" />
        <signal name="XLXN_24" />
        <signal name="XLXN_25" />
        <signal name="XLXN_26" />
        <signal name="XLXN_27(15:0)" />
        <signal name="XLXN_28(1:0)" />
        <signal name="XLXN_29(15:0)" />
        <signal name="XLXN_30" />
        <signal name="XLXN_31" />
        <signal name="XLXN_32(15:0)" />
        <signal name="XLXN_33(15:0)" />
        <signal name="XLXN_34" />
        <signal name="XLXN_35(1:0)" />
        <signal name="XLXN_36(15:0)" />
        <signal name="XLXN_37" />
        <port polarity="Input" name="XLXN_22" />
        <blockdef name="fsmc2bram">
            <timestamp>2015-9-16T13:18:41</timestamp>
            <rect width="320" x="64" y="-448" height="440" />
            <line x2="0" y1="-416" y2="-416" x1="64" />
            <line x2="0" y1="-352" y2="-352" x1="64" />
            <line x2="0" y1="-288" y2="-288" x1="64" />
            <line x2="0" y1="-224" y2="-224" x1="64" />
            <rect width="64" x="0" y="-172" height="24" />
            <line x2="0" y1="-160" y2="-160" x1="64" />
            <rect width="64" x="0" y="-108" height="24" />
            <line x2="0" y1="-96" y2="-96" x1="64" />
            <line x2="448" y1="-416" y2="-416" x1="384" />
            <rect width="64" x="384" y="-332" height="24" />
            <line x2="448" y1="-320" y2="-320" x1="384" />
            <rect width="64" x="384" y="-236" height="24" />
            <line x2="448" y1="-224" y2="-224" x1="384" />
            <rect width="64" x="384" y="-140" height="24" />
            <line x2="448" y1="-128" y2="-128" x1="384" />
            <rect width="64" x="384" y="-76" height="24" />
            <line x2="384" y1="-64" y2="-64" x1="448" />
            <line x2="64" y1="-32" y2="-32" x1="0" />
            <rect width="64" x="0" y="-44" height="24" />
        </blockdef>
        <blockdef name="fsmc_stimuly">
            <timestamp>2015-9-16T13:4:27</timestamp>
            <rect width="256" x="64" y="-448" height="448" />
            <line x2="384" y1="-416" y2="-416" x1="320" />
            <line x2="384" y1="-352" y2="-352" x1="320" />
            <line x2="384" y1="-288" y2="-288" x1="320" />
            <line x2="384" y1="-224" y2="-224" x1="320" />
            <rect width="64" x="320" y="-172" height="24" />
            <line x2="384" y1="-160" y2="-160" x1="320" />
            <rect width="64" x="320" y="-108" height="24" />
            <line x2="384" y1="-96" y2="-96" x1="320" />
            <rect width="64" x="320" y="-44" height="24" />
            <line x2="384" y1="-32" y2="-32" x1="320" />
        </blockdef>
        <blockdef name="bram">
            <timestamp>2015-9-16T13:12:2</timestamp>
            <rect width="512" x="32" y="32" height="1344" />
            <line x2="32" y1="80" y2="80" style="linewidth:W" x1="0" />
            <line x2="32" y1="112" y2="112" style="linewidth:W" x1="0" />
            <line x2="32" y1="144" y2="144" x1="0" />
            <line x2="32" y1="208" y2="208" style="linewidth:W" x1="0" />
            <line x2="32" y1="272" y2="272" x1="0" />
            <line x2="32" y1="432" y2="432" style="linewidth:W" x1="0" />
            <line x2="32" y1="464" y2="464" style="linewidth:W" x1="0" />
            <line x2="32" y1="496" y2="496" x1="0" />
            <line x2="32" y1="560" y2="560" style="linewidth:W" x1="0" />
            <line x2="32" y1="624" y2="624" x1="0" />
            <line x2="544" y1="80" y2="80" style="linewidth:W" x1="576" />
            <line x2="544" y1="368" y2="368" style="linewidth:W" x1="576" />
        </blockdef>
        <block symbolname="fsmc_stimuly" name="stimuly">
            <blockpin signalname="XLXN_37" name="clk" />
            <blockpin signalname="XLXN_24" name="NCE" />
            <blockpin signalname="XLXN_26" name="NWE" />
            <blockpin signalname="XLXN_25" name="NOE" />
            <blockpin signalname="XLXN_27(15:0)" name="A(15:0)" />
            <blockpin signalname="XLXN_28(1:0)" name="NBL(1:0)" />
            <blockpin signalname="XLXN_29(15:0)" name="D(15:0)" />
        </block>
        <block symbolname="fsmc2bram" name="glue">
            <blockpin signalname="XLXN_37" name="hclk" />
            <blockpin signalname="XLXN_26" name="NWE" />
            <blockpin signalname="XLXN_25" name="NOE" />
            <blockpin signalname="XLXN_24" name="NCE" />
            <blockpin signalname="XLXN_27(15:0)" name="A(15:0)" />
            <blockpin signalname="XLXN_28(1:0)" name="NBL(1:0)" />
            <blockpin signalname="XLXN_34" name="bram_en" />
            <blockpin signalname="XLXN_32(15:0)" name="bram_a(15:0)" />
            <blockpin signalname="XLXN_33(15:0)" name="bram_di(15:0)" />
            <blockpin signalname="XLXN_35(1:0)" name="bram_we(1:0)" />
            <blockpin signalname="XLXN_36(15:0)" name="bram_do(15:0)" />
            <blockpin signalname="XLXN_29(15:0)" name="D(15:0)" />
        </block>
        <block symbolname="bram" name="bram_x">
            <blockpin signalname="XLXN_32(15:0)" name="addra(15:0)" />
            <blockpin signalname="XLXN_33(15:0)" name="dina(15:0)" />
            <blockpin signalname="XLXN_34" name="ena" />
            <blockpin signalname="XLXN_35(1:0)" name="wea(1:0)" />
            <blockpin signalname="XLXN_37" name="clka" />
            <blockpin name="addrb(15:0)" />
            <blockpin name="dinb(15:0)" />
            <blockpin name="enb" />
            <blockpin name="web(1:0)" />
            <blockpin signalname="XLXN_22" name="clkb" />
            <blockpin signalname="XLXN_36(15:0)" name="douta(15:0)" />
            <blockpin name="doutb(15:0)" />
        </block>
    </netlist>
    <sheet sheetnum="1" width="3801" height="2688">
        <attr value="CM" name="LengthUnitName" />
        <attr value="4" name="GridsPerUnit" />
        <instance x="272" y="896" name="stimuly" orien="R0">
        </instance>
        <branch name="XLXN_22">
            <wire x2="1584" y1="1280" y2="1280" x1="1568" />
            <wire x2="1632" y1="1040" y2="1040" x1="1584" />
            <wire x2="1584" y1="1040" y2="1280" x1="1584" />
        </branch>
        <iomarker fontsize="28" x="1568" y="1280" name="XLXN_22" orien="R180" />
        <instance x="832" y="896" name="glue" orien="R0">
        </instance>
        <branch name="XLXN_24">
            <wire x2="736" y1="544" y2="544" x1="656" />
            <wire x2="736" y1="544" y2="672" x1="736" />
            <wire x2="832" y1="672" y2="672" x1="736" />
        </branch>
        <branch name="XLXN_25">
            <wire x2="720" y1="672" y2="672" x1="656" />
            <wire x2="720" y1="608" y2="672" x1="720" />
            <wire x2="832" y1="608" y2="608" x1="720" />
        </branch>
        <branch name="XLXN_26">
            <wire x2="704" y1="608" y2="608" x1="656" />
            <wire x2="816" y1="576" y2="576" x1="704" />
            <wire x2="704" y1="576" y2="608" x1="704" />
            <wire x2="832" y1="544" y2="544" x1="816" />
            <wire x2="816" y1="544" y2="576" x1="816" />
        </branch>
        <branch name="XLXN_27(15:0)">
            <wire x2="832" y1="736" y2="736" x1="656" />
        </branch>
        <branch name="XLXN_28(1:0)">
            <wire x2="832" y1="800" y2="800" x1="656" />
        </branch>
        <branch name="XLXN_29(15:0)">
            <wire x2="832" y1="864" y2="864" x1="656" />
        </branch>
        <instance x="1632" y="416" name="bram_x" orien="R0">
        </instance>
        <branch name="XLXN_32(15:0)">
            <wire x2="1456" y1="576" y2="576" x1="1280" />
            <wire x2="1456" y1="496" y2="576" x1="1456" />
            <wire x2="1632" y1="496" y2="496" x1="1456" />
        </branch>
        <branch name="XLXN_33(15:0)">
            <wire x2="1472" y1="672" y2="672" x1="1280" />
            <wire x2="1472" y1="528" y2="672" x1="1472" />
            <wire x2="1632" y1="528" y2="528" x1="1472" />
        </branch>
        <branch name="XLXN_34">
            <wire x2="1536" y1="480" y2="480" x1="1280" />
            <wire x2="1536" y1="480" y2="560" x1="1536" />
            <wire x2="1632" y1="560" y2="560" x1="1536" />
        </branch>
        <branch name="XLXN_35(1:0)">
            <wire x2="1488" y1="768" y2="768" x1="1280" />
            <wire x2="1488" y1="624" y2="768" x1="1488" />
            <wire x2="1632" y1="624" y2="624" x1="1488" />
        </branch>
        <branch name="XLXN_36(15:0)">
            <wire x2="1440" y1="832" y2="832" x1="1280" />
            <wire x2="1440" y1="384" y2="832" x1="1440" />
            <wire x2="2272" y1="384" y2="384" x1="1440" />
            <wire x2="2272" y1="384" y2="496" x1="2272" />
            <wire x2="2272" y1="496" y2="496" x1="2208" />
        </branch>
        <branch name="XLXN_37">
            <wire x2="784" y1="480" y2="480" x1="656" />
            <wire x2="832" y1="480" y2="480" x1="784" />
            <wire x2="1600" y1="272" y2="272" x1="784" />
            <wire x2="1600" y1="272" y2="688" x1="1600" />
            <wire x2="1632" y1="688" y2="688" x1="1600" />
            <wire x2="784" y1="272" y2="480" x1="784" />
        </branch>
    </sheet>
</drawing>