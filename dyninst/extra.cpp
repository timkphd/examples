#include <chrono>
#include <cstdlib>
#include <iostream>
#include <thread>
#ifdef DOE
#define FLT double
// calculate e via a serise 
 FLT doe(){

	FLT psum=-1.0;
	FLT next=0.0;
	FLT bot=0.0;
	FLT fact=1.0;
	while(psum != next){
		psum=next;
		bot=bot+1;
		fact=fact*bot;
		next=next+1.0/fact;
	}
	return psum+1.0;
}
#endif
#ifdef INVERT
// do a bunch of matrix inversions for a given number of milliseconds
int doinvert(int);
#endif
namespace sc = std::chrono;
using milliseconds = sc::duration<unsigned int, std::milli>;

int dostuff(milliseconds delay) {
  std::this_thread::sleep_for(delay);
  return static_cast<int>(delay.count()) * 2;
}

void doitA(milliseconds delay) { dostuff(delay); }

void doitB(milliseconds delay) {
  dostuff(delay);
#ifdef PRINT
	  std::cerr << "did doitB " << "\n";
#endif
#ifdef INVERT
  int iv=doinvert((int)delay.count());
  std::cerr << "did " << iv << " inverts in " << (int)delay.count() << " ms\n";
#endif
#ifdef DOE
  std::cerr << "e=" << doe() << "\n";
#endif
  dostuff(delay);
}

int doitC(milliseconds delay) { return dostuff(delay); }

int doitD(milliseconds delay) { return dostuff(delay); }

int main(int argc, char* argv[]) {
  milliseconds delay{800};
  int c=800;
  if(argc > 1) {
    c = atoi(argv[1]);
    if(c < 0) {
      std::cerr << "Cannot have negative delay time\n";
      return -1;
    }
    delay = milliseconds{c};
  }
  doitA(delay);
  doitB(delay);
  return doitC(delay) + doitD(delay);
}

