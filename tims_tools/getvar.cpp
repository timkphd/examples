
#include <iostream>
#include <vector>
#include <string>
#include <cstring>
#include <sstream>

// Return the value(s) of an environmental variable as a vector 
// We assume a given delimiter between "values". 
// Use '\n' as the delimiter to return everything as a string in res[0].
// We pass in char *envp[] from main when main is called like this
// int main(int argc, char **argv, char *envp[])
// Returns a zero length vector if the variable is not defined.
std::vector<std::string> getvar(char *BONK, char dlim, char *envp[]) {
	int k=0;
	std::vector<std::string> res;
	while (envp[k] != NULL) {
		if (strlen(envp[k]) > 3) {
			std::string totest=envp[k];
			if (totest.find(BONK) == 0 && totest.find("=")==strlen(BONK)){
				std::stringstream ss(envp[k]+strlen(BONK)+1);
				std::string token;
				while (getline(ss, token, dlim)) { res.push_back(token); }
				return res;	
			}
		k++;
		}
	}
	return res;
}

// Return the value(s) of an environmental variable as a vector 
// We assume a given delimiter between "values". 
// Use '\n' as the delimiter to return everything as a string in res[0].
// We use getenv so we don't need to pass in envp
std::vector<std::string> getvar(char *BONK, char dlim) {
	int k=0;
	std::vector<std::string> res;
	const char* varstr = getenv(BONK);
	if(varstr != NULL) {
		std::string totest=varstr;
		std::stringstream ss(varstr);
		std::string token;
		while (getline(ss, token, dlim)) { res.push_back(token); }
		return res;			
	}
	else {
		return res;
	}
}
int main(int argc, char **argv, char *envp[]) {
    char env[20];
    strcpy(env,"PATH");
	std::vector<std::string> res=getvar(env,':',envp);
	for (int i = 0; i < res.size(); i++) {
        std::cout << res[i] << std::endl;
    }
    std::cout << "################" << std::endl;
	res=getvar(env,':');
	for (int i = 0; i < res.size(); i++) {
        std::cout << res[i] << std::endl;
    }
}
