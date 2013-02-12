package r.shootout.reversecomplement;

import org.junit.*;
import r.shootout.*;

public class TestReverseComplement extends ShootoutTestBase {
    @Test
    public void testReverseComplement() {
        String inputFile = ".tmp.unit.reversecomplement.input";
        generateFastaOutput(100, inputFile);
        assertShootout("reversecomplement", "reversecomplement", inputFile,
">ONE Homo sapiens alu\n" +
"CCGGCCCGCGCCACCGAGTGCGGACATTAGGGTCGTGAAACCCTCCGGCTCCGCCCGCCT\n" +
"AGTGGACTCCAGTCCTCAAGCTCTGGTCGGACCGGTTGTACCACTTTGGGGCAGAGATGA\n" +
"TTTTTATGTTTTTAATCGGCCCGCACCACCGCGCGCGGACATTAGGGTCGATGAGCCCTC\n" +
"CGACTCCGTCCTCTTAGCGA\n" +
">TWO IUB ambiguity codes\n" +
"GAAVATAGTATACGATMCCNGTATTTSTACATTTHGHYAVCCHAGAAATATTAAGVCAGC\n" +
"ATGAHAHTCGGATAAASBDADAAMACADKTSTAACWTDMDAAAATCTGTAWTACAYCTTT\n" +
"NATGAKGSKARAGKCYATGAAGAWVTGCTTTATATCSGHAAACTTCTGTGTATCABCRCA\n" +
"GTAADWAKKWGSACAATCCMASCTRTTGGWSAGCVAACGCTKAAVRTAGWACTGTRGTCT\n" +
"CATVHAYTGAAAAGWTAKAAHVGTAWATAGAATGATVCTRAGAACAAAAAAAARTTSGRT\n" +
">THREE Homo sapiens frequency\n" +
"AGAGCCACATCGAATATTTACGTAGGCATTCTTATAATACAAATAAACAGCCATGCAAGT\n" +
"ACCATCACCACAGCGGCTAAATCTGCATTTCCGTACATACCTAGAACTAGATACGTTTCC\n" +
"ATCCAGGTAGATATATGCAACGTGTCGCCTATGTTTATTCTATTCTTAAATGATTGTAAA\n" +
"TTTAAAAGAATAACAGCTCGTATCTAACCTCCTTTTTGAATAAATGAACCATAAATTTGC\n" +
"CTTCAAAGATTACAAATACTAACCTACGTGCCTGTCAAATGACGAATGAAAGAATCCAAA\n" +
"GAACTTGTTGTCCTACGTGATCATTGTACAGAGCAAGTACGAAGGTAATTCAAGAAGAAT\n" +
"TTGAATGTGTTTGATGGATTAAATCTCAACTGCTCTACCAACTTGCACAACACTGTTTGC\n" +
"AAACGTTTTACGTGTCATAGCAATGGTTTTTCATGTAAATTCACACACGCATCCTTAAGA\n" +
"CGATGCAGGTAACGTCCGGT\n",
                        null, "NULL");
    }

