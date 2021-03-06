#include "Riostream.h"
#include "TFile.h"
//#include "TH1F.h"
#include "TF1.h"
//#include "TH2F.h"
//#include "TCanvas.h"
//#include "TNtuple.h"
#include "TGraph.h"
#include "TMath.h"
#include "xigar_params.h"
//#include "math.h"
//#include "TRandom.h"

// TNtuple *ntuple = new TNtuple("ntuple","data from ascii file","x:y");
// TH1F *h1 = new TH1F("h1","x distribution",100,-4,4);
TGraph *gr = new TGraph();

// Define the break in fit here (two different fits for low temperatures and high temperatures).
// const Float_t param_break = 3.;

// Number of header lines.
const Int_t nheader = 10;

// const Int_t nfiles = 1070;

// const Int_t n = (nspectra+1)-nheader;
const Int_t n = 101-nheader;
const Int_t nfiles = nchannels2;

float chisquarelow[nfiles],parlow1[nfiles],parlow2[nfiles],parlow3[nfiles],parlow4[nfiles];
float chisquarehigh[nfiles],parhigh1[nfiles],parhigh2[nfiles],parhigh3[nfiles],parhigh4[nfiles];
float nf[nfiles];

Double_t x[n], y[n];

// void LoadParameters() {
// 	ifstream in;
// 	in.open("xigar_params.c");
// 	in >> temp_low >> temp_high >> exposure >> nfiles >> nspectra;
// 	in.close();
// }

