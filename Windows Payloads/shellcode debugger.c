#include <windows.h>
char code[] = "shell code";


int main(int argc, char **argv)
{
#  LoadLibraryA("Shell32.dll");  // load library
  int (*func)();
  func = (int (*)()) code;
  (int)(*func)();
}