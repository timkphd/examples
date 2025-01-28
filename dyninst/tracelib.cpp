#include <cstring>
#include <ctime>
#include <chrono>
#include <iostream>
#include <iomanip>
static char* get_formatted_time() {
  time_t curtime = time(NULL);
  char* fmt_time = asctime(localtime(&curtime));
  if(auto* nl = strchr(fmt_time, '\n'))
    *nl = 0;
  return fmt_time;
}
double myclock() {
    using namespace std::chrono;
    double t1;
    auto start = system_clock::now();
    auto duration = start.time_since_epoch();
    t1=std::chrono::duration<double>(duration).count();
    return t1;
}


extern "C" void trace_entry_func(char const* func_name, char const* desc_line, int num_func_args,
                                 void* func_arg1, int func_arg1_type) {
	auto old_flags = std::cerr.flags(); // save flags
  std::cerr << "[TRACE_ENTRY- func: " << func_name << ", num_args: " << num_func_args;

  if(func_arg1_type == 1) {
    std::cerr << ", arg1: " << *static_cast<int*>(func_arg1);
  }
std::cerr << ", " << desc_line << ", " << get_formatted_time() << " ST "<< std::setprecision(20)<< myclock() << "]\n";
std::cerr.flags(old_flags); // restore flags
}

extern "C" void trace_exit_func(char const* func_name, char const* desc_line, void* ret_val,
                                int ret_val_type) {
	auto old_flags = std::cerr.flags(); // save flags
  std::cerr << "[TRACE_EXIT- func: " << func_name;

  if(ret_val_type == 1) {
    std::cerr << ", ret_val: " << *static_cast<int*>(ret_val);
  }
std::cerr << ", " << desc_line << ", " << get_formatted_time() << " ET "<< std::setprecision(20)<< myclock() << "]\n";
std::cerr.flags(old_flags); // restore flags
}

int count = 0;

extern "C" void trace_callsite_func(char* callsite_func_name, char* desc_line, int num_callsite_args,
                                    void* callsite_arg1, int callsite_arg1_type) {
  std::cerr << "[TRACE_CALLSITE- callsite: " << callsite_func_name << ", num_args: " << num_callsite_args;

  if(num_callsite_args > 0 && callsite_arg1_type == 1) {
    std::cerr << ", callsite_arg1: " << *static_cast<int*>(callsite_arg1);
  }

  std::cerr << ", " << desc_line << ", " << get_formatted_time() << "]\n";
}

