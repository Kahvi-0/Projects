#used to debug shellcode 
#More information here https://kahvi.gitbook.io/reverse-engineering/shell-code/shellcode-in-assembly

#include <windows.h>
char code[] = "shell code";


int main(int argc, char **argv)
{
#  LoadLibraryA("Shell32.dll");  // load library
  int (*func)();
  func = (int (*)()) code;
  (int)(*func)();
}
