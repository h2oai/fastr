package r;

import org.antlr.runtime.*;
import org.junit.*;

public class TestSimpleVectors extends TestBase {

    @Test
    public void testSubscript() throws RecognitionException {
        assertEval("{ x<-1:10; x[3] }", "3L");
        assertEval("{ x<-1:10; x[3L] }", "3L");
        assertEval("{ x<-c(1,2,3); x[3] }", "3.0");
        assertEval("{ x<-c(1,2,3); x[3L] }", "3.0");
        assertEval("{ x<-1:3; x[0-2] }", "1L, 3L");
        assertEval("{ x<-1:3; x[FALSE] }", "integer(0)");
        assertEval("{ x<-1:3; x[TRUE] }", "1L, 2L, 3L");
        assertEval("{ x<-c(TRUE,TRUE,FALSE); x[0-2] }", "TRUE, FALSE");
        assertEval("{ x<-c(1,2);x[[-1]] }", "2.0");
        assertEval("{ x<-c(1,2);x[0-3] }", "1.0, 2.0");
        assertEval("{ x<-10; x[0-1] }", "numeric(0)");
        assertEval("{ x<-10; x[NA] }", "NA");
    }

    @Test
    public void testSubset() throws RecognitionException {
        assertEval("{ x<-1:5 ; x[3:4] }", "3L, 4L");
        assertEval("{ x<-1:5 ; x[4:3] }", "4L, 3L");
        assertEval("{ x<-c(1,2,3,4,5) ; x[4:3] }", "4.0, 3.0");
        assertEval("{ (1:5)[3:4] }", "3L, 4L");
        assertEval("{ x<-(1:5)[2:4] ; x[2:1] }", "3L, 2L");
        assertEval("{ x<-1:5;x[c(0-2,0-3)] }", "1L, 4L, 5L");
        assertEval("{ x<-1:5;x[c(0-2,0-3,0,0,0)] }", "1L, 4L, 5L");
        assertEval("{ x<-1:5;x[c(2,5,4,3,3,3,0)] }", "2L, 5L, 4L, 3L, 3L, 3L");
        assertEval("{ x<-1:5;x[c(2L,5L,4L,3L,3L,3L,0L)] }", "2L, 5L, 4L, 3L, 3L, 3L");
        assertEval("{ f<-function(x, i) { x[i] } ; f(1:3,3:1) ; f(1:5,c(0,0,0,0-2)) }", "1L, 3L, 4L, 5L");
        assertEval("{ f<-function(x, i) { x[i] } ; f(1:3,0-3) ; f(1:5,c(0,0,0,0-2)) }", "1L, 3L, 4L, 5L");
        assertEval("{ f<-function(x, i) { x[i] } ; f(1:3,0L-3L) ; f(1:5,c(0,0,0,0-2)) }", "1L, 3L, 4L, 5L");
        assertEval("{ x<-1:5 ; x[c(TRUE,FALSE)] }", "1L, 3L, 5L");
        assertEval("{ x<-1:5 ; x[c(TRUE,TRUE,TRUE,NA)] }", "1L, 2L, 3L, NA, 5L");
        assertEval("{ x<-1:5 ; x[c(TRUE,TRUE,TRUE,FALSE,FALSE,FALSE,FALSE,TRUE,NA)] }", "1L, 2L, 3L, NA, NA");
        assertEval("{ f<-function(i) { x<-1:5 ; x[i] } ; f(1) ; f(1L) ; f(TRUE) }", "1L, 2L, 3L, 4L, 5L");
        assertEval("{ f<-function(i) { x<-1:5 ; x[i] } ; f(1) ; f(TRUE) ; f(1L)  }", "1L");
        assertEval("{ f<-function(i) { x<-1:5 ; x[i] } ; f(1) ; f(TRUE) ; f(c(3,2))  }", "3L, 2L");
        assertEval("{ f<-function(i) { x<-1:5 ; x[i] } ; f(1)  ; f(3:4) }", "3L, 4L");
        assertEval("{ f<-function(i) { x<-1:5 ; x[i] } ; f(c(TRUE,FALSE))  ; f(3:4) }", "3L, 4L");
    }
}
