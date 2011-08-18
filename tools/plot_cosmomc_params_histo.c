#include "Riostream.h"
#include "TFile.h"
#include "TF1.h"
#include "TGraph.h"
#include "TMath.h"
#include "stdio.h"
#include "TGText.h"
#include <string>

void PlotParams() {
	// // // // // // Define functions // // // // // // 
	void NormalizeHist(TCanvas *canvas, TH1F *hist) {
		Double_t ymax;
		hist->Draw();
		canvas->Pad()->Update();
		ymax = canvas->Pad()->GetFrame()->GetY2();
		//cout << ymax;
		hist->Scale(1/ymax);
	}

	// // // // // // Set input filename // // // // // //
	TString fnamein = "/Users/askielboe/projects/astrophysics/cosmomc/parameters.txt";
	// TString fnamein = "/Users/askielboe/Documents/Coding/Repositories/astro/xigar/logs/2011-07-28-1928 - mpitestrun4nodes1000samples/parameters.txt";
	// TString fnamein = "/Users/askielboe/Documents/Coding/Repositories/astro/xigar/logs/2011-04-28-1741/parameters.txt";
	// TString fnamein = "/Users/askielboe/Documents/Coding/Repositories/astro/xigar/logs/2011-04-22-1644/parameters.txt";
	// TString fnamein = "/Users/askielboe/Documents/Coding/Repositories/astro/xigar/logs/2011-04-22-2150 - real data res 10, mcmc res 1/parameters.txt";

	// // // // // // Count number of lines // // // // // //
	int numLines = 0;
	ifstream in(fnamein);	
	while ( std::getline(in, std::string()) )
	   ++numLines;
	in.close();
	cout << "Number of lines = " << numLines << ".\n";
	
	// // // // // // Declare variables // // // // // // 
	const Int_t n = numLines;
	Double_t dummy;
	Int_t iline = 1, goodlines;
	Double_t likecheck;
	Double_t like[n], Param1[n], Param2[n], Param3[n], Param4[n], Param5[n], Param6[n], Param7[n];
	
	// // // // // // SETTINGS // // // // // // 
	Double_t likecut = 0.01;
	Int_t nbins = 30;
	
	// // // // // // Define histograms // // // // // //
	// 2011-04-22-1644
	// TH1F *h1 = new TH1F("h1","Param1: rc",nbins,0.1,0.3);
	// TH1F *h2 = new TH1F("h2","Param2: Ta",nbins,0.5,3.0);
	// TH1F *h3 = new TH1F("h3","Param3: Tb",nbins,0.1,1.0);
	// TH1F *h4 = new TH1F("h4","Param4: n0",nbins,0.1,2.0);
	// TH1F *h5 = new TH1F("h5","Param5: Da",nbins,0.1,2.0);
	// TH1F *h6 = new TH1F("h6","Param6: alpha",nbins,-5.0,5.0);
	// TH1F *h7 = new TH1F("h7","Param7: beta",nbins,0.0,5.0);

	TH1F *h1 = new TH1F("h1","Param1: rc",nbins,0.0,0.3);
	TH1F *h2 = new TH1F("h2","Param2: Ta",nbins,0.0,5.0);
	TH1F *h3 = new TH1F("h3","Param3: Tb",nbins,0.0,1.4);
	TH1F *h4 = new TH1F("h4","Param4: n0",nbins,0.0,2.0);
	TH1F *h5 = new TH1F("h5","Param5: Da",nbins,0.0,1.6);
	TH1F *h6 = new TH1F("h6","Param6: alpha",nbins,0.0,6.0);
	TH1F *h7 = new TH1F("h7","Param7: beta",nbins,0.0,1.0);
	
	// // // // // // Parse input file // // // // // //
	in.open(fnamein);
	while (iline < n) {
		in >> likecheck;
		// Do the cut
		if (likecheck < likecut) {
			in >> dummy >> dummy >> dummy >> dummy >> dummy >> dummy >> dummy >> dummy >> dummy;
			iline++;
		}
		else {
			like[iline] = likecheck;
			in >> Param1[iline] >> Param2[iline] >> Param3[iline] >> Param4[iline] >> Param5[iline] >> Param6[iline] >> Param7[iline] >> dummy >> dummy;
			// Fill histograms
			h1->Fill(Param1[iline],like[iline]);
			h2->Fill(Param2[iline],like[iline]);
			h3->Fill(Param3[iline],like[iline]);
			h4->Fill(Param4[iline],like[iline]);
			h5->Fill(Param5[iline],like[iline]);
			h6->Fill(Param6[iline],like[iline]);
			h7->Fill(Param7[iline],like[iline]);
			
			goodlines++;
			iline++;
		}
		if (!in.good()) {
			cout << "WARNING: INPUT FILE IS NOT GOOD: EXITING...\n";
			break;
		}
	}
	
	cout << "Number of lines above cut = " << goodlines << ".\n";	
	
	in.close();
	
	// // // // // // Fitting // // // // // //
	
	TF1 *fit1 = new TF1("fit1","gaus", 0, 2);
	TF1 *fit2 = new TF1("fit2","gaus", 0, 2);
	TF1 *fit3 = new TF1("fit3","gaus", 0, 2);
	TF1 *fit4 = new TF1("fit4","gaus", 0, 2);
	TF1 *fit5 = new TF1("fit5","gaus", 0, 2);
	TF1 *fit6 = new TF1("fit6","gaus", 0, 2);
	TF1 *fit7 = new TF1("fit7","gaus", 0, 2);
	
	// // // // // // Plotting // // // // // //
	
	// First define the canvas and divide it into areas
	TCanvas *c1 = new TCanvas("c1","c1",200,10,900,600);
	c1->Divide(4,3);
	
	// Make and draw each graph in different areas in the canvas
	c1->cd(1);
	//c1_1->SetLogy();
	NormalizeHist(c1,h1);
	//h1->Fit("fit1");
	h1->Draw();
	
	c1->cd(2);
	//c1_2->SetLogy();
	NormalizeHist(c1,h2);
	//h2->Fit("fit2");
	h2->Draw();
	
	c1->cd(3);
	//c1_3->SetLogy();
	NormalizeHist(c1,h3);
	h3->Draw();
	
	c1->cd(4);
	//c1_4->SetLogy();
	NormalizeHist(c1,h4);
	h4->Draw();
	
	c1->cd(5);
	//c1_5->SetLogy();
	NormalizeHist(c1,h5);
	h5->Draw();
	
	c1->cd(6);
	//c1_6->SetLogy();
	NormalizeHist(c1,h6);
	//h6->Fit("fit6");
	h6->Draw();
	
	c1->cd(7);
	// c1_6->SetLogy();
	NormalizeHist(c1,h7);
	h7->Draw();
	
	// Plot degeneracies
	gStyle->SetPalette(1);
	
	c1->cd(8);
	//c1_8->SetLogz();
	gr8 = new TGraph2D(n,Param4,Param7,like);
	gr8->SetTitle("Param4 vs Param7: n0 vs beta");
	gr8->SetMarkerStyle(2);
	gPad->SetTheta(90); // default is 30
	gPad->SetPhi(0); // default is 30
	gPad->Update();
	gr8->Draw("pcol");
	//gr8->Draw("cont,list");
	
	c1->cd(9);
	gr9 = new TGraph2D(n,Param6,Param7,like);
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
	gr10 = new TGraph2D(n,Param5,Param6,like);
	gr10->SetTitle("Param5 vs Param6: Da vs alpha");
	gr10->SetMarkerStyle(2);
	gPad->SetTheta(90); // default is 30
	gPad->SetPhi(0); // default is 30
	gPad->Update();
	//gr10->SetMinimum(0.01);
	//gr10->Set(10);
	gr10->Draw("pcol");
	//gr10->Draw("cont,list");
	
	c1->cd(11);
	gr11 = new TGraph2D(n,Param5,Param7,like);
	gr11->SetTitle("Param5 vs Param7: Da vs beta");
	gr11->SetMarkerStyle(2);
	gPad->SetTheta(90); // default is 30
	gPad->SetPhi(0); // default is 30
	gPad->Update();
	gr11->Draw("pcol");
	//gr11->Draw("cont,list");
	
	c1->cd(12);
	gr12 = new TGraph2D(n,Param1,Param6,like);
	gr12->SetTitle("Param1 vs Param6: rc vs alpha");
	gr12->SetMarkerStyle(2);
	gPad->SetTheta(90); // default is 30
	gPad->SetPhi(0); // default is 30
	gPad->Update();
	gr12->Draw("pcol");
	//gr12->Draw("cont,list");
	
}
