// mcs -out:comp.exe comp.cs
// monodis --output=comp.txt comp.exe

// mcs -d:TRANSPOSE -out:trans.exe comp.cs
// monodis  --output=trans.txt trans.exe

//Read a Text File
using System;
using System.IO;
using System.Diagnostics;
using System.Reflection;
using System.Runtime.InteropServices;
namespace readwriteapp
{
    class Class1
    {
        [STAThread]
        static void Main(string[] args)
        {
            String line;

            Console.WriteLine("spec spac '1600 102'");    
            int spec =1600;
            int spac = 102; 
        /*
            string[] tokens=Console.ReadLine().Split();
            spec =Int16.Parse(tokens[0]);
            spac = Int16.Parse(tokens[1]);
        */
            Console.WriteLine($"{spec}, {spac}");
            int nvalues =spec*spac;
            uint[] values=new uint[nvalues];
            Console.WriteLine("spectral reduction factor      spacial reduction factor");
    /*
            string[] tokens2=Console.ReadLine().Split();
            int rspec =Int16.Parse(tokens2[0]);
            int rspac = Int16.Parse(tokens2[1]);
    */
            int rspec =Int16.Parse(args[0]);
            int rspac = Int16.Parse(args[1]);
            Console.WriteLine($"{rspec}, {rspac}");
	    int w=10;
	    if (args.Length > 2 ) {
		    w=Int16.Parse(args[2]);
	    }
            // int rnvalues =srspec*srspac;
            float elapsed_time;

            try
            {
                //Pass the file path and file name to the StreamReader constructor
#if TRANSPOSE
		StreamReader sr = new StreamReader("transpose");
#else
		StreamReader sr = new StreamReader("original");
#endif
                //Read the first line of text
                //Continue to read until you reach end of file
                line = sr.ReadLine();
                int i=0;
                while (line != null)
                {
                    values[i]=uint.Parse(line);
                    //write the line to console window
                    // Console.WriteLine(line);
                    //Read the next line
                    line = sr.ReadLine();
                    i++;
                }
                Console.WriteLine($"Read {i} values");
                //close the file
                sr.Close();
                var stopwatch = new Stopwatch();
                int count;
                stopwatch.Start();
                for (count=0;count<50;count++){
#if TRANSPOSE
               uint[] dvalues=mytreduce(values,spec,spac,rspec,rspac,w);
#else
               uint[] dvalues=myreduce(values,spec,spac,rspec,rspac,w);
#endif
                }
                stopwatch.Stop();                
                elapsed_time = (float)stopwatch.ElapsedMilliseconds/(count);
#if TRANSPOSE
               uint[] rvalues=mytreduce(values,spec,spac,rspec,rspac,w);
            StreamWriter sw = new StreamWriter("new_sharp_trans",false);
#else
            StreamWriter sw = new StreamWriter("new_sharp",false);
               uint[] rvalues=myreduce(values,spec,spac,rspec,rspac,w);
#endif
            int todo=rvalues.Length;
            for (i=0;i<todo;i++){
                sw.WriteLine($"{rvalues[i]}");
            }
            sw.Close();
            Console.WriteLine($"Wrote {todo} values");
            int[] bounds=MyDim(spec,spac,rspec,rspac);
            Console.WriteLine($"New Spec {bounds[0]} New Spac {bounds[1]}");
            Console.WriteLine($"Time {elapsed_time} ms");





                // Console.ReadLine();
            }
            catch(Exception e)
            {
                Console.WriteLine("Exception: " + e.Message);
            }
            finally
            {
                Console.WriteLine($"Done");
            }
        }



         static uint[] myreduce(uint[] myorg ,int oldspec,int oldspac,int specfac,int spacfac,int awidth) 
        {
    // code to be executed
            
            int newspec=(oldspec/specfac);
            if ( (newspec*specfac) < oldspec ) newspec++;
            int newspac=(oldspac/spacfac);
            if ( (newspac*spacfac) < oldspac ) newspac++;
            int newsize=newspec*newspac;
            uint[] c=new uint[newspec*newspac];
            // spacadd = np.array(range(-awidth,awidth+1))
            for (int nindex=0; nindex<newsize;nindex++) {
                int vnew = nindex/newspac;
                int hnew = nindex-vnew*newspac;
                int v = vnew*specfac;
                int h = hnew*spacfac;
                int oindex=v*oldspac+h;
                double mysum=0;
                int count=0;
                for (int s=-awidth;s<=awidth;s++){
                    int i=h+s;
                    if ((i > -1 ) && (i < oldspac)){
                        mysum=mysum+myorg[oindex+s];
                        count++;
                    }
                }
                c[nindex]=(uint)(mysum/count + 0.5);
                }
                return(c);
        }  
         static uint[] mytreduce(uint[] myorg ,int oldspec,int oldspac,int specfac,int spacfac,int awidth) 
        {
    // code to be executed
            
            int newspec=(oldspec/specfac);
            if ( (newspec*specfac) < oldspec ) newspec++;
            int newspac=(oldspac/spacfac);
            if ( (newspac*spacfac) < oldspac ) newspac++;
            int newsize=newspec*newspac;
            uint[] c=new uint[newspec*newspac];
            // spacadd = np.array(range(-awidth,awidth+1))
            for (int nindex=0; nindex<newsize;nindex++) {                
            int newrow = nindex / newspec         ;
            int newcol = nindex - newrow * newspec ;
            int oldcol = newcol * specfac          ;
            int oldrow = newrow * spacfac          ;
            int oindex = oldrow * oldspec + oldcol ;
            float mysum=0;
            int count=0;

                for (int s=-awidth;s<=awidth;s++){
                    int i = oindex + s * oldspec;
                    if ((i > -1 ) && ((s + oldrow) < oldspac)){
                        mysum=mysum+myorg[i];
                        count++;
                    }
                }
                c[nindex]=(uint)(mysum/count + 0.5);
                }
                return(c);
        }  

        static int[] MyDim(int oldspec,int oldspac,int specfac,int spacfac){
            int newspec=(oldspec/specfac);
            if ( (newspec*specfac) < oldspec ) newspec++;
            int newspac=(oldspac/spacfac);
            if ( (newspac*spacfac) < oldspac ) newspac++;
            int[] c=new int[2];
            c[0]=newspec;
            c[1]=newspac;
            return (c);
    }

}

       
}
