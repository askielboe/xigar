#include "Riostream.h"
#include "TFile.h"
#include "TH1F.h"
#include "TF1.h"
#include "TH2F.h"
#include "TCanvas.h"
#include "TNtuple.h"
#include "TGraph.h"
#include "TMath.h"
// #include "math.h"
// #include "TRandom.h"

// TNtuple *ntuple = new TNtuple("ntuple","data from ascii file","x:y");
// TH1F *h1 = new TH1F("h1","x distribution",100,-4,4);
TGraph *gr = new TGraph();

const Int_t nfiles = 999;
const Int_t nheader = 10;
const Int_t n = 101-nheader;

float chisquare[nfiles],par1[nfiles],par2[nfiles],par3[nfiles],par4[nfiles];
float nf[nfiles];

Double_t x[n], y[n];

void LoadData(Int_t i) {
	
   ifstream in;

	if (i < 10) {
		in.open(Form("./data/profiles/profile_1_    %1i.txt",i));
		// printf("Opening file profile_1_    %1i.txt\n",i);
	}
	else if (i >= 10 && i < 100) {
		in.open(Form("./data/profiles/profile_1_   %2i.txt",i));
	}
	else if (i >= 100 && i < 1000) {
		in.open(Form("./data/profiles/profile_1_  %3i.txt",i));
	}
	else if (i >= 1000) {
		printf("ERROR: i must be an integer between 1 and 1000!\n");
		return;
	}
   
	// printf("Opening file data.dat\n");

	Double_t dummy;
   Int_t nlines = 0;
   // TFile *f = new TFile("basic.root","RECREATE");

	// printf("Skipping %i header lines...\n",nheader);
	
	for (int counts = 0; counts < nheader; ++counts) {
		in >> dummy >> dummy;
	}

   while (nlines < n) {
      in >> x[nlines] >> y[nlines];
      if (!in.good()) break;
      // if (nlines < 5) printf("x=%f, y=%f\n",x[nlines],y[nlines]);
		// x[nlines] = TMath::Log(x[nlines]);
		y[nlines] = TMath::Log(y[nlines]);		
      // h1->Fill(x,y);
      // ntuple->Fill(x,y);
      nlines++;
   }
	//    printf(" found %d points\n",nlines);
	// printf("x=%f, y=%f\n",x[0],y[0]);
	// printf("x=%f, y=%f\n",x[1],y[1]);

	gr = new TGraph(n,x,y);

   in.close();

   // f->Write();
}

double thefitfunc(double *v, double *par) {
	// double result = par[0] * pow(TMath::Log(v[0]),3) + par[1] * pow(TMath::Log(v[0]),2) + par[2]*TMath::Log(v[0]) + par[3];
	//	double result = par[5] * pow(v[0],5.) + par[4] * pow(v[0],4.) + par[3] * pow(v[0],3.) + par[2] * pow(v[0],2.) + par[1]*v[0] + par[0];
	//	double result = par[4] * pow(v[0],4.) + par[3] * pow(v[0],3.) + par[2] * pow(v[0],2.) + par[1]*v[0] + par[0];
	double result = par[0] * pow(v[0],3.) + par[1] * pow(v[0],2.) + par[2]*v[0] + par[3];
	// double result = par[0] * pow(v[0],3.) + par[1];
	// double result = par[0] * pow(v[0],2.) + par[1]*v[0] + par[2];
	// double result = par[0]*pow(v[0],-1./2.)+par[1];
	return result;
}

double CalcRMS(TF1 *fit) {
	float rms = 0.;
	printf("Eval(4) = %f\n",fit->Eval(4));
	printf("y(4) = %f\n",y[4]);
	for (int i=1;i<n;++i) {
		rms = rms + pow((fit->Eval(i) - y[i])/(0.5*(fit->Eval(i)+y[i])),2.);
		// printf("fit->Eval(i) = %f, y[i] = %f, rms = %f\n",fit->Eval(i),y[i],rms);
	}
	rms = pow(rms/n,1./2.);
	return rms;
}

void FitAllLowT() {
	TF1 *thefit = new TF1("thefit",thefitfunc,0.,3.,4);
	
	for (int i = 1;i<999;++i) {
		LoadData(i);
		gr->Fit("thefit","qR");
		TF1 *fit = gr->GetFunction("thefit");
		chisquare[i] = gr->Chisquare(fit);
		par1[i] = fit->GetParameter(0);
		par2[i] = fit->GetParameter(1);
		par3[i] = fit->GetParameter(2);
		par4[i] = fit->GetParameter(3);
		nf[i]=i;
	}
}

void FitAllHighT() {
	TF1 *thefit = new TF1("thefit",thefitfunc,3.,15.,4);
	
	for (int i = 1;i<999;++i) {
		LoadData(i);
		gr->Fit("thefit","qR");
		TF1 *fit = gr->GetFunction("thefit");
		chisquare[i] = gr->Chisquare(fit);
		par1[i] = fit->GetParameter(0);
		par2[i] = fit->GetParameter(1);
		par3[i] = fit->GetParameter(2);
		par4[i] = fit->GetParameter(3);
		nf[i]=i;
	}
}

void FitChannel(Int_t i) {
	LoadData(i);
	
	TCanvas *c0;
	c0 = new TCanvas("c0"," ",1000,750);
	
	TF1 *thefit = new TF1("thefit",thefitfunc,0.,15.,4);
	
	gr->Fit("thefit");
	TF1 *fit = gr->GetFunction("thefit");
	printf("Chisquare = %f\n",gr->Chisquare(fit));

	gr->SetMarkerColor(4);
   gr->SetMarkerStyle(2);
	gr->Draw("AP");
	c0->Update();
	
	// printf("RMS = %f\n",CalcRMS(fit));
}

