<?xml version="1.0" encoding="UTF-8"?>
<drawing version="7">
    <attr value="spartan6" name="DeviceFamilyName">
        <trait delete="all:0" />
        <trait editname="all:0" />
        <trait edittrait="all:0" />
    </attr>
    <netlist>
        <signal name="NCE_x" />
        <signal name="NOE_x" />
        <signal name="NWE_x" />
        <signal name="clk_x" />
        <signal name="A_x(15:0)" />
        <signal name="D_x(15:0)" />
        <signal name="NBL_x(1:0)" />
        <signal name="XLXN_5" />
        <port polarity="Output" name="XLXN_5" />
        <blockdef name="fsmc2bram">
            <timestamp>2015-9-16T8:35:48</timestamp>
            <line x2="384" y1="32" y2="32" x1="320" />
            <rect width="64" x="320" y="84" height="24" />
            <line x2="384" y1="96" y2="96" x1="320" />
            <rect width="64" x="320" y="148" height="24" />
            <line x2="384" y1="160" y2="160" x1="320" />
            <rect width="64" x="320" y="212" height="24" />
            <line x2="384" y1="224" y2="224" x1="320" />
            <line x2="0" y1="-352" y2="-352" x1="64" />
            <line x2="0" y1="-288" y2="-288" x1="64" />
            <line x2="0" y1="-224" y2="-224" x1="64" />
            <line x2="0" y1="-160" y2="-160" x1="64" />
            <rect width="64" x="0" y="-108" height="24" />
            <line x2="0" y1="-96" y2="-96" x1="64" />
            <rect width="64" x="0" y="-44" height="24" />
            <line x2="0" y1="-32" y2="-32" x1="64" />
            <rect width="64" x="320" y="-364" height="24" />
            <line x2="384" y1="-352" y2="-352" x1="320" />
            <rect width="256" x="64" y="-384" height="640" />
        </blockdef>
        <blockdef name="fsmc_stimuly">
            <timestamp>2015-9-16T7:44:29</timestamp>
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
        <block symbolname="fsmc2bram" name="glue">
            <blockpin signalname="clk_x" name="hclk" />
            <blockpin signalname="NWE_x" name="NWE" />
            <blockpin signalname="NOE_x" name="NOE" />
            <blockpin signalname="NCE_x" name="NCE" />
            <blockpin signalname="A_x(15:0)" name="A(15:0)" />
            <blockpin signalname="NBL_x(1:0)" name="NBL(1:0)" />
            <blockpin signalname="D_x(15:0)" name="D(15:0)" />
            <blockpin signalname="XLXN_5" name="bram_en" />
            <blockpin name="bram_a(15:0)" />
            <blockpin name="bram_di(15:0)" />
            <blockpin name="bram_we(1:0)" />
        </block>
        <block symbolname="fsmc_stimuly" name="stimuly">
            <blockpin signalname="NCE_x" name="NCE" />
            <blockpin signalname="NWE_x" name="NWE" />
            <blockpin signalname="NOE_x" name="NOE" />
            <blockpin signalname="clk_x" name="clk" />
            <blockpin signalname="A_x(15:0)" name="A(15:0)" />
            <blockpin signalname="NBL_x(1:0)" name="NBL(1:0)" />
            <blockpin signalname="D_x(15:0)" name="D(15:0)" />
        </block>
    </netlist>
    <sheet sheetnum="1" width="3520" height="2720">
        <instance x="1872" y="880" name="glue" orien="R0">
        </instance>
        <instance x="1312" y="896" name="stimuly" orien="R0">
        </instance>
        <branch name="NCE_x">
            <wire x2="1776" y1="480" y2="480" x1="1696" />
            <wire x2="1776" y1="480" y2="720" x1="1776" />
            <wire x2="1872" y1="720" y2="720" x1="1776" />
        </branch>
        <branch name="NOE_x">
            <wire x2="1760" y1="608" y2="608" x1="1696" />
            <wire x2="1760" y1="608" y2="656" x1="1760" />
            <wire x2="1872" y1="656" y2="656" x1="1760" />
        </branch>
        <branch name="NWE_x">
            <wire x2="1760" y1="544" y2="544" x1="1696" />
            <wire x2="1760" y1="544" y2="592" x1="1760" />
            <wire x2="1872" y1="592" y2="592" x1="1760" />
        </branch>
        <branch name="clk_x">
            <wire x2="1744" y1="672" y2="672" x1="1696" />
            <wire x2="1744" y1="528" y2="672" x1="1744" />
            <wire x2="1872" y1="528" y2="528" x1="1744" />
        </branch>
        <branch name="A_x(15:0)">
            <wire x2="1776" y1="736" y2="736" x1="1696" />
            <wire x2="1776" y1="736" y2="784" x1="1776" />
            <wire x2="1872" y1="784" y2="784" x1="1776" />
        </branch>
        <branch name="D_x(15:0)">
            <wire x2="1728" y1="864" y2="864" x1="1696" />
            <wire x2="1728" y1="864" y2="1008" x1="1728" />
            <wire x2="2320" y1="1008" y2="1008" x1="1728" />
            <wire x2="2320" y1="528" y2="528" x1="2256" />
            <wire x2="2320" y1="528" y2="1008" x1="2320" />
        </branch>
        <branch name="NBL_x(1:0)">
            <wire x2="1776" y1="800" y2="800" x1="1696" />
            <wire x2="1776" y1="800" y2="848" x1="1776" />
            <wire x2="1872" y1="848" y2="848" x1="1776" />
        </branch>
        <branch name="XLXN_5">
            <wire x2="2288" y1="912" y2="912" x1="2256" />
        </branch>
        <iomarker fontsize="28" x="2288" y="912" name="XLXN_5" orien="R0" />
    </sheet>
</drawing>