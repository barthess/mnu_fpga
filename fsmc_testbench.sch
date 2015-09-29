<?xml version="1.0" encoding="UTF-8"?>
<drawing version="7">
    <attr value="spartan6" name="DeviceFamilyName">
        <trait delete="all:0" />
        <trait editname="all:0" />
        <trait edittrait="all:0" />
    </attr>
    <netlist>
        <signal name="XLXN_22" />
        <signal name="XLXN_24" />
        <signal name="XLXN_25" />
        <signal name="XLXN_26" />
        <signal name="XLXN_27(15:0)" />
        <signal name="XLXN_28(1:0)" />
        <signal name="XLXN_29(15:0)" />
        <signal name="XLXN_32(15:0)" />
        <signal name="XLXN_33(15:0)" />
        <signal name="XLXN_34" />
        <signal name="XLXN_35(1:0)" />
        <signal name="XLXN_38(15:0)" />
        <signal name="XLXN_70" />
        <port polarity="Input" name="XLXN_22" />
        <blockdef name="fsmc2bram">
            <timestamp>2015-9-24T13:50:22</timestamp>
            <rect width="320" x="64" y="-448" height="448" />
            <line x2="0" y1="-416" y2="-416" x1="64" />
            <line x2="0" y1="-352" y2="-352" x1="64" />
            <line x2="0" y1="-288" y2="-288" x1="64" />
            <line x2="0" y1="-224" y2="-224" x1="64" />
            <rect width="64" x="0" y="-172" height="24" />
            <line x2="0" y1="-160" y2="-160" x1="64" />
            <rect width="64" x="0" y="-108" height="24" />
            <line x2="0" y1="-96" y2="-96" x1="64" />
            <rect width="64" x="0" y="-44" height="24" />
            <line x2="0" y1="-32" y2="-32" x1="64" />
            <line x2="448" y1="-416" y2="-416" x1="384" />
            <rect width="64" x="384" y="-332" height="24" />
            <line x2="448" y1="-320" y2="-320" x1="384" />
            <rect width="64" x="384" y="-236" height="24" />
            <line x2="448" y1="-224" y2="-224" x1="384" />
            <rect width="64" x="384" y="-140" height="24" />
            <line x2="448" y1="-128" y2="-128" x1="384" />
            <rect width="64" x="384" y="-44" height="24" />
            <line x2="448" y1="-32" y2="-32" x1="384" />
        </blockdef>
        <blockdef name="fsmc_stimuly">
            <timestamp>2015-9-21T18:38:51</timestamp>
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
            <timestamp>2015-9-29T6:43:28</timestamp>
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
            <blockpin signalname="XLXN_70" name="clk" />
            <blockpin signalname="XLXN_24" name="NCE" />
            <blockpin signalname="XLXN_26" name="NWE" />
            <blockpin signalname="XLXN_25" name="NOE" />
            <blockpin signalname="XLXN_27(15:0)" name="A(15:0)" />
            <blockpin signalname="XLXN_28(1:0)" name="NBL(1:0)" />
            <blockpin signalname="XLXN_29(15:0)" name="D(15:0)" />
        </block>
        <block symbolname="fsmc2bram" name="glue">
            <blockpin signalname="XLXN_70" name="clk" />
            <blockpin signalname="XLXN_26" name="NWE" />
            <blockpin signalname="XLXN_25" name="NOE" />
            <blockpin signalname="XLXN_24" name="NCE" />
            <blockpin signalname="XLXN_27(15:0)" name="A(15:0)" />
            <blockpin signalname="XLXN_28(1:0)" name="NBL(1:0)" />
            <blockpin signalname="XLXN_29(15:0)" name="bram_do(15:0)" />
            <blockpin signalname="XLXN_34" name="bram_en" />
            <blockpin signalname="XLXN_32(15:0)" name="bram_a(15:0)" />
            <blockpin signalname="XLXN_33(15:0)" name="bram_di(15:0)" />
            <blockpin signalname="XLXN_35(1:0)" name="bram_we(1:0)" />
            <blockpin signalname="XLXN_38(15:0)" name="D(15:0)" />
        </block>
        <block symbolname="bram" name="bram_sym">
            <blockpin signalname="XLXN_32(15:0)" name="addra(12:0)" />
            <blockpin signalname="XLXN_33(15:0)" name="dina(15:0)" />
            <blockpin signalname="XLXN_34" name="ena" />
            <blockpin signalname="XLXN_35(1:0)" name="wea(1:0)" />
            <blockpin signalname="XLXN_70" name="clka" />
            <blockpin name="addrb(10:0)" />
            <blockpin name="dinb(63:0)" />
            <blockpin name="enb" />
            <blockpin name="web(7:0)" />
            <blockpin signalname="XLXN_22" name="clkb" />
            <blockpin signalname="XLXN_38(15:0)" name="douta(15:0)" />
            <blockpin name="doutb(63:0)" />
        </block>
    </netlist>
    <sheet sheetnum="1" width="7609" height="5382">
        <attr value="CM" name="LengthUnitName" />
        <attr value="4" name="GridsPerUnit" />
        <instance x="272" y="896" name="stimuly" orien="R0">
        </instance>
        <iomarker fontsize="28" x="1568" y="1280" name="XLXN_22" orien="R180" />
        <branch name="XLXN_24">
            <wire x2="752" y1="544" y2="544" x1="656" />
            <wire x2="752" y1="544" y2="784" x1="752" />
            <wire x2="848" y1="784" y2="784" x1="752" />
        </branch>
        <branch name="XLXN_27(15:0)">
            <wire x2="736" y1="736" y2="736" x1="656" />
            <wire x2="736" y1="736" y2="848" x1="736" />
            <wire x2="848" y1="848" y2="848" x1="736" />
        </branch>
        <branch name="XLXN_28(1:0)">
            <wire x2="720" y1="800" y2="800" x1="656" />
            <wire x2="720" y1="800" y2="912" x1="720" />
            <wire x2="848" y1="912" y2="912" x1="720" />
        </branch>
        <branch name="XLXN_29(15:0)">
            <wire x2="672" y1="864" y2="864" x1="656" />
            <wire x2="672" y1="864" y2="976" x1="672" />
            <wire x2="848" y1="976" y2="976" x1="672" />
        </branch>
        <branch name="XLXN_22">
            <wire x2="1584" y1="1280" y2="1280" x1="1568" />
            <wire x2="1584" y1="1040" y2="1280" x1="1584" />
            <wire x2="1632" y1="1040" y2="1040" x1="1584" />
        </branch>
        <branch name="XLXN_35(1:0)">
            <wire x2="1616" y1="880" y2="880" x1="1296" />
            <wire x2="1632" y1="624" y2="624" x1="1616" />
            <wire x2="1616" y1="624" y2="880" x1="1616" />
        </branch>
        <branch name="XLXN_33(15:0)">
            <wire x2="1440" y1="784" y2="784" x1="1296" />
            <wire x2="1440" y1="528" y2="784" x1="1440" />
            <wire x2="1632" y1="528" y2="528" x1="1440" />
        </branch>
        <branch name="XLXN_32(15:0)">
            <wire x2="1456" y1="688" y2="688" x1="1296" />
            <wire x2="1456" y1="496" y2="688" x1="1456" />
            <wire x2="1632" y1="496" y2="496" x1="1456" />
        </branch>
        <instance x="1632" y="416" name="bram_sym" orien="R0">
        </instance>
        <branch name="XLXN_38(15:0)">
            <wire x2="1344" y1="976" y2="976" x1="1296" />
            <wire x2="1344" y1="976" y2="1152" x1="1344" />
            <wire x2="2336" y1="1152" y2="1152" x1="1344" />
            <wire x2="2336" y1="496" y2="496" x1="2208" />
            <wire x2="2336" y1="496" y2="1152" x1="2336" />
        </branch>
        <branch name="XLXN_34">
            <wire x2="1616" y1="592" y2="592" x1="1296" />
            <wire x2="1632" y1="560" y2="560" x1="1616" />
            <wire x2="1616" y1="560" y2="592" x1="1616" />
        </branch>
        <instance x="848" y="1008" name="glue" orien="R0">
        </instance>
        <branch name="XLXN_26">
            <wire x2="672" y1="608" y2="608" x1="656" />
            <wire x2="672" y1="608" y2="656" x1="672" />
            <wire x2="848" y1="656" y2="656" x1="672" />
        </branch>
        <branch name="XLXN_25">
            <wire x2="672" y1="672" y2="672" x1="656" />
            <wire x2="672" y1="672" y2="720" x1="672" />
            <wire x2="848" y1="720" y2="720" x1="672" />
        </branch>
        <branch name="XLXN_70">
            <wire x2="768" y1="480" y2="480" x1="656" />
            <wire x2="768" y1="480" y2="592" x1="768" />
            <wire x2="848" y1="592" y2="592" x1="768" />
            <wire x2="1520" y1="480" y2="480" x1="768" />
            <wire x2="1520" y1="480" y2="688" x1="1520" />
            <wire x2="1632" y1="688" y2="688" x1="1520" />
        </branch>
    </sheet>
</drawing>