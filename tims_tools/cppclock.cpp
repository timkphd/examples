#include <chrono>
#include <iostream>
double myclock() {
    using namespace std::chrono;
    double t1;
    auto start = system_clock::now();
    auto duration = start.time_since_epoch();
    t1=std::chrono::duration<double>(duration).count();
    return t1;
}
int main() {
    double t1,t2;
    std::cout.precision(16);
    t1=myclock();
    t2=myclock();	
    std::cout <<  t1 << std::endl;
    std::cout <<  t2 << std::endl;
    double dt=(t2-t1)*1e9;
    std::cout.precision(9);
    std::cout << dt << " nsec\n";
    return 0;
}


