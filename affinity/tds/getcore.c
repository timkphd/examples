extern inline __attribute__((always_inline)) int get_core_number() {
   unsigned long a, d, c;
   __asm__ volatile("rdtscp" : "=a" (a), "=d" (d), "=c" (c));
   return ( c & 0xFFFUL );
}