    @Test
    public void testReverseComplementNaive() {
        String inputFile = ".tmp.unit.reversecomplement.input";
        generateFastaOutput(100, inputFile);
        assertShootout("reversecomplement", "reversecomplement-naive", inputFile,
">ONE Homo sapiens alu\n" +
"CCGGCCCGCGCCACCGAGTGCGGACATTAGGGTCGTGAAACCCTCCGGCTCCGCCCGCCT\n" +
"AGTGGACTCCAGTCCTCAAGCTCTGGTCGGACCGGTTGTACCACTTTGGGGCAGAGATGA\n" +
"TTTTTATGTTTTTAATCGGCCCGCACCACCGCGCGCGGACATTAGGGTCGATGAGCCCTC\n" +
"CGACTCCGTCCTCTTAGCGA\n" +
">TWO IUB ambiguity codes\n" +
"GAAVATAGTATACGATMCCNGTATTTSTACATTTHGHYAVCCHAGAAATATTAAGVCAGC\n" +
"ATGAHAHTCGGATAAASBDADAAMACADKTSTAACWTDMDAAAATCTGTAWTACAYCTTT\n" +
"NATGAKGSKARAGKCYATGAAGAWVTGCTTTATATCSGHAAACTTCTGTGTATCABCRCA\n" +
"GTAADWAKKWGSACAATCCMASCTRTTGGWSAGCVAACGCTKAAVRTAGWACTGTRGTCT\n" +
"CATVHAYTGAAAAGWTAKAAHVGTAWATAGAATGATVCTRAGAACAAAAAAAARTTSGRT\n" +
">THREE Homo sapiens frequency\n" +
"AGAGCCACATCGAATATTTACGTAGGCATTCTTATAATACAAATAAACAGCCATGCAAGT\n" +
"ACCATCACCACAGCGGCTAAATCTGCATTTCCGTACATACCTAGAACTAGATACGTTTCC\n" +
"ATCCAGGTAGATATATGCAACGTGTCGCCTATGTTTATTCTATTCTTAAATGATTGTAAA\n" +
"TTTAAAAGAATAACAGCTCGTATCTAACCTCCTTTTTGAATAAATGAACCATAAATTTGC\n" +
"CTTCAAAGATTACAAATACTAACCTACGTGCCTGTCAAATGACGAATGAAAGAATCCAAA\n" +
"GAACTTGTTGTCCTACGTGATCATTGTACAGAGCAAGTACGAAGGTAATTCAAGAAGAAT\n" +
"TTGAATGTGTTTGATGGATTAAATCTCAACTGCTCTACCAACTTGCACAACACTGTTTGC\n" +
"AAACGTTTTACGTGTCATAGCAATGGTTTTTCATGTAAATTCACACACGCATCCTTAAGA\n" +
"CGATGCAGGTAACGTCCGGT\n",
                        null, "NULL");
    }

    @Test
    public void testReverseComplement2() {
        String inputFile = ".tmp.unit.reversecomplement.input";
        generateFastaOutput(100, inputFile);
        assertShootout("reversecomplement", "reversecomplement-2", inputFile,
">ONE Homo sapiens alu\n" +
"CCGGCCCGCGCCACCGAGTGCGGACATTAGGGTCGTGAAACCCTCCGGCTCCGCCCGCCT\n" +
"AGTGGACTCCAGTCCTCAAGCTCTGGTCGGACCGGTTGTACCACTTTGGGGCAGAGATGA\n" +
"TTTTTATGTTTTTAATCGGCCCGCACCACCGCGCGCGGACATTAGGGTCGATGAGCCCTC\n" +
"CGACTCCGTCCTCTTAGCGA\n" +
">TWO IUB ambiguity codes\n" +
"GAAVATAGTATACGATMCCNGTATTTSTACATTTHGHYAVCCHAGAAATATTAAGVCAGC\n" +
"ATGAHAHTCGGATAAASBDADAAMACADKTSTAACWTDMDAAAATCTGTAWTACAYCTTT\n" +
"NATGAKGSKARAGKCYATGAAGAWVTGCTTTATATCSGHAAACTTCTGTGTATCABCRCA\n" +
"GTAADWAKKWGSACAATCCMASCTRTTGGWSAGCVAACGCTKAAVRTAGWACTGTRGTCT\n" +
"CATVHAYTGAAAAGWTAKAAHVGTAWATAGAATGATVCTRAGAACAAAAAAAARTTSGRT\n" +
">THREE Homo sapiens frequency\n" +
"AGAGCCACATCGAATATTTACGTAGGCATTCTTATAATACAAATAAACAGCCATGCAAGT\n" +
"ACCATCACCACAGCGGCTAAATCTGCATTTCCGTACATACCTAGAACTAGATACGTTTCC\n" +
"ATCCAGGTAGATATATGCAACGTGTCGCCTATGTTTATTCTATTCTTAAATGATTGTAAA\n" +
"TTTAAAAGAATAACAGCTCGTATCTAACCTCCTTTTTGAATAAATGAACCATAAATTTGC\n" +
"CTTCAAAGATTACAAATACTAACCTACGTGCCTGTCAAATGACGAATGAAAGAATCCAAA\n" +
"GAACTTGTTGTCCTACGTGATCATTGTACAGAGCAAGTACGAAGGTAATTCAAGAAGAAT\n" +
"TTGAATGTGTTTGATGGATTAAATCTCAACTGCTCTACCAACTTGCACAACACTGTTTGC\n" +
"AAACGTTTTACGTGTCATAGCAATGGTTTTTCATGTAAATTCACACACGCATCCTTAAGA\n" +
"CGATGCAGGTAACGTCCGGT\n",
                        null, "NULL");
    }
}