void LoadData(Int_t i) {
	
   ifstream in;

	if (i < 10) {
		in.open(Form("./tmp/profile_    %1i.txt",i));
		// printf("Opening file profile_1_    %1i.txt\n",i);
	}
	else if (i >= 10 && i < 100) {
		in.open(Form("./tmp/profile_   %2i.txt",i));
	}
	else if (i >= 100 && i < 1000) {
		in.open(Form("./tmp/profile_  %3i.txt",i));
	}
	else if (i >= 1000 && i < 10000) {
		in.open(Form("./tmp/profile_ %4i.txt",i));
	}
	else if (i >= 10000) {
		printf("ERROR: i must be an integer between 1 and 10000!\n");
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

// double CalcRMS(TF1 *fit) {
// 	float rms = 0.;
// 	printf("Eval(4) = %f\n",fit->Eval(4));
// 	printf("y(4) = %f\n",y[4]);
// 	for (int i=1;i<n;++i) {
// 		rms = rms + pow((fit->Eval(i) - y[i])/(0.5*(fit->Eval(i)+y[i])),2.);
// 		// printf("fit->Eval(i) = %f, y[i] = %f, rms = %f\n",fit->Eval(i),y[i],rms);
// 	}
// 	rms = pow(rms/n,1./2.);
// 	return rms;
// }

void FitAll() {
	
	TF1 *thefitlow = new TF1("thefitlow",thefitfunc,param_min,param_break,4);
	TF1 *thefithigh = new TF1("thefithigh",thefitfunc,param_break,param_max,4);
	
	for (int i = 1;i<nfiles;++i) {
		LoadData(i);
		gr->Fit("thefitlow","qR");
		TF1 *fitlow = gr->GetFunction("thefitlow");
		chisquarelow[i] = gr->Chisquare(fitlow);
		parlow1[i] = fitlow->GetParameter(0);
		parlow2[i] = fitlow->GetParameter(1);
		parlow3[i] = fitlow->GetParameter(2);
		parlow4[i] = fitlow->GetParameter(3);
		
		gr->Fit("thefithigh","qR");
		TF1 *fithigh = gr->GetFunction("thefithigh");
		chisquarehigh[i] = gr->Chisquare(fithigh);
		parhigh1[i] = fithigh->GetParameter(0);
		parhigh2[i] = fithigh->GetParameter(1);
		parhigh3[i] = fithigh->GetParameter(2);
		parhigh4[i] = fithigh->GetParameter(3);
		
		nf[i]=i;
	}
}

// void FitAllLowT() {
// 	TF1 *thefit = new TF1("thefit",thefitfunc,0.,3.,4);
// 	
// 	for (int i = 1;i<nfiles;++i) {
// 		LoadData(i);
// 		gr->Fit("thefit","qR");
// 		TF1 *fit = gr->GetFunction("thefit");
// 		chisquare[i] = gr->Chisquare(fit);
// 		par1[i] = fit->GetParameter(0);
// 		par2[i] = fit->GetParameter(1);
// 		par3[i] = fit->GetParameter(2);
// 		par4[i] = fit->GetParameter(3);
// 		nf[i]=i;
// 	}
// }
// 
// void FitAllHighT() {
// 	TF1 *thefit = new TF1("thefit",thefitfunc,3.,15.,4);
// 	
// 	for (int i = 1;i<nfiles;++i) {
// 		LoadData(i);
// 		gr->Fit("thefit","qR");
// 		TF1 *fit = gr->GetFunction("thefit");
// 		chisquare[i] = gr->Chisquare(fit);
// 		par1[i] = fit->GetParameter(0);
// 		par2[i] = fit->GetParameter(1);
// 		par3[i] = fit->GetParameter(2);
// 		par4[i] = fit->GetParameter(3);
// 		nf[i]=i;
// 	}
// }

// void FitChannel(Int_t i) {
// 	LoadData(i);
// 	
// 	TCanvas *c0;
// 	c0 = new TCanvas("c0"," ",1000,750);
// 	
// 	TF1 *thefit = new TF1("thefit",thefitfunc,0.,15.,4);
// 	
// 	gr->Fit("thefit");
// 	TF1 *fit = gr->GetFunction("thefit");
// 	printf("Chisquare = %f\n",gr->Chisquare(fit));
// 
// 	gr->SetMarkerColor(4);
//    gr->SetMarkerStyle(2);
// 	gr->Draw("AP");
// 	c0->Update();
// 	
// 	// printf("RMS = %f\n",CalcRMS(fit));
// }

// void WriteParameters() {
// 	FILE *fout = fopen("parout.txt","w");
// 	fprintf(fout,"%s %13s %15s %15s %15s %15s %15s %s", "#", "channel", "chisquare", "parameter1", "parameter2", "parameter3", "parameter4","\n");
// 	for (int i = 1;i<999;++i) {
// 		fprintf(fout,"%15f %15f %15f %15f %15f %15f %s",nf[i], chisquare[i], par1[i], par2[i], par3[i], par4[i],"\n");
// 	}
// 	fclose(fout);
// }

void WriteParams() {
	FILE *fout = fopen("./cosmomc/fit_params.f90","w");
	
	fprintf(fout,"%s", "module fit_params\n\n");
	fprintf(fout,"%s", "implicit none\n\n");

	fprintf(fout,"%s%i%s", "REAL,DIMENSION(",nfiles,") :: lowpar1 = (/ &\n");
	for (int i = 1;i<nfiles;++i) {
		fprintf(fout,"%15f %s",parlow1[i], ", &\n");
	}
	fprintf(fout,"%15f %s",parlow1[nfiles], " &\n");
	fprintf(fout,"%2s %s", "/)" ,"\n\n");
	
	fprintf(fout,"%s%i%s", "REAL,DIMENSION(",nfiles,") :: lowpar2 = (/ &\n");
	for (int i = 1;i<nfiles;++i) {
		fprintf(fout,"%15f %s",parlow2[i], ", &\n");
	}
	fprintf(fout,"%15f %s",parlow2[nfiles], " &\n");
	fprintf(fout,"%2s %s", "/)" ,"\n\n");
	
	fprintf(fout,"%s%i%s", "REAL,DIMENSION(",nfiles,") :: lowpar3 = (/ &\n");
	for (int i = 1;i<nfiles;++i) {
		fprintf(fout,"%15f %s",parlow3[i], ", &\n");
	}
	fprintf(fout,"%15f %s",parlow3[nfiles], " &\n");
	fprintf(fout,"%2s %s", "/)" ,"\n\n");
	
	fprintf(fout,"%s%i%s", "REAL,DIMENSION(",nfiles,") :: lowpar4 = (/ &\n");
	for (int i = 1;i<nfiles;++i) {
		fprintf(fout,"%15f %s",parlow4[i], ", &\n");
	}
	fprintf(fout,"%15f %s",parlow4[nfiles], " &\n");
	fprintf(fout,"%2s %s", "/)" ,"\n\n");
	

	fprintf(fout,"%s%i%s", "REAL,DIMENSION(",nfiles,") :: highpar1 = (/ &\n");
	for (int i = 1;i<nfiles;++i) {
		fprintf(fout,"%15f %s",parhigh1[i], ", &\n");
	}
	fprintf(fout,"%15f %s",parhigh1[nfiles], " &\n");
	fprintf(fout,"%2s %s", "/)" ,"\n\n");
	
	fprintf(fout,"%s%i%s", "REAL,DIMENSION(",nfiles,") :: highpar2 = (/ &\n");
	for (int i = 1;i<nfiles;++i) {
		fprintf(fout,"%15f %s",parhigh2[i], ", &\n");
	}
	fprintf(fout,"%15f %s",parhigh2[nfiles], " &\n");
	fprintf(fout,"%2s %s", "/)" ,"\n\n");
	
	fprintf(fout,"%s%i%s", "REAL,DIMENSION(",nfiles,") :: highpar3 = (/ &\n");
	for (int i = 1;i<nfiles;++i) {
		fprintf(fout,"%15f %s",parhigh3[i], ", &\n");
	}
	fprintf(fout,"%15f %s",parhigh3[nfiles], " &\n");
	fprintf(fout,"%2s %s", "/)" ,"\n\n");
	
	fprintf(fout,"%s%i%s", "REAL,DIMENSION(",nfiles,") :: highpar4 = (/ &\n");
	for (int i = 1;i<nfiles;++i) {
		fprintf(fout,"%15f %s",parhigh4[i], ", &\n");
	}
	fprintf(fout,"%15f %s",parhigh4[nfiles], " &\n");
	fprintf(fout,"%2s %s", "/)" ,"\n\n");
	
	fprintf(fout,"%s", "end module fit_params");
	
	fclose(fout);
}

// void PlotResults() {
// 
// 	// Plot chisquare as a function of channel
// 	TCanvas *c1;
// 	c1 = new TCanvas("c1","Chisquare as a function of channel.",1000,750);
// 	
// 	TGraph *gr_chi = new TGraph(nfiles,nf,chisquare);	
// 	gr_chi->SetMarkerColor(4);
//    gr_chi->SetMarkerStyle(2);
// 	gr_chi->SetTitle("Chisquare as a function of channel.");
// 	gr_chi->GetXaxis()->SetTitle("Channel");
// 	gr_chi->GetYaxis()->SetTitle("Chisquare");
// 	gr_chi->Draw("AP");
// 	
// 	c1->SetLogy();
// 	c1->Update();
// 	
// 	// Plot parameter1 as a function of channel
// 	TCanvas *c2;
// 	c2 = new TCanvas("c2","Parameter1 as a function of channel.",1000,750);
// 	
// 	TGraph *gr_par1 = new TGraph(nfiles,nf,par1);	
// 	gr_par1->SetMarkerColor(4);
// 	   gr_par1->SetMarkerStyle(2);
// 	gr_par1->SetTitle("Parameter1 as a function of channel.");
// 	gr_par1->GetXaxis()->SetTitle("Channel");
// 	gr_par1->GetYaxis()->SetTitle("Par1");
// 	gr_par1->Draw("AP");
// 	
// 	//c2->SetLogy();
// 	c2->Update();
// 	
// 	// Plot parameter2 as a function of channel
// 	TCanvas *c3;
// 	c3 = new TCanvas("c3","parameter2 as a function of channel.",1000,750);
// 	
// 	TGraph *gr_par2 = new TGraph(nfiles,nf,par2);	
// 	gr_par2->SetMarkerColor(4);
// 	gr_par2->SetMarkerStyle(2);
// 	gr_par2->SetTitle("parameter2 as a function of channel.");
// 	gr_par2->GetXaxis()->SetTitle("Channel");
// 	gr_par2->GetYaxis()->SetTitle("par2");
// 	gr_par2->Draw("AP");
// 	
// 	//c3->SetLogy();
// 	c3->Update();	
// 	
// 	// Plot parameter3 as a function of channel
// 	TCanvas *c4;
// 	c4 = new TCanvas("c4","parameter3 as a function of channel.",1000,750);
// 	
// 	TGraph *gr_par3 = new TGraph(nfiles,nf,par3);	
// 	gr_par3->SetMarkerColor(4);
// 	gr_par3->SetMarkerStyle(2);
// 	gr_par3->SetTitle("parameter3 as a function of channel.");
// 	gr_par3->GetXaxis()->SetTitle("Channel");
// 	gr_par3->GetYaxis()->SetTitle("par3");
// 	gr_par3->Draw("AP");
// 	
// 	//c4->SetLogy();
// 	c4->Update();
// 	
// 	// Plot parameter4 as a function of channel
// 	TCanvas *c5;
// 	c5 = new TCanvas("c5","parameter4 as a function of channel.",1000,750);
// 	
// 	TGraph *gr_par4 = new TGraph(nfiles,nf,par4);	
// 	gr_par4->SetMarkerColor(4);
// 	gr_par4->SetMarkerStyle(2);
// 	gr_par4->SetTitle("parameter4 as a function of channel.");
// 	gr_par4->GetXaxis()->SetTitle("Channel");
// 	gr_par4->GetYaxis()->SetTitle("par4");
// 	gr_par4->Draw("AP");
// 	
// 	//c5->SetLogy();
// 	c5->Update();
// 	
// }


