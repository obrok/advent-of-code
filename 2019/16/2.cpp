#include <cstdio>
#include <cstring>
#include <cstdlib>
#include <algorithm>

using namespace std;

const int modifiers[] = {1, 0, -1, 0};

int main() {
  char input[1000];
  scanf("%s", input);

  int input_len = strlen(input);

  int data_len = 10000 * input_len;
  int* data = new int[data_len];
  for (int i = 0; i < data_len; i++) {
    data[i] = input[i % input_len] - '0';
  }

  int offset = 0;
  for (int i = 0; i < 7; i++) {
    offset *= 10;
    offset += data[i];
  }

  long long int* sums = new long long int[data_len + 1];

  for (int p = 0; p < 100; p++) {
    printf("%d\n", p);

    sums[0] = 0;
    for (int i = 0; i < data_len; i++) {
      sums[i + 1] = sums[i] + data[i];
    }

    for (int i = 0; i < data_len; i++) {
      long long int total = 0;
      int j = 0;
      int left = i;
      while (left < data_len) {
        total += modifiers[j % 4] * (sums[min(left + i + 1, data_len - 1)] - sums[left]);
        j += 1;
        left += i + 1;
      }
      data[i] = abs(total % 10);
    }
  }

  for (int i = 0; i < 8; i++) {
    printf("%d", data[offset + i]);
  }
  printf("\n");
}