void WriteParameters() {
	FILE *fout = fopen("parout.txt","w");
	fprintf(fout,"%s %13s %15s %15s %15s %15s %15s %s", "#", "channel", "chisquare", "parameter1", "parameter2", "parameter3", "parameter4","\n");
	for (int i = 1;i<999;++i) {
		fprintf(fout,"%15f %15f %15f %15f %15f %15f %s",nf[i], chisquare[i], par1[i], par2[i], par3[i], par4[i],"\n");
	}
	fclose(fout);
}

void WriteParSimple() {
	FILE *fout = fopen("parout_simple.txt","w");
	
	fprintf(fout,"%15s %s", "highpar1 = (/ &" ,"\n");
	for (int i = 1;i<998;++i) {
		fprintf(fout,"%15f %s",par1[i], ", &\n");
	}
	fprintf(fout,"%15f %s",par1[999], " &\n");
	fprintf(fout,"%15s %s", "/)" ,"\n\n");
	
	fprintf(fout,"%15s %s", "highpar2 = (/ &" ,"\n");
	for (int i = 1;i<998;++i) {
		fprintf(fout,"%15f %s",par2[i], ", &\n");
	}
	fprintf(fout,"%15f %s",par2[999], " &\n");
	fprintf(fout,"%15s %s", "/)" ,"\n\n");
	
	fprintf(fout,"%15s %s", "highpar3 = (/ &" ,"\n");
	for (int i = 1;i<998;++i) {
		fprintf(fout,"%15f %s",par3[i], ", &\n");
	}
	fprintf(fout,"%15f %s",par3[999], " &\n");
	fprintf(fout,"%15s %s", "/)" ,"\n\n");
	
	fprintf(fout,"%15s %s", "highpar4 = (/ &" ,"\n");
	for (int i = 1;i<998;++i) {
		fprintf(fout,"%15f %s",par4[i], ", &\n");
	}
	fprintf(fout,"%15f %s",par4[999], " &\n");
	fprintf(fout,"%15s %s", "/)" ,"\n\n");
	
	fclose(fout);
}

void PlotResults() {

	// Plot chisquare as a function of channel
	TCanvas *c1;
	c1 = new TCanvas("c1","Chisquare as a function of channel.",1000,750);
	
	TGraph *gr_chi = new TGraph(nfiles,nf,chisquare);	
	gr_chi->SetMarkerColor(4);
   gr_chi->SetMarkerStyle(2);
	gr_chi->SetTitle("Chisquare as a function of channel.");
	gr_chi->GetXaxis()->SetTitle("Channel");
	gr_chi->GetYaxis()->SetTitle("Chisquare");
	gr_chi->Draw("AP");
	
	c1->SetLogy();
	c1->Update();
	
	// Plot parameter1 as a function of channel
	TCanvas *c2;
	c2 = new TCanvas("c2","Parameter1 as a function of channel.",1000,750);
	
	TGraph *gr_par1 = new TGraph(nfiles,nf,par1);	
	gr_par1->SetMarkerColor(4);
	   gr_par1->SetMarkerStyle(2);
	gr_par1->SetTitle("Parameter1 as a function of channel.");
	gr_par1->GetXaxis()->SetTitle("Channel");
	gr_par1->GetYaxis()->SetTitle("Par1");
	gr_par1->Draw("AP");
	
	//c2->SetLogy();
	c2->Update();
	
	// Plot parameter2 as a function of channel
	TCanvas *c3;
	c3 = new TCanvas("c3","parameter2 as a function of channel.",1000,750);
	
	TGraph *gr_par2 = new TGraph(nfiles,nf,par2);	
	gr_par2->SetMarkerColor(4);
	gr_par2->SetMarkerStyle(2);
	gr_par2->SetTitle("parameter2 as a function of channel.");
	gr_par2->GetXaxis()->SetTitle("Channel");
	gr_par2->GetYaxis()->SetTitle("par2");
	gr_par2->Draw("AP");
	
	//c3->SetLogy();
	c3->Update();	
	
	// Plot parameter3 as a function of channel
	TCanvas *c4;
	c4 = new TCanvas("c4","parameter3 as a function of channel.",1000,750);
	
	TGraph *gr_par3 = new TGraph(nfiles,nf,par3);	
	gr_par3->SetMarkerColor(4);
	gr_par3->SetMarkerStyle(2);
	gr_par3->SetTitle("parameter3 as a function of channel.");
	gr_par3->GetXaxis()->SetTitle("Channel");
	gr_par3->GetYaxis()->SetTitle("par3");
	gr_par3->Draw("AP");
	
	//c4->SetLogy();
	c4->Update();
	
	// Plot parameter4 as a function of channel
	TCanvas *c5;
	c5 = new TCanvas("c5","parameter4 as a function of channel.",1000,750);
	
	TGraph *gr_par4 = new TGraph(nfiles,nf,par4);	
	gr_par4->SetMarkerColor(4);
	gr_par4->SetMarkerStyle(2);
	gr_par4->SetTitle("parameter4 as a function of channel.");
	gr_par4->GetXaxis()->SetTitle("Channel");
	gr_par4->GetYaxis()->SetTitle("par4");
	gr_par4->Draw("AP");
	
	//c5->SetLogy();
	c5->Update();
	
}


