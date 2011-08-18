{
	#include "Riostream.h"
	#include "TFile.h"
	#include "TF1.h"
	#include "TGraph.h"
	#include "TMath.h"
	#include "stdio.h"
	#include "TGText.h"
	
	// Count number of lines in file
	int numLines = 0;
	ifstream in("/Users/askielboe/projects/astrophysics/cosmomc/parameters.txt");
	while ( std::getline(in, std::string()) )
	   ++numLines;
	in.close();
	
	//numLines = 1000;
	
	cout << "Number of lines = " << numLines << ".\n";
	
	// Set number of lines (should really be set dynamically)
	Double_t dummy;
	const Int_t n = numLines; // PLOT ONLY THE FIRST 10 LINES
	//Int_n = 0;
	Int_t iline = 1;
	Int_t numLines;
	ifstream in;
	
	// Define variables
	Double_t chi2check;
	Double_t chi2cut = 0.01;
	Double_t chi2[n], Param1[n], Param2[n], Param3[n], Param4[n], Param5[n], Param6[n], Param7[n];
	
	in.open("/Users/askielboe/projects/astrophysics/cosmomc/parameters.txt");
	// Parse parameter file
	while (iline < n) {
		in >> chi2check;
		if (chi2check < chi2cut) {
			in >> dummy >> dummy >> dummy >> dummy >> dummy >> dummy >> dummy >> dummy >> dummy;
		}
		else {
			chi2[iline] = chi2check;
			in >> Param1[iline] >> Param2[iline] >> Param3[iline] >> Param4[iline] >> Param5[iline] >> Param6[iline] >> Param7[iline] >> dummy >> dummy;
			iline++;
		}
		if (!in.good()) break;
	}
	
	in.close();
	
	// Plot the scatter plots
	
	// First define the canvas and divide it into areas
	TCanvas *c1 = new TCanvas("c1","c1",200,10,900,600);
	c1->Divide(4,3);
	
	// Make and draw each graph in different areas in the canvas
	c1->cd(1);
	//c1_1->SetLogy();
	gr1 = new TGraph(n,Param1,chi2);
	gr1->SetTitle("Param1: rc");
	gr1->SetMarkerStyle(2);
	gr1->Draw("AP");
	
	c1->cd(2);
	//c1_2->SetLogy();
	gr2 = new TGraph(n,Param2,chi2);
	gr2->SetTitle("Param2: Ta");
	gr2->SetMarkerStyle(2);
	gr2->Draw("AP");
	
	c1->cd(3);
	//c1_3->SetLogy();
	gr3 = new TGraph(n,Param3,chi2);
	gr3->SetTitle("Param3: Tb");
	gr3->SetMarkerStyle(2);
	gr3->Draw("AP");
	
	c1->cd(4);
	//c1_4->SetLogy();
	gr4 = new TGraph(n,Param4,chi2);
	gr4->SetTitle("Param4: n0");
	gr4->SetMarkerStyle(2);
	gr4->Draw("AP");
	
	c1->cd(5);
	//c1_5->SetLogy();
	gr5 = new TGraph(n,Param5,chi2);
	gr5->SetTitle("Param5: Da");
	gr5->SetMarkerStyle(2);
	gr5->Draw("AP");
	
	c1->cd(6);
	//c1_6->SetLogy();
	gr6 = new TGraph(n,Param6,chi2);
	gr6->SetTitle("Param6: alpha");
	gr6->SetMarkerStyle(2);
	gr6->Draw("AP");
	
	c1->cd(7);
	// c1_6->SetLogy();
	gr7 = new TGraph(n,Param7,chi2);
	gr7->SetTitle("Param7: beta");
	gr7->SetMarkerStyle(2);
	gr7->Draw("AP");
	
	// Plot degeneracies
	gStyle->SetPalette(1);
	
	c1->cd(8);
	//c1_8->SetLogz();
	gr8 = new TGraph2D(n,Param4,Param7,chi2);
	gr8->SetTitle("Param4 vs Param7: n0 vs beta");
	gr8->SetMarkerStyle(2);
	gPad->SetTheta(90); // default is 30
	gPad->SetPhi(0); // default is 30
	gPad->Update();
	gr8->Draw("pcol");
	//gr8->Draw("cont,list");
	
	c1->cd(9);
	gr9 = new TGraph2D(n,Param6,Param7,chi2);
	gr9->SetTitle("Param6 vs Param7: alpha vs beta");
	gr9->SetMarkerStyle(2);
	gPad->SetTheta(90); // default is 30
	gPad->SetPhi(0); // default is 30
	gPad->Update();
	//gr9->SetMinimum(0.01);
	//gr9->Set(1000);
	gr9->Draw("pcol");
	//gr9->Draw("cont");
	
	c1->cd(10);
	gr10 = new TGraph2D(n,Param4,Param6,chi2);
	gr10->SetTitle("Param4 vs Param6: n0 vs alpha");
	gr10->SetMarkerStyle(2);
	gPad->SetTheta(90); // default is 30
	gPad->SetPhi(0); // default is 30
	gPad->Update();
	gr10->Draw("pcol");
	//gr10->Draw("cont,list");
	
	c1->cd(11);
	gr11 = new TGraph2D(n,Param5,Param6,chi2);
	gr11->SetTitle("Param5 vs Param6: Da vs alpha");
	gr11->SetMarkerStyle(2);
	gPad->SetTheta(90); // default is 30
	gPad->SetPhi(0); // default is 30
	gPad->Update();
	//gr11->SetMinimum(0.01);
	//gr11->Set(10);
	gr11->Draw("pcol");
	//gr11->Draw("cont,list");
	
	c1->cd(12);
	gr12 = new TGraph2D(n,Param1,Param6,chi2);
	gr12->SetTitle("Param1 vs Param6: rc vs alpha");
	gr12->SetMarkerStyle(2);
	gPad->SetTheta(90); // default is 30
	gPad->SetPhi(0); // default is 30
	gPad->Update();
	gr12->Draw("pcol");
	//gr12->Draw("cont,list");
}